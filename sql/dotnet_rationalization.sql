CASE
    -- .NET 5+ (e.g. net5, net5.0, net50, net60, net6.0, net8.0-windows, net07.0)
    WHEN runtime_version ~ '(^|;)net0?([5-9])0?(\.\d+)?([-a-z0-9]*)?' THEN
        'NET ' || regexp_replace(runtime_version, '.*(^|;)net0?([5-9])0?.*', '\2')

    -- .NET Core (e.g. netcoreapp3.1, netcoreapp2.0)
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

    -- .NET Framework (e.g. net472, net48)
    WHEN runtime_version ~ '(^|;)net4\d{1,2}' THEN
        'NET Framework'

    -- Fallback
    ELSE runtime_version
END
