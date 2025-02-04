-- Enable pg_trgm extension for GIN indexes
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Drop the materialized view along with any dependencies
DROP MATERIALIZED VIEW IF EXISTS combined_repo_metrics CASCADE;

-- Ensure indexes exist to speed up joins and aggregations
CREATE INDEX IF NOT EXISTS idx_lizard_summary_repo_id ON lizard_summary(repo_id);
CREATE INDEX IF NOT EXISTS idx_cloc_metrics_repo_id ON cloc_metrics(repo_id);
CREATE INDEX IF NOT EXISTS idx_checkov_summary_repo_id ON checkov_summary(repo_id);
CREATE INDEX IF NOT EXISTS idx_trivy_vulnerability_repo_id ON trivy_vulnerability(repo_id);
CREATE INDEX IF NOT EXISTS idx_semgrep_results_repo_id ON semgrep_results(repo_id);
CREATE INDEX IF NOT EXISTS idx_repo_metrics_repo_id ON repo_metrics(repo_id);
CREATE INDEX IF NOT EXISTS idx_go_enry_analysis_repo_id ON go_enry_analysis(repo_id);
CREATE INDEX IF NOT EXISTS idx_bitbucket_repositories_repo_id ON bitbucket_repositories(repo_id);

-- Ensure functional index for case-insensitive joins
CREATE INDEX IF NOT EXISTS idx_version_control_mapping_lower 
ON version_control_mapping (LOWER(project_key), LOWER(repo_slug));

-- Ensure indexes on UI filter fields
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_host_name ON combined_repo_metrics (host_name);
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_activity_status ON combined_repo_metrics (activity_status);
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_tc ON combined_repo_metrics (tc);
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_main_language ON combined_repo_metrics (main_language);
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_classification_label ON combined_repo_metrics (classification_label);
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_app_id ON combined_repo_metrics (app_id);

-- Add GIN indexes for text search fields
CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_main_language_gin 
ON combined_repo_metrics USING GIN (main_language gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_classification_label_gin 
ON combined_repo_metrics USING GIN (classification_label gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_combined_repo_metrics_app_id_gin 
ON combined_repo_metrics USING GIN (app_id gin_trgm_ops);

-- Create the optimized materialized view
CREATE MATERIALIZED VIEW combined_repo_metrics AS
WITH all_repos AS (
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
        MAX(CASE WHEN check_type = 'ansible' THEN 1 ELSE 0 END) AS iac_ansible,
        MAX(CASE WHEN check_type = 'terraform' THEN 1 ELSE 0 END) AS iac_terraform
    FROM checkov_summary
    GROUP BY repo_id
),

trivy_agg AS (
    SELECT
        repo_id,
        COUNT(*) AS total_trivy_vulns,
        COUNT(*) FILTER (WHERE severity = 'CRITICAL') AS trivy_critical,
        COUNT(*) FILTER (WHERE severity = 'HIGH') AS trivy_high,
        COUNT(*) FILTER (WHERE severity = 'MEDIUM') AS trivy_medium,
        COUNT(*) FILTER (WHERE severity = 'LOW') AS trivy_low
    FROM trivy_vulnerability
    GROUP BY repo_id
),

semgrep_agg AS (
    SELECT
        repo_id,
        COUNT(*) AS total_semgrep_findings
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
        vcm.web_url,
        STRING_AGG(DISTINCT bam.business_app_identifier, ', ' ORDER BY bam.business_app_identifier) AS business_app_identifiers,
        bam.transaction_cycle
    FROM repo_business_mapping rbm
    JOIN business_app_mapping bam ON rbm.component_id = bam.component_id
    JOIN version_control_mapping vcm ON lower(rbm.project_key) = lower(vcm.project_key)
                                     AND lower(rbm.repo_slug) = lower(vcm.repo_slug)
    GROUP BY rbm.project_key, rbm.repo_slug, rbm.component_id, vcm.web_url, bam.transaction_cycle
)

SELECT
    r.repo_id,
    b.host_name,
    b.project_key,
    b.repo_slug,
    bapp.component_id,
    bapp.business_app_identifiers as app_id,
    bapp.transaction_cycle as tc,
    vcm.web_url,
    b.clone_url_ssh,
    b.status,
    c.source_code_file_count,
    t.total_trivy_vulns,
    s.total_semgrep_findings,
    e.language_count,
    e.main_language,
    al.all_languages,
    rm.repo_size_bytes,
    rm.last_commit_date,
    ck.iac_ansible,
    ck.iac_terraform,
    rm.activity_status,
    -- Classification label logic remains unchanged
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
LEFT JOIN bitbucket_repositories b ON r.repo_id = b.repo_id
LEFT JOIN business_app_agg bapp ON lower(b.project_key) = lower(bapp.project_key)
                               AND lower(b.repo_slug) = lower(bapp.repo_slug)
LEFT JOIN version_control_mapping vcm ON lower(b.project_key) = lower(vcm.project_key)
                                     AND lower(b.repo_slug) = lower(vcm.repo_slug)
LEFT JOIN cloc_agg c ON r.repo_id = c.repo_id
LEFT JOIN checkov_agg ck ON r.repo_id = ck.repo_id
LEFT JOIN trivy_agg t ON r.repo_id = t.repo_id
LEFT JOIN semgrep_agg s ON r.repo_id = s.repo_id
LEFT JOIN go_enry_agg e ON r.repo_id = e.repo_id
LEFT JOIN all_languages_agg al ON r.repo_id = al.repo_id
LEFT JOIN repo_metrics rm ON r.repo_id = rm.repo_id
ORDER BY r.repo_id;

-- Ensure unique index for fast concurrent refresh
CREATE UNIQUE INDEX IF NOT EXISTS idx_combined_repo_metrics_repo_id ON combined_repo_metrics(repo_id);

-- Refresh using concurrent mode for faster updates
REFRESH MATERIALIZED VIEW CONCURRENTLY combined_repo_metrics;