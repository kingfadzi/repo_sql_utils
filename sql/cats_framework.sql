SELECT
    repo_id,
    name,
    version,
    CASE

        WHEN version ~ '^3\.2\.' THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2016-12-31')) * 12 +
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2016-12-31'))
        WHEN version ~ '^3\.[01]\.' OR version < '3' THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2013-12-31')) * 12 +
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2013-12-31'))
        WHEN version ~ '^3\.[3-9]\.' THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2017-12-31')) * 12 +
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2017-12-31'))

        WHEN version ~ '^4\.' THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2020-12-31')) * 12 +
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2020-12-31'))

        WHEN version ~ '^5\.[01]\.' THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2020-12-31')) * 12 +
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2020-12-31'))

        WHEN version ~ '^5\.2\.' THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2021-12-31')) * 12 +
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2021-12-31'))

        WHEN version ~ '^5\.3\.' THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2023-06-30')) * 12 +
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2023-06-30'))

        WHEN version ~ '^6\.0\.' THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2024-06-30')) * 12 +
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2024-06-30'))

        WHEN version ~ '^6\.1\.' THEN
            CASE
                WHEN CURRENT_DATE > DATE '2025-06-30' THEN
                    EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2025-06-30')) * 12 +
                    EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2025-06-30'))
                ELSE
                    -1 * (EXTRACT(YEAR FROM AGE(DATE '2025-06-30', CURRENT_DATE)) * 12 +
                    EXTRACT(MONTH FROM AGE(DATE '2025-06-30', CURRENT_DATE)))
END

WHEN version ~ '^6\.2\.' THEN
            CASE
                WHEN CURRENT_DATE > DATE '2026-06-30' THEN
                    EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE '2026-06-30')) * 12 +
                    EXTRACT(MONTH FROM AGE(CURRENT_DATE, DATE '2026-06-30'))
                ELSE
                    -1 * (EXTRACT(YEAR FROM AGE(DATE '2026-06-30', CURRENT_DATE)) * 12 +
                    EXTRACT(MONTH FROM AGE(DATE '2026-06-30', CURRENT_DATE)))
END

ELSE NULL
END AS months_since_eol
FROM categorized_dependencies_mv
WHERE sub_category = 'Spring: Framework';

