SELECT
    cr.repo_id,
    cr.main_language,
    cr.clone_url_ssh,
    cr.status,
    cr.web_url,
    cr.classification_label,
    cr.repo_size_bytes,
    cr.activity_status,
    COALESCE(bt.tool, 'None') AS build_tool,
    bt.runtime_version,
    COALESCE(dep_counts.dependency_count, 0) AS dependency_count
FROM combined_repo_metrics cr
         LEFT JOIN build_tools bt ON cr.repo_id = bt.repo_id
         LEFT JOIN (
    SELECT repo_id, COUNT(*) AS dependency_count
    FROM dependencies
    GROUP BY repo_id
) dep_counts ON cr.repo_id = dep_counts.repo_id;


----

SELECT
    combined_repo_metrics.repo_id,
    combined_repo_metrics.host_name,
    combined_repo_metrics.clone_url_ssh,
    combined_repo_metrics.status,
    combined_repo_metrics.web_url,
    combined_repo_metrics.main_language,
    combined_repo_metrics.repo_size_bytes,
    combined_repo_metrics.activity_status,
    combined_repo_metrics.classification_label,
    combined_repo_metrics.comment,
    cdmv.runtime_version,
    cdmv.tool_version,
    cdmv.tool,
    cdmv.sub_category,
    cdmv.category,
    cdmv.package_type,
    cdmv.version,
    cdmv.name
FROM combined_repo_metrics
         LEFT JOIN categorized_dependencies_mv AS cdmv
                   ON combined_repo_metrics.repo_id = cdmv.repo_id;


---

SELECT
    crm.repo_id,
    crm.host_name,
    crm.clone_url_ssh,
    crm.status,
    crm.web_url,
    crm.main_language,
    crm.repo_size_bytes,
    crm.activity_status,
    crm.classification_label,
    crm.comment,
    MIN(cdmv.runtime_version) AS runtime_version,
    MIN(cdmv.tool_version) AS tool_version,
    MIN(cdmv.tool) AS tool,
    MIN(cdmv.sub_category) AS sub_category,
    MIN(cdmv.category) AS category,
    MIN(cdmv.package_type) AS package_type,
    MIN(cdmv.version) AS version,
    MIN(cdmv.name) AS name
FROM combined_repo_metrics AS crm
         LEFT JOIN categorized_dependencies_mv AS cdmv
                   ON crm.repo_id = cdmv.repo_id
GROUP BY
    crm.repo_id,
    crm.host_name,
    crm.clone_url_ssh,
    crm.status,
    crm.web_url,
    crm.main_language,
    crm.repo_size_bytes,
    crm.activity_status,
    crm.classification_label,
    crm.comment;
