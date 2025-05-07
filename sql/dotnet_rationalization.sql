CASE
    -- .NET 5+ unified (net5+, net6.0, netcoreapp6.0, etc.)
    WHEN runtime_version ~ '(^|;)?net(coreapp)?0?[5-9](\.\d+)?' THEN
        'NET ' || regexp_replace(runtime_version, '.*net(?:coreapp)?0?([5-9]).*', '\1')

    -- .NET Core (1.x–3.x)
    WHEN runtime_version ~ 'netcoreapp3\.' THEN 'NET Core 3.x'
    WHEN runtime_version ~ 'netcoreapp2\.' THEN 'NET Core 2.x'
    WHEN runtime_version ~ 'netcoreapp1\.' THEN 'NET Core 1.x'

    -- .NET Standard
    WHEN runtime_version ~ 'netstandard2\.1' THEN 'NET Core 3.x'
    WHEN runtime_version ~ 'netstandard2\.0' THEN 'NET Core 2.x'
    WHEN runtime_version ~ 'netstandard1\.' THEN 'NET Core 1.x'

    -- .NET Framework (net4.x, net4.x.y)
    WHEN runtime_version ~ 'net4\.(\d+)(\.\d+)?' THEN 'NET Framework'
    WHEN runtime_version ~ 'net4\d{2}' THEN 'NET Framework'

    -- Fallback
    ELSE runtime_version
END
