SELECT
    g.language,
    COUNT(DISTINCT g.repo_id) AS repo_count,
    AVG(c.code/NULLIF(c.files,0)) AS avg_code_per_file,
    AVG(c.comment/NULLIF(c.code,0)) AS avg_comment_ratio
FROM go_enry_analysis g
         JOIN cloc_metrics c USING (repo_id, language)
WHERE g.percent_usage > 30
GROUP BY g.language
HAVING AVG(c.code/NULLIF(c.files,0)) > 500
    OR AVG(c.comment/NULLIF(c.code,0)) < 0.1;

---

SELECT
    g.language,
    COUNT(DISTINCT g.repo_id) AS repo_count,
    AVG(c.code/NULLIF(c.files,0)) AS avg_code_per_file,
    AVG(c.blank/NULLIF(c.code,0)) AS avg_blank_ratio,  -- Replaces comment ratio
    AVG(c.files) AS avg_files_per_repo
FROM go_enry_analysis g
         JOIN cloc_metrics c USING (repo_id, language)
WHERE g.percent_usage > 30
GROUP BY g.language
HAVING AVG(c.code/NULLIF(c.files,0)) > 500
    OR AVG(c.blank/NULLIF(c.code,0)) < 0.08;  -- New threshold

---
SELECT
    ga.language,
    -- Core metrics
    ROUND(AVG(ga.percent_usage)::numeric, 2) AS avg_percent_usage,
    COUNT(DISTINCT ga.repo_id) AS repo_count,
    -- Dominance metric
    SUM(CASE WHEN ga.percent_usage = primary_langs.max_usage THEN 1 ELSE 0 END) AS primary_language_count,
    -- Code structure
    ROUND(AVG(c.code/NULLIF(c.files,0))::numeric, 1) AS avg_code_per_file
FROM go_enry_analysis ga
         JOIN harvested_repositories hr ON ga.repo_id = hr.repo_id
         JOIN languages l ON ga.language = l.name
         JOIN cloc_metrics c ON ga.repo_id = c.repo_id AND ga.language = c.language
-- Subquery to identify primary languages per repo
         JOIN (
    SELECT
        repo_id,
        MAX(percent_usage) AS max_usage
    FROM go_enry_analysis
    GROUP BY repo_id
) primary_langs ON ga.repo_id = primary_langs.repo_id
WHERE l.type = 'programming'
  AND ga.percent_usage > 0
  AND ga.percent_usage <> 'NaN'

GROUP BY ga.language
HAVING COUNT(DISTINCT ga.repo_id) > 5  -- Filter outlier languages
ORDER BY
    (COUNT(DISTINCT ga.repo_id) * AVG(ga.percent_usage)) DESC,  -- Composite score
    avg_code_per_file DESC;
