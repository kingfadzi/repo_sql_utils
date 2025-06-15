SELECT
    hr.main_language,
    l.type
FROM harvested_repositories hr
         LEFT JOIN languages l ON LOWER(hr.main_language) = LOWER(l.name)
WHERE NOT (
    l.type = 'programming'
        OR LOWER(hr.main_language) = 'no language'
        OR LOWER(l.type) IN ('markup', 'data')
    )
  AND hr.main_language IS NOT NULL
GROUP BY hr.main_language, l.type
ORDER BY COUNT(*) DESC;
