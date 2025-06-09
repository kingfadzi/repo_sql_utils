WITH product_info AS (
    SELECT
        repo_id,
        CASE
            WHEN resource_type = 'pom' THEN SPLIT_PART(pkg_name, ':', 1)
            ELSE pkg_name
            END AS product_name,
        resource_type,
        severity
    FROM trivy_vulnerability
    WHERE pkg_name IS NOT NULL
)
SELECT
    product_name,
    resource_type,
    severity,
    COUNT(DISTINCT repo_id) AS repo_count
FROM product_info
         JOIN harvested_repositories USING (repo_id)

GROUP BY product_name, resource_type, severity
ORDER BY repo_count DESC

