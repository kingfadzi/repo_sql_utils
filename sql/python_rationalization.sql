CASE
    -- Match and reduce X.Y.Z → X.Y
    WHEN runtime_version ~ '\d+\.\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\d+.*', '\1')

    -- Match and reduce X.Y.* or !=X.Y.* → X.Y
    WHEN runtime_version ~ '\d+\.\d+\.\*' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\*.*', '\1')

    -- Match first X.Y version in any string with separators (comma, space, |, etc.)
    WHEN runtime_version ~ '\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+).*', '\1')

    -- Match just major version → X.0 (e.g. ^3, >=3)
    WHEN runtime_version ~ '\D*(\d+)\D*$' THEN
        regexp_replace(runtime_version, '.*?(\d+)\D?.*', '\1.0')

    -- Fallback
    ELSE runtime_version
END
