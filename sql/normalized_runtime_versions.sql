CASE
  -- Java: normalize to major version
  WHEN main_language = 'java' THEN (
    CASE
      WHEN runtime_version LIKE '1.%' THEN split_part(runtime_version, '.', 2)::int::text
      WHEN runtime_version ~ '^\d+\.\d+(\.\d+)?([+_a-zA-Z0-9-]*)?$' THEN split_part(runtime_version, '.', 1)::int::text
      WHEN runtime_version ~ '^\d+$' THEN runtime_version
      WHEN runtime_version ~ '.*(\d{1,2})\.\d+.*' THEN regexp_replace(runtime_version, '.*?(\d{1,2})\.\d+.*', '\1')
      ELSE runtime_version
    END
  )

  -- Python
  WHEN main_language = 'python' THEN (
    CASE
      WHEN runtime_version LIKE '%|%' THEN
        regexp_replace(
          regexp_replace(
            regexp_replace(split_part(runtime_version, '|', 1), '[\^<>=~! ]+', '', 'g'),
            '\.\*$', ''
          ),
          '^(\d+\.\d+)(?:\.\d+)?$', '\1'
        )
      ELSE
        regexp_replace(
          regexp_replace(
            regexp_replace(split_part(runtime_version, ',', 1), '[\^<>=~! ]+', '', 'g'),
            '\.\*$', ''
          ),
          '^(\d+\.\d+)(?:\.\d+)?$', '\1'
        )
    END
  )

  -- JavaScript / Node
  WHEN main_language IN ('javascript', 'node') THEN (
    CASE
      WHEN runtime_version LIKE '%|%' THEN
        regexp_replace(
          regexp_replace(
            regexp_replace(split_part(runtime_version, '|', 1), '[\^<>=~! ]+', '', 'g'),
            '\.\*$', ''
          ),
          '^(\d+\.\d+)(?:\.\d+)?$', '\1'
        )
      ELSE
        regexp_replace(
          regexp_replace(
            regexp_replace(split_part(runtime_version, ',', 1), '[\^<>=~! ]+', '', 'g'),
            '\.\*$', ''
          ),
          '^(\d+\.\d+)(?:\.\d+)?$', '\1'
        )
    END
  )

  -- .NET family
  WHEN main_language = 'dotnet' THEN (
    CASE
      WHEN runtime_version ~ '(^|;)net4\.\d+(\.\d+)?' THEN 'NET Framework'
      WHEN runtime_version ~ '(^|;)netcoreapp[6-9]\.' THEN
        'NET ' || regexp_replace(runtime_version, '.*netcoreapp([6-9])\..*', '\1')
      WHEN runtime_version ~ '(^|;)\.?(net0?([5-9])0?(\.\d+)?([-a-z0-9]*)?)' THEN
        'NET ' || regexp_replace(runtime_version, '.*(^|;)\.?(net0?([5-9])).*', '\3')
      WHEN runtime_version ~ '(^|;)netcoreapp3\.' THEN 'NET Core 3.x'
      WHEN runtime_version ~ '(^|;)netcoreapp2\.' THEN 'NET Core 2.x'
      WHEN runtime_version ~ '(^|;)netcoreapp1\.' THEN 'NET Core 1.x'
      WHEN runtime_version ~ '(^|;)netstandard2\.1' THEN 'NET Core 3.x'
      WHEN runtime_version ~ '(^|;)netstandard2\.0' THEN 'NET Core 2.x'
      WHEN runtime_version ~ '(^|;)netstandard20' THEN 'NET Core 2.x'
      WHEN runtime_version ~ '(^|;)netstandard1\.' THEN 'NET Core 1.x'
      WHEN runtime_version ~ '(^|;)net4\d{1,2}' THEN 'NET Framework'
      ELSE runtime_version
    END
  )

  -- Fallback for all others
  ELSE runtime_version
END AS normalized_runtime_version
