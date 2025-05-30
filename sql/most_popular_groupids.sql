SELECT
    SPLIT_PART(package_name, ':', 1) AS group_id,
    COUNT(*) AS usage_count
FROM
    syft_dependencies
WHERE
    package_type = 'java-archive'
  AND package_name LIKE '%:%'
GROUP BY
    group_id
ORDER BY
    usage_count DESC
