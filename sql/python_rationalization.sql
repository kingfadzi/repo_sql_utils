CASE
    -- X.Y.Z → extract and reduce to X.Y
    WHEN runtime_version ~ '\d+\.\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\d+.*', '\1')

    -- X.Y.* → reduce to X.Y
    WHEN runtime_version ~ '\d+\.\d+\.\*' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\*.*', '\1')

    -- First X.Y anywhere (e.g. "3.10, <3.13" → "3.10")
    WHEN runtime_version ~ '\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+).*', '\1')

    -- Just major version (e.g. ^3 → 3.0)
    WHEN runtime_version ~ '\D*(\d+)\D*$' THEN
        regexp_replace(runtime_version, '.*?(\d+)\D?.*', '\1.0')

    -- Fallback
    ELSE runtime_version
END
