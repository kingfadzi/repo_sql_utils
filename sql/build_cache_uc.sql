-- First, drop the existing unique constraint
ALTER TABLE build_config_cache
DROP CONSTRAINT IF EXISTS _build_tools_full_uc;

-- Then, create the new unique constraint including `variant`
ALTER TABLE build_config_cache
    ADD CONSTRAINT _build_tools_full_uc
        UNIQUE (repo_id, module_path, tool, variant, tool_version, runtime_version)