CASE
    -- Normalize leading dot (e.g., '.net6.0' → 'net6.0')
    WHEN runtime_version LIKE '.net%' THEN
        CASE
            WHEN substring(runtime_version from 2) ~ '^net[5-9]\d*(\.\d+)?' THEN
                'NET ' || regexp_replace(substring(runtime_version from 2), '^net([5-9]\d*)(\.\d+)?([-a-z0-9]*)?$', '\1')
            WHEN substring(runtime_version from 2) ~ '^netcoreapp' THEN
                'NET Core ' || regexp_replace(substring(runtime_version from 2), '^netcoreapp(\d+(\.\d+)?).*$', '\1')
            WHEN substring(runtime_version from 2) ~ '^netstandard' THEN
                'NET Standard ' || regexp_replace(substring(runtime_version from 2), '^netstandard(\d+(\.\d+)?).*$', '\1')
            WHEN substring(runtime_version from 2) ~ '^net4\d{1,2}$' THEN
                'NET Framework ' || regexp_replace(substring(runtime_version from 2), '^net(\d{2,3})$', '\1' || '.' || substr('\1', 2, 1))
            ELSE substring(runtime_version from 2)
END

    -- .NET 5+ (e.g., net6.0, net6.0-windows, net50)
WHEN runtime_version ~ '^net[5-9]\d*(\.\d+)?([-a-z0-9]*)?$' THEN
        'NET ' || regexp_replace(runtime_version, '^net([5-9]\d*)(\.\d+)?([-a-z0-9]*)?$', '\1')

    -- .NET Core (e.g., netcoreapp2.0, netcoreapp3.1)
    WHEN runtime_version ~ '^netcoreapp\d' THEN
        'NET Core ' || regexp_replace(runtime_version, '^netcoreapp(\d+(\.\d+)?).*$', '\1')

    -- .NET Framework (e.g., net461, net48)
    WHEN runtime_version ~ '^net4\d{1,2}$' THEN
        'NET Framework ' || regexp_replace(runtime_version, '^net(\d{2,3})$', '\1' || '.' || substr('\1', 2, 1))

    -- .NET Standard (e.g., netstandard2.0, netstandard2.1)
    WHEN runtime_version ~ '^netstandard' THEN
        'NET Standard ' || regexp_replace(runtime_version, '^netstandard(\d+(\.\d+)?).*$', '\1')

    -- Fallback: keep original value
    ELSE runtime_version
END
