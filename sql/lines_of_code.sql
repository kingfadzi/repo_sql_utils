WITH cleaned AS (
  SELECT
    language AS "Language",
    repo_id AS "Repository",
    CAST(REPLACE(files::TEXT, ',', '') AS INTEGER) AS "File Count",
    CAST(REPLACE(blank::TEXT, ',', '') AS INTEGER) AS "Blank Lines",
    CAST(REPLACE(comment::TEXT, ',', '') AS INTEGER) AS "Comment Lines",
    CAST(REPLACE(code::TEXT, ',', '') AS INTEGER) AS "Code Lines"
  FROM cloc_metrics
  WHERE LOWER(language) != 'sum'
),
aggregated AS (
  SELECT
    "Language",
    COUNT(DISTINCT "Repository") AS "Total Repositories",
    SUM("File Count") AS "Total Files",
    ROUND(AVG("File Count"), 2) AS "Avg Files per Repository",
    SUM("Code Lines") AS "Total Code Lines",
    ROUND(SUM("Code Lines")::FLOAT / NULLIF(COUNT("Code Lines"), 0), 2) AS "Avg Code per File",
    SUM("Comment Lines") AS "Total Comment Lines",
    SUM("Blank Lines") AS "Total Blank Lines",
    ROUND(SUM("Comment Lines")::FLOAT / NULLIF(SUM("Code Lines"), 0), 4) AS "Comment to Code Ratio",
    ROUND(SUM("Blank Lines")::FLOAT / NULLIF(SUM("Code Lines"), 0), 4) AS "Blank to Code Ratio"
  FROM cleaned
  GROUP BY "Language"
)
SELECT * FROM aggregated
ORDER BY "Total Code Lines" DESC;