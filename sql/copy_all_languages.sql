UPDATE harvested_repositories hr
SET all_languages = sub.languages
    FROM (
    SELECT
        ga.repo_id,
        STRING_AGG(ga.language, ', ' ORDER BY ga.percent_usage DESC) AS languages
    FROM go_enry_analysis ga
    WHERE ga.language IS NOT NULL AND ga.percent_usage IS NOT NULL
    GROUP BY ga.repo_id
) sub
WHERE hr.repo_id = sub.repo_id;