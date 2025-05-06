CASE
    -- .NET 5+ unified (handles: net6, net60, net6.0, .net6, net8.0-windows, net07.0)
    WHEN runtime_version ~ '(^|;)\.?(net0?([5-9])0?(\.\d+)?([-a-z0-9]*)?)' THEN
        'NET ' || regexp_replace(runtime_version, '.*(^|;)\.?(net0?([5-9])).*', '\3')

    -- .NET Core (e.g. netcoreapp3.1, netcoreapp2.0)
    WHEN runtime_version ~ '(^|;)netcoreapp3\.' THEN
        'NET Core 3.x'
    WHEN runtime_version ~ '(^|;)netcoreapp2\.' THEN
        'NET Core 2.x'
    WHEN runtime_version ~ '(^|;)netcoreapp1\.' THEN
        'NET Core 1.x'

    -- .NET Standard → inferred runtime support
    WHEN runtime_version ~ '(^|;)netstandard2\.1' THEN
        'NET Core 3.x'
    WHEN runtime_version ~ '(^|;)netstandard2\.0' THEN
        'NET Core 2.x'
    WHEN runtime_version ~ '(^|;)netstandard1\.' THEN
        'NET Core 1.x'

    -- .NET Framework (e.g. net472, net48)
    WHEN runtime_version ~ '(^|;)net4\d{1,2}' THEN
        'NET Framework'

    -- Fallback
    ELSE runtime_version
END
