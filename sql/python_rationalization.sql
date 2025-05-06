CASE
    -- Match the lowest X.Y version (first one in the string), including ^ or ~ prefixes
    WHEN runtime_version ~ '[\^~>=<]*\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+).*', '\1')

    -- Match standalone major versions (e.g. ^3) → convert to 3.0
    WHEN runtime_version ~ '[\^~>=<]*\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+).*', '\1.0')

    -- Fallback: return raw
    ELSE runtime_version
END
