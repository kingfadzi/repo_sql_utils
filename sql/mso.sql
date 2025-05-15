SELECT
    public.harvested_repositories.repo_id,
    public.harvested_repositories.browse_url,
    public.harvested_repositories.activity_status,
    public.harvested_repositories.transaction_cycle,
    public.harvested_repositories.component_name,
    public.build_config_cache.tool,
    public.build_config_cache.variant,
    public.build_config_cache.module_path,
    public.build_config_cache.copied_files,
    public.build_config_cache.tool_version,
    public.build_config_cache.runtime_version,
    public.build_config_cache.confidence,
    public.build_config_cache.detection_sources,
    public.build_config_cache.extraction_method
FROM
    public.harvested_repositories
        LEFT JOIN
    public.build_config_cache
    ON public.harvested_repositories.repo_id = public.build_config_cache.repo_id
    LIMIT 1048575;
