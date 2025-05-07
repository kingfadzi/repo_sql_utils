SELECT
    hr.repo_id,
    hr.repo_name,
    hr.project_key,
    hr.repo_slug,
    hr.clone_url_ssh,
    hr.browse_url,
    hr.updated_date,
    hr.last_harvested_at,
    hr.app_id,
    hr.host_name,
    hr.transaction_cycle,
    hr.main_language,
    hr.classification_label,
    hr.activity_status,
    hr.status,
    hr.comment,
    hr.scope,
    hr.component_id,
    hr.component_name,
    gea.id AS go_enry_id,
    gea.language AS go_enry_language,
    gea.percent_usage AS go_enry_percent_usage
FROM public.harvested_repositories hr
         LEFT JOIN public.go_enry_analysis gea ON hr.repo_id = gea.repo_id

