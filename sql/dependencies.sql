SELECT cr.repo_id, cr.main_language, COUNT(d.repo_id) AS dependency_count
FROM combined_repo_metrics cr
         LEFT JOIN dependencies d ON cr.repo_id = d.repo_id
GROUP BY cr.repo_id, cr.main_language;


SELECT
    cr.repo_id,
    cr.main_language,
    COALESCE(bt.tool, 'None') AS build_tool
FROM combined_repo_metrics cr
         LEFT JOIN build_tools bt ON cr.repo_id = bt.repo_id;



