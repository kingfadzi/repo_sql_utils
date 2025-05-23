SELECT
    transaction_cycle,
    COUNT(*) AS total_repos
FROM
    harvested_repositories
GROUP BY
    transaction_cycle
ORDER BY
    total_repos DESC;
