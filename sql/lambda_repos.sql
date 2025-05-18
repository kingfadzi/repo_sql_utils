SELECT
    h.project_key,
    COUNT(b.module_path) AS module_count
FROM
    public.harvested_repositories h
        LEFT JOIN
    public.build_config_cache b
    ON h.repo_id = b.repo_id
GROUP BY
    h.project_key
ORDER BY
    module_count DESC
    LIMIT 1;
