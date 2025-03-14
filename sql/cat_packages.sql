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
SELECT
    SPLIT_PART(SPLIT_PART(name, ':', 1), '.', 1) AS part1,
    SPLIT_PART(SPLIT_PART(name, ':', 1), '.', 2) AS part2,
    SPLIT_PART(SPLIT_PART(name, ':', 1), '.', 3) AS part3,
    COUNT(*) AS total_occurrences
FROM categorized_dependencies_mv
WHERE package_type IN ('maven', 'gradle')
GROUP BY part1, part2, part3
ORDER BY total_occurrences DESC;
