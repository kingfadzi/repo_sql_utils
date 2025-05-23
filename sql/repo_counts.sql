SELECT
    transaction_cycle,
    COUNT(*) AS total_repos
FROM
    harvested_repositories
WHERE
    activity_status = 'ACTIVE'
GROUP BY
    transaction_cycle
ORDER BY
    total_repos DESC;
