-- Enable the pg_trgm extension for GIN indexes
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Drop the materialized view and any dependent objects
DROP MATERIALIZED VIEW IF EXISTS combined_repo_metrics CASCADE;

-- Create the materialized view with all fields and aggregations

CREATE MATERIALIZED VIEW combined_repo_metrics AS
WITH all_repos AS (
    -- Gather unique repo_ids from every source table using UNION ALL for performance,
    -- then remove duplicates with DISTINCT.
    SELECT DISTINCT repo_id FROM (
        SELECT repo_id FROM lizard_summary
        UNION ALL
        SELECT repo_id FROM cloc_metrics
        UNION ALL
        SELECT repo_id FROM checkov_summary
        UNION ALL
        SELECT repo_id FROM trivy_vulnerability
        UNION ALL
        SELECT repo_id FROM semgrep_results
        UNION ALL
        SELECT repo_id FROM repo_metrics
        UNION ALL
        SELECT repo_id FROM go_enry_analysis
        UNION ALL
        SELECT repo_id FROM bitbucket_repositories
    ) subquery
),

cloc_agg AS (
    SELECT
        repo_id,
        SUM(files) AS source_code_file_count,
        SUM(blank) AS total_blank,
        SUM(comment) AS total_comment,
        SUM(code) AS total_lines_of_code
    FROM cloc_metrics
    WHERE language != 'SUM'
    GROUP BY repo_id
),

checkov_agg AS (
    SELECT
        repo_id,
        MAX(CASE WHEN check_type = 'ansible' THEN 1 ELSE 0 END)             AS iac_ansible,
        MAX(CASE WHEN check_type = 'azure_pipelines' THEN 1 ELSE 0 END)     AS iac_azure_pipelines,
        MAX(CASE WHEN check_type = 'bitbucket_pipelines' THEN 1 ELSE 0 END) AS iac_bitbucket_pipelines,
        MAX(CASE WHEN check_type = 'circleci_pipelines' THEN 1 ELSE 0 END)  AS iac_circleci_pipelines,
        MAX(CASE WHEN check_type = 'cloudformation' THEN 1 ELSE 0 END)      AS iac_cloudformation,
        MAX(CASE WHEN check_type = 'dockerfile' THEN 1 ELSE 0 END)          AS iac_dockerfile,
        MAX(CASE WHEN check_type = 'github_actions' THEN 1 ELSE 0 END)      AS iac_github_actions,
        MAX(CASE WHEN check_type = 'gitlab_ci' THEN 1 ELSE 0 END)           AS iac_gitlab_ci,
        MAX(CASE WHEN check_type = 'kubernetes' THEN 1 ELSE 0 END)          AS iac_kubernetes,
        MAX(CASE WHEN check_type = 'no-checks' THEN 1 ELSE 0 END)           AS iac_no_checks,
        MAX(CASE WHEN check_type = 'openapi' THEN 1 ELSE 0 END)             AS iac_openapi,
        MAX(CASE WHEN check_type = 'secrets' THEN 1 ELSE 0 END)             AS iac_secrets,
        MAX(CASE WHEN check_type = 'terraform' THEN 1 ELSE 0 END)           AS iac_terraform,
        MAX(CASE WHEN check_type = 'terraform_plan' THEN 1 ELSE 0 END)      AS iac_terraform_plan
    FROM checkov_summary
    GROUP BY repo_id
),

trivy_agg AS (
    SELECT
        repo_id,
        COUNT(*) AS total_trivy_vulns,
        COUNT(*) FILTER (WHERE severity = 'CRITICAL') AS trivy_critical,
        COUNT(*) FILTER (WHERE severity = 'HIGH')     AS trivy_high,
        COUNT(*) FILTER (WHERE severity = 'MEDIUM')   AS trivy_medium,
        COUNT(*) FILTER (WHERE severity = 'LOW')      AS trivy_low
    FROM trivy_vulnerability
    GROUP BY repo_id
),

semgrep_agg AS (
    SELECT
        repo_id,
        COUNT(*) AS total_semgrep_findings,
        COUNT(*) FILTER (WHERE category = 'best-practice')   AS cat_best_practice,
        COUNT(*) FILTER (WHERE category = 'compatibility')   AS cat_compatibility,
        COUNT(*) FILTER (WHERE category = 'correctness')     AS cat_correctness,
        COUNT(*) FILTER (WHERE category = 'maintainability') AS cat_maintainability,
        COUNT(*) FILTER (WHERE category = 'performance')     AS cat_performance,
        COUNT(*) FILTER (WHERE category = 'portability')     AS cat_portability,
        COUNT(*) FILTER (WHERE category = 'security')        AS cat_security
    FROM semgrep_results
    GROUP BY repo_id
),

go_enry_agg AS (
    SELECT
        g.repo_id,
        COUNT(*) AS language_count,
        (
            SELECT x.language
            FROM go_enry_analysis x
            WHERE x.repo_id = g.repo_id
            ORDER BY x.percent_usage DESC, x.language
            LIMIT 1
        ) AS main_language
    FROM go_enry_analysis g
    GROUP BY g.repo_id
),

all_languages_agg AS (
    SELECT
        repo_id,
        STRING_AGG(language, ', ' ORDER BY language) AS all_languages
    FROM go_enry_analysis
    GROUP BY repo_id
),

business_app_agg AS (
    SELECT
        rbm.project_key,
        rbm.repo_slug,
        rbm.component_id,
        vcm_ba.web_url,
        STRING_AGG(DISTINCT bam.business_app_identifier, ', ' ORDER BY bam.business_app_identifier) AS business_app_identifiers,
        bam.transaction_cycle
    FROM repo_business_mapping rbm
    JOIN business_app_mapping bam ON rbm.component_id = bam.component_id
    -- For business_app_agg we join version_control_mapping to get web_url (alias as vcm_ba)
    JOIN version_control_mapping vcm_ba ON lower(rbm.project_key) = lower(vcm_ba.project_key)
                                       AND lower(rbm.repo_slug) = lower(vcm_ba.repo_slug)
    GROUP BY rbm.project_key, rbm.repo_slug, rbm.component_id, vcm_ba.web_url, bam.transaction_cycle
)

