CASE
    -- 0. New: Match patterns like ">=3.10,<3.13"
    WHEN runtime_version ~ '>=\s*\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*>=\s*(\d+\.\d+).*', '\1')

    -- 0.1 New: Match versions like "3.10.*"
    WHEN runtime_version ~ '\d+\.\d+\.\*' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\*.*', '\1')

    -- 0.2 New: Match patterns like "^3.9|^3.10|^3.11"
    WHEN runtime_version ~ '\^?\d+\.\d+(?:\|\^?\d+\.\d+)*' THEN
        regexp_replace(runtime_version, '.*?\^?(\d+\.\d+).*', '\1')

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

    ELSE runtime_version  -- Return original value instead of NULL for debugging
END
