WITH subcat_totals AS (
    SELECT
        sd.sub_category,
        COUNT(DISTINCT sd.repo_id) AS total_repo_count
    FROM syft_dependencies sd
             JOIN harvested_repositories hr ON sd.repo_id = hr.repo_id
    WHERE sd.sub_category IS NOT NULL AND sd.sub_category <> ''
    GROUP BY sd.sub_category
),
     top_subcategories AS (
         SELECT sub_category
         FROM subcat_totals
         ORDER BY total_repo_count DESC
    LIMIT 15
    )
SELECT
    sd.sub_category,
    sd.package_type,
    COUNT(DISTINCT sd.repo_id) AS repo_count
FROM syft_dependencies sd
         JOIN harvested_repositories hr ON sd.repo_id = hr.repo_id
         JOIN top_subcategories ts ON sd.sub_category = ts.sub_category
WHERE sd.package_type IS NOT NULL AND sd.package_type <> ''
GROUP BY sd.sub_category, sd.package_type
ORDER BY sd.sub_category, repo_count DESC;
