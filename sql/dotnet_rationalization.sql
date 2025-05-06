CASE
    -- .NET 5+ unified platform: net5.0, net6.0, net7.0, etc.
    WHEN runtime_version ~ '^net[5-9]\d*(\.\d+)?$' THEN
        'NET ' || regexp_replace(runtime_version, '^net([5-9]\d*(\.\d+)?).*$', '\1')

    -- .NET Core (e.g., netcoreapp3.1)
    WHEN runtime_version ~ '^netcoreapp' THEN
        'NET Core ' || regexp_replace(runtime_version, '^netcoreapp(\d+(\.\d+)?).*$', '\1')

    -- .NET Framework (e.g., net48, net472)
    WHEN runtime_version ~ '^net4\d{1,2}$' THEN
        'NET Framework ' || regexp_replace(runtime_version, '^net(\d{2,3})$', '\1' || '.' || substr('\1', 2, 1))

    -- .NET Standard (e.g., netstandard2.0)
    WHEN runtime_version ~ '^netstandard' THEN
        'NET Standard ' || regexp_replace(runtime_version, '^netstandard(\d+(\.\d+)?).*$', '\1')

    -- Fallback: return original string
    ELSE runtime_version
END
