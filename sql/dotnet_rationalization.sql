CASE
    -- Prefer netX (i.e. .NET 5+ unified)
    WHEN runtime_version ~ '(^|;)\.?(net[5-9]\d*(\.\d+)?([-a-z0-9]*)?)' THEN
        'NET ' || regexp_replace(runtime_version, '.*(^|;)\.?(net([5-9]\d*))(\.\d+)?([-a-z0-9]*)?.*', '\3')

    -- If netcoreapp, infer .NET Core
    WHEN runtime_version ~ '(^|;)netcoreapp(\d+(\.\d+)?)' THEN
        'NET Core ' || regexp_replace(runtime_version, '.*(^|;)netcoreapp(\d+(\.\d+)?).*', '\2')

    -- If netstandard2.1 → .NET Core 3.0+
    WHEN runtime_version ~ '(^|;)netstandard2\.1' THEN
        'NET Core 3.0+'

    -- If netstandard2.0 → .NET Core 2.0+
    WHEN runtime_version ~ '(^|;)netstandard2\.0' THEN
        'NET Core 2.0+'

    -- If netstandard1.x → .NET Core 1.x
    WHEN runtime_version ~ '(^|;)netstandard1\.' THEN
        'NET Core 1.x'

    -- If net4xx present → .NET Framework
    WHEN runtime_version ~ '(^|;)net4\d{1,2}' THEN
        'NET Framework'

    -- Otherwise: return raw
    ELSE runtime_version
END
