CASE
    -- Case 1: '1.x' prefix (e.g., '1.8', '1.8.0_292') → extract x
    WHEN runtime_version LIKE '1.%' THEN split_part(runtime_version, '.', 2)::int::text

    -- Case 2: 'x.y.z' or 'x.y' with optional suffixes (e.g., '17.0.1+12') → extract x
    WHEN runtime_version ~ '^\d+\.\d+(\.\d+)?([+_a-zA-Z0-9-]*)?$' THEN split_part(runtime_version, '.', 1)::int::text

    -- Case 3: simple integer (e.g., '8', '11', '21') → return as is
    WHEN runtime_version ~ '^\d+$' THEN runtime_version

    -- Case 4: vendor-wrapped (e.g., 'jdk-17.0.1', 'zulu11.50.19-ca-jdk11.0.12') → extract first major version
    WHEN runtime_version ~ '.*(\d{1,2})\.\d+.*' THEN regexp_replace(runtime_version, '.*?(\d{1,2})\.\d+.*', '\1')

    -- Fallback: return original value
    ELSE runtime_version
END AS normalized_jdk_version
