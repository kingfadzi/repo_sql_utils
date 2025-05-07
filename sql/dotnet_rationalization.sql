CASE
    -- .NET 5+ unified (handles: net5, net6.0, netcoreapp6.0, etc.)
    WHEN runtime_version ~ '\bnet(coreapp)?0?([5-9])(\.\d+)?' THEN
        'NET ' || regexp_replace(runtime_version, '.*net(?:coreapp)?0?([5-9]).*', '\1')

    -- .NET Core (1.x–3.x)
    WHEN runtime_version ~ '\bnetcoreapp3\.' THEN 'NET Core 3.x'
    WHEN runtime_version ~ '\bnetcoreapp2\.' THEN 'NET Core 2.x'
    WHEN runtime_version ~ '\bnetcoreapp1\.' THEN 'NET Core 1.x'

    -- .NET Standard → inferred runtime support
    WHEN runtime_version ~ '\bnetstandard2\.1' THEN 'NET Core 3.x'
    WHEN runtime_version ~ '\bnetstandard2\.0' THEN 'NET Core 2.x'
    WHEN runtime_version ~ '\bnetstandard1\.' THEN 'NET Core 1.x'

    -- .NET Framework (e.g. net472, net4.7.2, net48)
    WHEN runtime_version ~ '\bnet4(\d{1,2}|\.\d+(\.\d+)?)' THEN 'NET Framework'

    -- Fallback
    ELSE runtime_version
END
