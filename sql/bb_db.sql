-- Table for projects
CREATE TABLE bitbucket_projects (
    project_key TEXT PRIMARY KEY,
    project_name TEXT NOT NULL,
    description TEXT,
    is_private BOOLEAN,
    created_on TIMESTAMP,
    updated_on TIMESTAMP
);

-- Table for repositories
CREATE TABLE bitbucket_repositories (
    repo_id VARCHAR PRIMARY KEY,
    repo_name VARCHAR NOT NULL,
    repo_slug VARCHAR NOT NULL,
    project_key VARCHAR NOT NULL,
    clone_url_ssh VARCHAR,
    browse VARCHAR,
    host_name VARCHAR,
    app_id VARCHAR,
    tc_cluster VARCHAR,
    tc VARCHAR,
    status VARCHAR,
    comment VARCHAR,
    updated_on TIMESTAMP
);

CREATE TABLE go_enry_analysis (
    id SERIAL PRIMARY KEY,
    repo_id VARCHAR NOT NULL,
    language VARCHAR NOT NULL,
    percent_usage FLOAT NOT NULL,
    analysis_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (repo_id, language)
);

CREATE TABLE repo_metrics (
      repo_id VARCHAR PRIMARY KEY,
      repo_size_bytes FLOAT NOT NULL,
      file_count INTEGER NOT NULL,
      total_commits INTEGER NOT NULL,
      number_of_contributors INTEGER NOT NULL,
      activity_status VARCHAR,
      last_commit_date TIMESTAMP,
      repo_age_days INTEGER NOT NULL,
      active_branch_count INTEGER NOT NULL,
      top_contributor_commits INTEGER,
      commits_by_top_3_contributors INTEGER,
      recent_commit_dates TIMESTAMP[],
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE lizard_metrics (
    id SERIAL PRIMARY KEY,
    repo_id VARCHAR NOT NULL,
    file_name TEXT,  -- Updated
    function_name TEXT,
    long_name TEXT,
    nloc INTEGER,
    ccn INTEGER,
    token_count INTEGER,
    param INTEGER,
    function_length INTEGER,  -- Updated
    start_line INTEGER,  -- Updated
    end_line INTEGER,  -- Updated
    CONSTRAINT lizard_metrics_unique UNIQUE (repo_id, file_name, function_name)
);

-- Create cloc_metrics table
CREATE TABLE cloc_metrics (
    id SERIAL PRIMARY KEY,
    repo_id VARCHAR NOT NULL,
    language TEXT,
    files INTEGER,
    blank INTEGER,
    comment INTEGER,
    code INTEGER,
    CONSTRAINT cloc_metrics_unique UNIQUE (repo_id, language)
);

-- Create checkov_results table
CREATE TABLE checkov_results (
    id SERIAL PRIMARY KEY,                        -- Auto-incrementing primary key
    repo_id VARCHAR NOT NULL,                    -- Repository ID (foreign key, not enforced here)
    resource TEXT,                               -- The resource being checked (e.g., S3 bucket, IAM role)
    check_name TEXT,                             -- Name/description of the check
    check_result TEXT,                           -- Result of the check (e.g., PASSED, FAILED)
    severity TEXT,                               -- Severity of the issue (e.g., LOW, MEDIUM, HIGH)
    file_path TEXT,                              -- Path to the file containing the resource
    line_range TEXT,                             -- Range of lines in the file affected by the issue
    CONSTRAINT checkov_results_unique UNIQUE (repo_id, resource, check_name)  -- Ensure no duplicates for the same check
);

CREATE TABLE lizard_summary (
    repo_id VARCHAR PRIMARY KEY,  -- repo_id as the primary key
    total_nloc INTEGER,
    avg_ccn FLOAT,
    total_token_count INTEGER,
    function_count INTEGER,
    total_ccn INTEGER
);

CREATE TABLE checkov_sarif_results (
    id SERIAL PRIMARY KEY,
    repo_id VARCHAR NOT NULL,
    rule_id TEXT NOT NULL,
    rule_name TEXT,
    severity TEXT,
    file_path TEXT,
    start_line INTEGER,
    end_line INTEGER,
    message TEXT,
    CONSTRAINT checkov_sarif_results_unique UNIQUE (repo_id, rule_id, file_path, start_line, end_line)
);

CREATE TABLE dependency_check_results (
    id SERIAL PRIMARY KEY,
    repo_id VARCHAR(255) NOT NULL,
    cve VARCHAR(255) NOT NULL,
    description TEXT,
    severity VARCHAR(50),
    vulnerable_software JSONB,
    CONSTRAINT dependency_check_results_uc UNIQUE (repo_id, cve)
);

CREATE TABLE grype_results (
    id SERIAL PRIMARY KEY,
    repo_id VARCHAR NOT NULL,
    cve VARCHAR NOT NULL,
    description TEXT,
    severity VARCHAR NOT NULL,
    language VARCHAR NOT NULL,
    package VARCHAR NOT NULL,
    version VARCHAR NOT NULL,
    fix_versions TEXT,
    fix_state TEXT,
    file_path TEXT,
    cvss TEXT,
    CONSTRAINT grype_result_uc UNIQUE (repo_id, cve, package, version)
);

CREATE TABLE checkov_summary (
    id SERIAL PRIMARY KEY,
    repo_id TEXT NOT NULL,
    check_type TEXT NOT NULL,
    passed INTEGER DEFAULT 0,
    failed INTEGER DEFAULT 0,
    skipped INTEGER DEFAULT 0,
    resource_count INTEGER DEFAULT 0,
    parsing_errors INTEGER DEFAULT 0,
    CONSTRAINT uq_repo_check UNIQUE (repo_id, check_type)
);

CREATE TABLE checkov_files (
    id SERIAL PRIMARY KEY,
    repo_id VARCHAR NOT NULL,
    check_type VARCHAR NOT NULL,
    file_path VARCHAR NOT NULL,
    file_abs_path VARCHAR,
    resource_count INTEGER DEFAULT 0 NOT NULL,
    UNIQUE (repo_id, check_type, file_path)
);

CREATE TABLE checkov_checks (
    id SERIAL PRIMARY KEY,
    repo_id TEXT NOT NULL,
    file_path TEXT NOT NULL,
    check_type TEXT NOT NULL,
    check_id TEXT NOT NULL,
    check_name TEXT,
    result TEXT,
    severity TEXT,
    resource TEXT,
    guideline TEXT,
    start_line INTEGER,
    end_line INTEGER,
    CONSTRAINT uq_repo_check_id UNIQUE (repo_id, file_path, check_type, check_id)
);

CREATE TABLE trivy_vulnerability (
    id SERIAL PRIMARY KEY,
    repo_id VARCHAR NOT NULL,
    target VARCHAR NOT NULL,
    resource_class VARCHAR,  -- e.g., config, lang-pkgs
    resource_type VARCHAR,   -- e.g., dockerfile, terraform
    vulnerability_id VARCHAR NOT NULL,
    pkg_name VARCHAR,
    installed_version VARCHAR,
    fixed_version VARCHAR,
    severity VARCHAR NOT NULL,
    primary_url VARCHAR,
    description TEXT,
    CONSTRAINT uq_repo_vuln_pkg UNIQUE (repo_id, vulnerability_id, pkg_name)
);

CREATE TABLE analysis_execution_log (
    id SERIAL PRIMARY KEY,
    method_name VARCHAR NOT NULL,
    stage VARCHAR,
    run_id VARCHAR,
    repo_id VARCHAR,
    status VARCHAR NOT NULL,
    message TEXT,
    execution_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    duration FLOAT NOT NULL
);

CREATE INDEX idx_analysis_log_method_name ON analysis_execution_log (method_name);
CREATE INDEX idx_analysis_log_stage      ON analysis_execution_log (stage);
CREATE INDEX idx_analysis_log_run_id     ON analysis_execution_log (run_id);
CREATE INDEX idx_analysis_log_repo_id    ON analysis_execution_log (repo_id);
CREATE INDEX idx_analysis_log_status     ON analysis_execution_log (status);


CREATE TABLE semgrep_results (
     id SERIAL PRIMARY KEY,
     repo_id VARCHAR NOT NULL,
     path VARCHAR NOT NULL,
     start_line INT NOT NULL,
     end_line INT NOT NULL,
     rule_id VARCHAR NOT NULL,
     severity VARCHAR NOT NULL,
     message TEXT,
     category VARCHAR,
     subcategory TEXT,
     technology VARCHAR,
     cwe TEXT,
     likelihood VARCHAR,
     impact VARCHAR,
     confidence VARCHAR,
     UNIQUE (repo_id, path, start_line, rule_id)
);
CREATE TABLE component_mapping (
   id SERIAL PRIMARY KEY,
   component_id   INTEGER,
   component_name VARCHAR,
   tc            VARCHAR,
   mapping_type   VARCHAR,
   instance_url   VARCHAR,
   tool_type      VARCHAR,
   name           VARCHAR,
   identifier     VARCHAR,
   web_url        VARCHAR,
   project_key    VARCHAR,
   repo_slug      VARCHAR
);

DROP TABLE IF EXISTS business_app_mapping;

CREATE TABLE business_app_mapping (
  id SERIAL PRIMARY KEY,
  component_id INTEGER NOT NULL,
  transaction_cycle VARCHAR NOT NULL,
  component_name VARCHAR NOT NULL,
  business_app_identifier VARCHAR NOT NULL
);

DROP TABLE IF EXISTS version_control_mapping;

CREATE TABLE version_control_mapping (
 id SERIAL PRIMARY KEY,
 component_id INTEGER NOT NULL,
 project_key VARCHAR NOT NULL,
 repo_slug VARCHAR NOT NULL,
 web_url VARCHAR
);

DROP TABLE IF EXISTS repo_business_mapping;

CREATE TABLE repo_business_mapping (
   id SERIAL PRIMARY KEY,
   component_id INTEGER NOT NULL,
   project_key VARCHAR NOT NULL,
   repo_slug VARCHAR NOT NULL,
   business_app_identifier VARCHAR NOT NULL
);

CREATE TABLE kantra_rulesets (
    name TEXT PRIMARY KEY,
    description TEXT
);

CREATE TABLE kantra_violations (
    id SERIAL PRIMARY KEY,
    ruleset_name TEXT NOT NULL,
    rule_name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    effort INTEGER,
    repo_id TEXT NOT NULL,
    UNIQUE (repo_id, ruleset_name, rule_name, description)
);

CREATE TABLE kantra_labels (
    id SERIAL PRIMARY KEY,
    key TEXT NOT NULL,
    value TEXT NOT NULL,
    UNIQUE (key, value)
);

CREATE TABLE kantra_violation_labels (
     violation_id INT NOT NULL,
     label_id INT NOT NULL,
     PRIMARY KEY (violation_id, label_id)
);

CREATE TABLE dependencies (
      id SERIAL PRIMARY KEY,
      repo_id VARCHAR NOT NULL,
      name VARCHAR NOT NULL,
      version VARCHAR NOT NULL,
      category VARCHAR,
      sub_category VARCHAR,
      package_type VARCHAR NOT NULL,
      CONSTRAINT uq_repo_name_version UNIQUE (repo_id, name, version)
);

CREATE TABLE xeol_results (
      id SERIAL PRIMARY KEY,
      repo_id VARCHAR NOT NULL,
      product_name VARCHAR,
      product_permalink VARCHAR,
      release_cycle VARCHAR,
      eol_date VARCHAR,
      latest_release VARCHAR,
      latest_release_date VARCHAR,
      release_date VARCHAR,
      artifact_name VARCHAR,
      artifact_version VARCHAR,
      artifact_type VARCHAR,
      file_path VARCHAR,
      language VARCHAR,
      CONSTRAINT _xeol_result_uc UNIQUE (repo_id, artifact_name, artifact_version)
);

CREATE TABLE IF NOT EXISTS build_tools (
   id SERIAL PRIMARY KEY,
   repo_id TEXT NOT NULL,
   module_path TEXT,
   tool TEXT NOT NULL,
   tool_version TEXT,
   runtime_version TEXT,
   extraction_method TEXT,
   confidence TEXT,
   detection_sources JSONB,
   status TEXT,
   error TEXT,
   created_at TIMESTAMPTZ DEFAULT now(),
   updated_at TIMESTAMPTZ,
   CONSTRAINT _build_tools_full_uc UNIQUE (
               repo_id, module_path, tool, tool_version, runtime_version
           )
    );

DROP MATERIALIZED VIEW IF EXISTS categorized_dependencies_mv;
CREATE MATERIALIZED VIEW categorized_dependencies_mv AS
SELECT
    repo_id,
    name,
    version,
    package_type,
    category,
    sub_category,
    tool,
    tool_version,
    runtime_version
FROM dependencies
LEFT JOIN build_tools USING (repo_id)
WITH NO DATA;

CREATE TABLE syft_dependencies (
    id VARCHAR PRIMARY KEY,
    repo_id VARCHAR NOT NULL,
    package_name VARCHAR NOT NULL,
    version VARCHAR NOT NULL,
    package_type VARCHAR NOT NULL,
    licenses TEXT,
    locations TEXT,
    language VARCHAR,
    category VARCHAR,
    sub_category VARCHAR,
    framework VARCHAR,
    CONSTRAINT uq_syft_dependencies_repo_package_version UNIQUE (repo_id, package_name, version)
);

CREATE TABLE repo_profile_cache (
   repo_id VARCHAR PRIMARY KEY,
   profile_json TEXT NOT NULL
);


CREATE TABLE iac_components (
    id SERIAL PRIMARY KEY,
    repo_id VARCHAR(255) NOT NULL,
    repo_slug VARCHAR(255) NOT NULL,
    repo_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(1024) NOT NULL,
    category VARCHAR(255) NOT NULL,
    subcategory VARCHAR(255) NOT NULL,
    framework VARCHAR(255) NOT NULL,
    scan_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE repo_catalog (
    repo_id VARCHAR PRIMARY KEY,
    source_code_file_count INT,
    total_blank INT,
    total_comment INT,
    total_lines_of_code INT,
    total_trivy_vulns INT,
    trivy_critical INT,
    trivy_high INT,
    trivy_medium INT,
    trivy_low INT,
    total_semgrep_findings INT,
    cat_best_practice INT,
    cat_compatibility INT,
    cat_correctness INT,
    cat_maintainability INT,
    cat_performance INT,
    cat_portability INT,
    cat_security INT,
    main_language VARCHAR,
    all_languages TEXT,
    classification_label VARCHAR,
    app_id VARCHAR,
    repo_size_bytes INT,
    component_id VARCHAR,
    component_name VARCHAR,
    web_url VARCHAR,
    transaction_cycle VARCHAR,

    -- From repo_metrics
    code_size_bytes DOUBLE PRECISION,
    file_count INTEGER,
    repo_age_days INTEGER,
    
    -- From lizard_summary
    lizard_total_nloc INTEGER,
    lizard_total_ccn INTEGER,
    
    -- From xeol_results
    xeol_eol_package_count INTEGER,
    xeol_earliest_eol_date TIMESTAMP,

        -- Application metadata fields
    business_application_name VARCHAR,
    tech_lead_group VARCHAR,
    correlation_id VARCHAR,
    active VARCHAR,
    owning_transaction_cycle VARCHAR,
    resilience_category VARCHAR,
    application_product_owner VARCHAR,
    application_product_owner_brid VARCHAR,
    system_architect VARCHAR,
    system_architect_brid VARCHAR,
    operational_status VARCHAR,
    application_type VARCHAR,
    architecture_type VARCHAR,
    install_type VARCHAR,
    application_tier VARCHAR,
    architecture_hosting VARCHAR,
    house_position VARCHAR,
    business_application_sys_id VARCHAR,
    short_description TEXT,
    chief_technology_officer VARCHAR,
    business_owner VARCHAR,
    business_owner_brid VARCHAR,

    -- from build_config_cache
    build_tool_version VARCHAR,
    runtime_version VARCHAR,

    -- from syft_dependencies
    dependency_count INTEGER,
    package_types VARCHAR,
    top_packages VARCHAR,

    -- from xeol_results
    eol_package_count INTEGER,
    earliest_eol_date TIMESTAMP,

    -- from iac_components
    iac_frameworks VARCHAR,

    -- from grype_results
    grype_total_vulns INTEGER,
    grype_fixable_vulns INTEGER,
    grype_critical_fixable INTEGER,
    grype_high_fixable INTEGER,
    grype_medium_fixable INTEGER,
    grype_low_fixable INTEGER


);



CREATE TABLE harvested_repositories (
    repo_id VARCHAR NOT NULL PRIMARY KEY,
    repo_name VARCHAR NOT NULL,
    project_key VARCHAR NOT NULL,
    repo_slug VARCHAR NOT NULL,
    clone_url_ssh VARCHAR,
    browse_url VARCHAR,
    updated_date TIMESTAMP WITHOUT TIME ZONE,
    last_harvested_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    app_id VARCHAR,
    host_name VARCHAR,
    component_id VARCHAR,
    component_name VARCHAR,
    transaction_cycle VARCHAR,
    main_language VARCHAR,
    all_languages VARCHAR,
    classification_label VARCHAR,
    activity_status VARCHAR,
    status VARCHAR,
    comment VARCHAR,
    scope VARCHAR
);

CREATE TABLE build_config_cache (
    id TEXT PRIMARY KEY,
    repo_id TEXT,
    run_id TEXT,
    browse_url TEXT,
    tool TEXT,
    variant TEXT,
    module_path TEXT,
    copied_files JSON NOT NULL,
    sbom_path TEXT,
    tool_version TEXT,
    runtime_version TEXT,
    confidence TEXT,
    detection_sources JSON,
    meta_data JSON,
    extraction_method TEXT,
    status TEXT,
    error TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    CONSTRAINT _build_config_cache_full_uc UNIQUE (
        repo_id,
        module_path,
        tool,
        variant,
        tool_version,
        runtime_version
        )
);

CREATE INDEX ix_build_config_cache_repo_id ON build_config_cache (repo_id);
