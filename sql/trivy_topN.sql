SELECT
    CASE
        WHEN resource_type = 'pom' THEN SPLIT_PART(pkg_name, ':', 1)
        ELSE pkg_name
        END AS product_name,
    resource_type,
    severity,
    COUNT(DISTINCT repo_id) AS repo_count
FROM trivy_vulnerability
WHERE pkg_name IS NOT NULL
GROUP BY
    CASE
        WHEN resource_type = 'pom' THEN SPLIT_PART(pkg_name, ':', 1)
        ELSE pkg_name
        END,
    resource_type,
    severity
ORDER BY repo_count DESC

