CASE
    -- Prefer >=X.Y or >=X.Y.Z, reduce to X.Y
    WHEN runtime_version ~ '>=\s*\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?>=\s*(\d+\.\d+)(?:\.\d+)?[^0-9]?.*', '\1')

    -- Handle range: >=3.10,<3.13 → extract first X.Y
    WHEN runtime_version ~ '>=\d+\.\d+,\s*<\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?>=\s*(\d+\.\d+).*', '\1')

    -- Handle wildcard: 3.10.* → return 3.10
    WHEN runtime_version ~ '\d+\.\d+\.\*' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\*.*', '\1')

    -- Handle caret ranges: ^3.9|^3.10|^3.11 → pick first match
    WHEN runtime_version ~ '\^\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?\^(\d+\.\d+).*', '\1')

    -- Match first full X.Y.Z → reduce to X.Y
    WHEN runtime_version ~ '\d+\.\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\d+.*', '\1')

    -- Match and isolate first X.Y (avoids comma/appending)
    WHEN runtime_version ~ '\d+\.\d+' THEN
        regexp_replace(runtime_version, '\D*(\d+\.\d+)\D?.*', '\1')

    -- Just major version → X.0
    WHEN runtime_version ~ '\m\d+\M' THEN
        regexp_replace(runtime_version, '.*?(\d+)\D.*', '\1.0')

    ELSE 'python_unspecified'
END
