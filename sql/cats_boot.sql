

SELECT
    repo_id,
    name,
    version,
    CASE
        WHEN version ~ '^2\.(0|1|2|3|4|5|6)\..*' THEN
            ROUND(
                    EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2022-11-24'))
                        + (EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2022-11-24')) * 12)
            )
        WHEN version ~ '^2\.7\..*' THEN
            ROUND(
                    EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2023-06-30'))
                        + (EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2023-06-30')) * 12)
            )
        WHEN version ~ '^3\.0\..*' THEN
            ROUND(
                    EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2023-12-31'))
                        + (EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2023-12-31')) * 12)
            )
        WHEN version ~ '^3\.1\..*' THEN
            ROUND(
                    EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2024-06-30'))
                        + (EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2024-06-30')) * 12)
            )
        WHEN version ~ '^3\.2\..*' THEN
            ROUND(
                    EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2024-12-31'))
                        + (EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2024-12-31')) * 12)
            )
        WHEN version ~ '^3\.3\..*' THEN
            ROUND(
                    EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2025-06-30'))
                        + (EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2025-06-30')) * 12)
            )
        WHEN version ~ '^3\.4\..*' THEN
            ROUND(
                    EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2025-12-31'))
                        + (EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2025-12-31')) * 12)
            )
        WHEN version ~ '^3\.5\..*' THEN
            ROUND(
                    EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2026-06-30'))
                        + (EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2026-06-30')) * 12)
            )
        ELSE NULL
        END AS months_since_eol
FROM
    categorized_dependencies_mv
WHERE
    sub_category = 'Spring: Boot';

