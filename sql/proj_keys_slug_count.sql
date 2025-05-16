SELECT
    project_key,
    COUNT(DISTINCT repo_slug) AS repo_count
FROM
    harvested_repositories
WHERE
    main_language IS NOT NULL
  AND activity_status = 'active'
GROUP BY
    project_key
ORDER BY
    repo_count DESC;