SELECT
    -- Repository identifier
    r.repo_id,

    -- Bitbucket and Business App fields
    b.host_name,
    b.project_key,
    b.repo_slug,
    bapp.component_id,
    bapp.business_app_identifiers AS app_id,
    bapp.transaction_cycle AS tc,
    vcm.web_url,  -- from version_control_mapping join (see below)
    b.clone_url_ssh,
    b.status,
    b.comment,

    -- Lizard fields
    l.total_nloc                    AS executable_lines_of_code,
    l.avg_ccn                       AS avg_cyclomatic_complexity,
    l.total_token_count,
    l.function_count,
    l.total_ccn                     AS total_cyclomatic_complexity,

    -- CLOC fields
    c.source_code_file_count,
    c.total_blank,
    c.total_comment,
    c.total_lines_of_code,

    -- Checkov fields
    ck.iac_ansible,
    ck.iac_azure_pipelines,
    ck.iac_bitbucket_pipelines,
    ck.iac_circleci_pipelines,
    ck.iac_cloudformation,
    ck.iac_dockerfile,
    ck.iac_github_actions,
    ck.iac_gitlab_ci,
    ck.iac_kubernetes,
    ck.iac_no_checks,
    ck.iac_openapi,
    ck.iac_secrets,
    ck.iac_terraform,
    ck.iac_terraform_plan,

    -- Trivy fields
    t.total_trivy_vulns,
    t.trivy_critical,
    t.trivy_high,
    t.trivy_medium,
    t.trivy_low,

    -- Semgrep fields
    s.total_semgrep_findings,
    s.cat_best_practice,
    s.cat_compatibility,
    s.cat_correctness,
    s.cat_maintainability,
    s.cat_performance,
    s.cat_portability,
    s.cat_security,

    -- go-enry fields
    e.language_count,
    e.main_language,
    al.all_languages,

    -- repo_metrics fields
    rm.repo_size_bytes,
    rm.file_count,
    rm.total_commits,
    rm.number_of_contributors,
    rm.activity_status,
    rm.last_commit_date,
    rm.repo_age_days,
    rm.active_branch_count,
    rm.updated_at,

    -- Classification label (based on repo_metrics and cloc fields)
    CASE
        WHEN c.total_lines_of_code IS NULL OR c.total_lines_of_code < 100
            THEN CASE
                WHEN rm.repo_size_bytes < 1000000 OR rm.repo_size_bytes IS NULL THEN 'Non-Code -> Empty/Minimal'
                ELSE 'Non-Code -> Docs/Data'
            END
        ELSE CASE
            WHEN rm.repo_size_bytes < 1000000 OR rm.repo_size_bytes IS NULL THEN 'Code -> Tiny'
            WHEN rm.repo_size_bytes < 10000000 THEN 'Code -> Small'
            WHEN rm.repo_size_bytes < 100000000 THEN 'Code -> Medium'
            WHEN rm.repo_size_bytes < 1000000000 THEN 'Code -> Large'
            ELSE 'Code -> Massive'
        END
    END AS classification_label
FROM all_repos r
    LEFT JOIN lizard_summary l ON r.repo_id = l.repo_id
    LEFT JOIN cloc_agg c ON r.repo_id = c.repo_id
    LEFT JOIN checkov_agg ck ON r.repo_id = ck.repo_id
    LEFT JOIN trivy_agg t ON r.repo_id = t.repo_id
    LEFT JOIN semgrep_agg s ON r.repo_id = s.repo_id
    LEFT JOIN go_enry_agg e ON r.repo_id = e.repo_id
    LEFT JOIN all_languages_agg al ON r.repo_id = al.repo_id
    LEFT JOIN repo_metrics rm ON r.repo_id = rm.repo_id
    LEFT JOIN bitbucket_repositories b ON r.repo_id = b.repo_id
    LEFT JOIN business_app_agg bapp ON lower(b.project_key) = lower(bapp.project_key)
                                   AND lower(b.repo_slug) = lower(bapp.repo_slug)
    LEFT JOIN version_control_mapping vcm ON lower(b.project_key) = lower(vcm.project_key)
                                         AND lower(b.repo_slug) = lower(vcm.repo_slug)
ORDER BY r.repo_id;

-- Create indexes on the materialized view for efficient UI filtering.
-- (These indexes are created after the view is built.)
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_host_name ON combined_repo_metrics (host_name);
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_activity_status ON combined_repo_metrics (activity_status);
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_tc ON combined_repo_metrics (tc);
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_main_language ON combined_repo_metrics (main_language);
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_classification_label ON combined_repo_metrics (classification_label);
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_app_id ON combined_repo_metrics (app_id);

-- Add GIN indexes for text search (using pg_trgm)
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_main_language_gin 
    ON combined_repo_metrics USING GIN (main_language gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_classification_label_gin 
    ON combined_repo_metrics USING GIN (classification_label gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_app_id_gin 
    ON combined_repo_metrics USING GIN (app_id gin_trgm_ops);

-- Create a unique index on repo_id for fast concurrent refreshes.
CREATE UNIQUE INDEX IF NOT EXISTS idx_combined_repo_metrics_repo_id ON combined_repo_metrics(repo_id);

-- Refresh the materialized view concurrently.
REFRESH MATERIALIZED VIEW CONCURRENTLY combined_repo_metrics;