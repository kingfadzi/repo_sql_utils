SELECT
    SPLIT_PART(name, ':', 1) AS group_id,
    SPLIT_PART(name, ':', 2) AS artifact_id,
    COUNT(*) AS total_occurrences
FROM categorized_dependencies_mv
WHERE package_type IN ('maven', 'gradle')
GROUP BY 1, 2
ORDER BY total_occurrences DESC;

---

SELECT
    SPLIT_PART(name, ':', 1) AS group_id,
    COUNT(*) AS total_occurrences
FROM categorized_dependencies_mv
WHERE package_type IN ('maven', 'gradle')
GROUP BY
    SPLIT_PART(name, ':', 1)
ORDER BY
    total_occurrences DESC;
----

SELECT
    SPLIT_PART(name, ':', 1) AS group_id,
    COUNT(DISTINCT repo_id) AS total_repos
FROM categorized_dependencies_mv
WHERE package_type IN ('maven', 'gradle')
GROUP BY group_id
ORDER BY total_repos DESC;

----

SELECT STRING_AGG(group_id, ',') AS nexus_group_ids
FROM (
         SELECT
             SPLIT_PART(name, ':', 1) AS group_id,
             COUNT(DISTINCT repo_id) AS total_repos
         FROM categorized_dependencies_mv
         WHERE package_type IN ('maven', 'gradle')
         GROUP BY group_id
         ORDER BY total_repos DESC
     ) AS ordered_groups;
