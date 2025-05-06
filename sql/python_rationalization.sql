CASE
    -- Match and extract the first X.Y version (e.g., ^3.9, >=3.6,<3.9)
    WHEN runtime_version ~ '[\^~><=]*\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+).*', '\1')

    -- Match and convert standalone major version (e.g., ^3) to X.0
    WHEN runtime_version ~ '[\^~><=]*\d+\b' THEN
        regexp_replace(runtime_version, '.*?(\d+)\b.*', '\1.0')

    -- Fallback
    ELSE runtime_version
END
