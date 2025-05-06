CASE
    -- .NET 5+ unified platform: net5.0, net6.0, net7.0, etc.
    WHEN target_framework ~ '^net[5-9]\d*(\.\d+)?$' THEN
        'NET ' || regexp_replace(target_framework, '^net([5-9]\d*(\.\d+)?).*$', '\1')

    -- .NET Core (e.g., netcoreapp3.1)
    WHEN target_framework ~ '^netcoreapp' THEN
        'NET Core ' || regexp_replace(target_framework, '^netcoreapp(\d+(\.\d+)?).*$', '\1')

    -- .NET Framework (e.g., net48, net472)
    WHEN target_framework ~ '^net4\d{1,2}$' THEN
        'NET Framework ' || regexp_replace(target_framework, '^net(\d{2,3})$', '\1' || '.' || substr('\1', 2, 1))

    -- .NET Standard (e.g., netstandard2.0)
    WHEN target_framework ~ '^netstandard' THEN
        'NET Standard ' || regexp_replace(target_framework, '^netstandard(\d+(\.\d+)?).*$', '\1')

    -- Fallback: return original string
    ELSE target_framework
END AS normalized_dotnet_runtime
