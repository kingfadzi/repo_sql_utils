WITH dotnet_repos AS (
    SELECT DISTINCT repo_id
FROM build_config_cache
WHERE tool = 'dotnet'
),

repos_with_deps AS (
    SELECT DISTINCT repo_id
FROM syft_dependencies
)

SELECT hr.repo_id, hr.browse_url
FROM dotnet_repos dr
LEFT JOIN repos_with_deps rwd ON dr.repo_id = rwd.repo_id
JOIN harvested_repositories hr ON dr.repo_id = hr.repo_id
WHERE rwd.repo_id IS NULL
