CASE
  WHEN runtime_version LIKE '%|%' THEN
    regexp_replace(
      regexp_replace(
        regexp_replace(
          split_part(runtime_version, '|', 1),
          '[\^<>=~! ]+',
          '',
          'g'
        ),
        '\.\*$',  -- remove trailing .*
        ''
      ),
      '^(\d+\.\d+)(?:\.\d+)?$',
      '\1'
    )

  ELSE
    regexp_replace(
      regexp_replace(
        regexp_replace(
          split_part(runtime_version, ',', 1),
          '[\^<>=~! ]+',
          '',
          'g'
        ),
        '\.\*$',  -- remove trailing .*
        ''
      ),
      '^(\d+\.\d+)(?:\.\d+)?$',
      '\1'
    )
END
