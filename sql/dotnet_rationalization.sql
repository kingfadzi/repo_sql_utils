CASE
    -- .NET 5+ unified: net6.0, net60, net6.0-windows → NET 6
    WHEN runtime_version ~ '(^|;)\.?(net[5-9]\d{1,2}(\.\d+)?([-a-z0-9]*)?)' THEN
        'NET ' || regexp_replace(
            regexp_replace(runtime_version, '.*(^|;)\.?(net([5-9])0).*', '\3'),
            '.*(^|;)\.?(net([5-9]))(\.0)?([-a-z0-9]*)?.*', '\3'
        )

    -- .NET Core: netcoreapp3.1 → NET Core 3.1
    WHEN runtime_version ~ '(^|;)netcoreapp(\d+(\.\d+)?)' THEN
        'NET Core ' || regexp_replace(runtime_version, '.*(^|;)netcoreapp(\d+(\.\d+)?).*', '\2')

    -- .NET Standard 2.1 → .NET Core 3.0+
    WHEN runtime_version ~ '(^|;)netstandard2\.1' THEN
        'NET Core 3.0+'

    -- .NET Standard 2.0 → .NET Core 2.0+
    WHEN runtime_version ~ '(^|;)netstandard2\.0' THEN
        'NET Core 2.0+'

    -- .NET Standard 1.x → .NET Core 1.x
    WHEN runtime_version ~ '(^|;)netstandard1\.' THEN
        'NET Core 1.x'

    -- .NET Framework: net472, net48 → .NET Framework
    WHEN runtime_version ~ '(^|;)net4\d{1,2}' THEN
        'NET Framework'

    -- Fallback
    ELSE runtime_version
END
