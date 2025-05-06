CASE
    -- Match X.Y.Z → reduce to X.Y (e.g. 3.10.9 → 3.10)
    WHEN runtime_version ~ '\d+\.\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\d+.*', '\1')

    -- Match X.Y.* or !=X.Y.* → reduce to X.Y (e.g. 3.10.* or !=3.10.* → 3.10)
    WHEN runtime_version ~ '\d+\.\d+\.\*' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)\.\*.*', '\1')

    -- Match multiple constraints like 3.10,<3.13 → extract first X.Y
    WHEN runtime_version ~ '\d+\.\d+.*[,|]' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+)[,|].*', '\1')

    -- Match X.Y alone
    WHEN runtime_version ~ '\d+\.\d+' THEN
        regexp_replace(runtime_version, '.*?(\d+\.\d+).*', '\1')

    -- Match just major version → X.0 (e.g. ^3 → 3.0)
    WHEN runtime_version ~ '\D*(\d+)\D*$' THEN
        regexp_replace(runtime_version, '.*?(\d+)\D?.*', '\1.0')

    -- Fallback: return raw
    ELSE runtime_version
END
