CASE
    WHEN TRY_CAST((
        SELECT MIN(
            CAST(regexp_replace(part, '^(\d+\.\d+)\.\d+$', '\1') AS numeric)
        )
        FROM unnest(
            regexp_matches(
                regexp_replace(runtime_version, '[\^~>=<!]', '', 'g'),
                '\d+\.\d+(?:\.\d+)?',
                'g'
            )
        ) AS part
    ) AS numeric) <= 3.6 THEN 'Python ≤ 3.6'

    WHEN TRY_CAST((
        SELECT MIN(
            CAST(regexp_replace(part, '^(\d+\.\d+)\.\d+$', '\1') AS numeric)
        )
        FROM unnest(
            regexp_matches(
                regexp_replace(runtime_version, '[\^~>=<!]', '', 'g'),
                '\d+\.\d+(?:\.\d+)?',
                'g'
            )
        ) AS part
    ) AS numeric) <= 3.8 THEN 'Python 3.7–3.8'

    WHEN TRY_CAST((
        SELECT MIN(
            CAST(regexp_replace(part, '^(\d+\.\d+)\.\d+$', '\1') AS numeric)
        )
        FROM unnest(
            regexp_matches(
                regexp_replace(runtime_version, '[\^~>=<!]', '', 'g'),
                '\d+\.\d+(?:\.\d+)?',
                'g'
            )
        ) AS part
    ) AS numeric) <= 3.10 THEN 'Python 3.9–3.10'

    WHEN TRY_CAST((
        SELECT MIN(
            CAST(regexp_replace(part, '^(\d+\.\d+)\.\d+$', '\1') AS numeric)
        )
        FROM unnest(
            regexp_matches(
                regexp_replace(runtime_version, '[\^~>=<!]', '', 'g'),
                '\d+\.\d+(?:\.\d+)?',
                'g'
            )
        ) AS part
    ) AS numeric) > 3.10 THEN 'Python ≥ 3.11'

    ELSE 'Unknown'
END
