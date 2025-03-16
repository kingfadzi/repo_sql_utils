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
    COALESCE(dep_counts.dependency_count, 0) AS dependency_count
FROM combined_repo_metrics cr
         LEFT JOIN build_tools bt ON cr.repo_id = bt.repo_id
         LEFT JOIN (
    SELECT repo_id, COUNT(*) AS dependency_count
    FROM dependencies
    GROUP BY repo_id
) dep_counts ON cr.repo_id = dep_counts.repo_id;



