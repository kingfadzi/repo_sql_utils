SELECT
    CASE WHEN resource_type = 'pom'
             THEN SPLIT_PART(pkg_name, ':', 1)
         ELSE pkg_name
        END AS product,
    resource_class,
    resource_type,
    COUNT(*) AS total_vulnerabilities,
    COUNT(DISTINCT repo_id) AS affected_repositories,
    COUNT(*) FILTER (WHERE severity = 'CRITICAL') AS critical_count,
        COUNT(DISTINCT repo_id) FILTER (WHERE severity = 'CRITICAL') AS critical_repos,
        COUNT(*) FILTER (WHERE severity = 'HIGH') AS high_count,
        COUNT(DISTINCT repo_id) FILTER (WHERE severity = 'HIGH') AS high_repos,
        COUNT(*) FILTER (WHERE severity = 'MEDIUM') AS medium_count,
        COUNT(DISTINCT repo_id) FILTER (WHERE severity = 'MEDIUM') AS medium_repos,
        COUNT(*) FILTER (WHERE severity = 'LOW') AS low_count,
        COUNT(DISTINCT repo_id) FILTER (WHERE severity = 'LOW') AS low_repos
FROM trivy_vulnerability
GROUP BY
    CASE WHEN resource_type = 'pom'
             THEN SPLIT_PART(pkg_name, ':', 1)
         ELSE pkg_name
        END,
    resource_class,
    resource_type
ORDER BY total_vulnerabilities DESC
    LIMIT 10;
