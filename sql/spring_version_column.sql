CASE
  WHEN version ~ '^\d+\.\d+\.\d+$' THEN regexp_replace(version, '^(\d+)\.\d+\.(\d+)$', '\1.\2')
  ELSE version
END