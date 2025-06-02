-- Get top 15 subcategories by repository count
WITH top_subcategories AS (
    SELECT
        sub_category,
        COUNT(DISTINCT repo_id) AS repo_count
    FROM syft_dependencies
    WHERE
        sub_category IS NOT NULL
      AND sub_category <> ''
    GROUP BY sub_category
    ORDER BY repo_count DESC
    LIMIT 15
    )

-- Get framework usage within top subcategories
SELECT
    sd.sub_category,
    sd.framework,
    COUNT(DISTINCT sd.repo_id) AS repo_count
FROM syft_dependencies sd
WHERE
    sd.sub_category IN (SELECT sub_category FROM top_subcategories)
  AND sd.framework IS NOT NULL
  AND sd.framework <> ''
GROUP BY
    sd.sub_category,
    sd.framework
ORDER BY
    sd.sub_category,
    repo_count DESC;