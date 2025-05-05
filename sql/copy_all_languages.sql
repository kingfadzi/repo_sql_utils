UPDATE harvested_repositories r
SET all_languages = sub.all_languages
    FROM (
    SELECT
        repo_id,
        STRING_AGG(language, ', ' ORDER BY percent_usage DESC) AS all_languages
    FROM go_enry_analysis
    GROUP BY repo_id
) sub
WHERE r.repo_id = sub.repo_id;