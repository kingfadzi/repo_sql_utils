CASE
    -- .NET 5+ unified (.NET 5+ and netcoreapp5+)
    WHEN runtime_version ~ '(^|;)\.?(net(coreapp)?0?([5-9])0?(\.\d+)?([-a-z0-9]*)?)' THEN
        'NET ' || regexp_replace(runtime_version, '.*(^|;)\.?(net(coreapp)?0?([5-9])).*', '\4')

    -- .NET Core (1.x–3.x)
    WHEN runtime_version ~ '(^|;)netcoreapp3\.' THEN 'NET Core 3.x'
    WHEN runtime_version ~ '(^|;)netcoreapp2\.' THEN 'NET Core 2.x'
    WHEN runtime_version ~ '(^|;)netcoreapp1\.' THEN 'NET Core 1.x'

    -- .NET Standard → inferred runtime support
    WHEN runtime_version ~ '(^|;)netstandard2\.1' THEN 'NET Core 3.x'
    WHEN runtime_version ~ '(^|;)netstandard2\.0' THEN 'NET Core 2.x'
    WHEN runtime_version ~ '(^|;)netstandard1\.' THEN 'NET Core 1.x'

    -- .NET Framework
    WHEN runtime_version ~ '(^|;)net4\d{1,2}' THEN 'NET Framework'

    -- Fallback
    ELSE runtime_version
END
