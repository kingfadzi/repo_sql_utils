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
