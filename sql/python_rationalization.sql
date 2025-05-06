CASE
    -- 1. Full X.Y.Z → extract and reduce to X.Y
    WHEN runtime_version ~ '\d+\.\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\d+.*', '\1')

    -- 2. X.Y → extract directly
    WHEN runtime_version ~ '\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+).*', '\1')

    -- 3. Major version only → convert to X.0
    WHEN runtime_version ~ '\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+)\b.*', '\1.0')

    -- 4. Fallback
    ELSE runtime_version
END
