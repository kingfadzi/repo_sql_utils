CASE
    -- Clean spaces around delimiters
    WHEN regexp_replace(runtime_version, '\s*(,|\|)\s*', '\1', 'g') ~ '>=\d+\.\d+' THEN
        regexp_replace(
            regexp_replace(runtime_version, '\s*(,|\|)\s*', '\1', 'g'),
            '.*>=\s*(\d+\.\d+).*',
            '\1'
        )

    WHEN regexp_replace(runtime_version, '\s*(,|\|)\s*', '\1', 'g') ~ '\d+\.\d+\.\*' THEN
        regexp_replace(
            regexp_replace(runtime_version, '\s*(,|\|)\s*', '\1', 'g'),
            '.*?(\d+\.\d+)\.\*.*',
            '\1'
        )

    WHEN regexp_replace(runtime_version, '\s*(,|\|)\s*', '\1', 'g') ~ '\^?\d+\.\d+(?:\|\^?\d+\.\d+)*' THEN
        regexp_replace(
            regexp_replace(runtime_version, '\s*(,|\|)\s*', '\1', 'g'),
            '.*?\^?(\d+\.\d+).*',
            '\1'
        )

    WHEN runtime_version ~ '>=\s*\d+\.\d+(\.\d+)?' THEN
        regexp_replace(runtime_version, '.*>=\s*(\d+\.\d+)(?:\.\d+)?[^0-9]?.*', '\1')

    WHEN runtime_version ~ '\d+\.\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\d+.*', '\1')

    WHEN runtime_version ~ '\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+).*', '\1')

    WHEN runtime_version ~ '\m\d+\M' THEN
        regexp_replace(runtime_version, '.*?\m(\d+)\M.*', '\1.0')

    ELSE runtime_version
END
