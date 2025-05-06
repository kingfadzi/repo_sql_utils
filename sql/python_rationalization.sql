CASE
    -- Match and reduce full X.Y.Z to X.Y
    WHEN runtime_version ~ '\d+\.\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\d+.*', '\1')

    -- Match X.Y pattern
    WHEN runtime_version ~ '\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+).*', '\1')

    -- Match just X (standalone major version) → X.0
    WHEN runtime_version ~ '\m\d+\M' THEN
        regexp_replace(runtime_version, '.*?(\d+)\D.*', '\1.0')

    -- Fallback
    ELSE runtime_version
END
