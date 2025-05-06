CASE
    -- 1. Prefer >=X.Y.Z or >=X.Y
    WHEN runtime_version ~ '>=\s*\d+\.\d+(\.\d+)?' THEN
        regexp_replace(runtime_version, '.*>=\s*(\d+\.\d+)(?:\.\d+)?[^0-9]?.*', '\1')

    -- 2. Fallback: first X.Y.Z → X.Y
    WHEN runtime_version ~ '\d+\.\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\d+.*', '\1')

    -- 3. Fallback: first X.Y (anywhere)
    WHEN runtime_version ~ '\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+).*', '\1')

    -- 4. Major version only → X.0
    WHEN runtime_version ~ '\m\d+\M' THEN
        regexp_replace(runtime_version, '.*?(\d+)\D.*', '\1.0')

    ELSE NULL
END
