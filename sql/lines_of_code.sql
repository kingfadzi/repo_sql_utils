WITH cleaned AS (
    SELECT
    language AS "Language",
    repo_id AS "Repository",
    COALESCE(NULLIF(REGEXP_REPLACE(files::TEXT, '[^0-9]', '', 'g'), ''), '0')::INT AS "File Count",
    COALESCE(NULLIF(REGEXP_REPLACE(blank::TEXT, '[^0-9]', '', 'g'), ''), '0')::INT AS "Blank Lines",
    COALESCE(NULLIF(REGEXP_REPLACE(comment::TEXT, '[^0-9]', '', 'g'), ''), '0')::INT AS "Comment Lines",
    COALESCE(NULLIF(REGEXP_REPLACE(code::TEXT, '[^0-9]', '', 'g'), ''), '0')::INT AS "Code Lines"
FROM cloc_metrics
WHERE LOWER(language) != 'sum'
    ),
    aggregated AS (
SELECT
    "Language",
    COUNT(DISTINCT "Repository") AS "Total Repositories",
    SUM("File Count") AS "Total Files",
    ROUND(AVG("File Count"::numeric), 2) AS "Avg Files per Repository",
    SUM("Code Lines") AS "Total Code Lines",
    ROUND(SUM("Code Lines"::numeric) / NULLIF(SUM("File Count"), 0), 2) AS "Avg Code per File",
    SUM("Comment Lines") AS "Total Comment Lines",
    SUM("Blank Lines") AS "Total Blank Lines",
    ROUND(SUM("Comment Lines"::numeric) / NULLIF(SUM("Code Lines"), 0), 4) AS "Comment to Code Ratio",
    ROUND(SUM("Blank Lines"::numeric) / NULLIF(SUM("Code Lines"), 0), 4) AS "Blank to Code Ratio"
FROM cleaned
GROUP BY "Language"
    )
SELECT *
FROM aggregated
ORDER BY "Total Code Lines" DESC;
