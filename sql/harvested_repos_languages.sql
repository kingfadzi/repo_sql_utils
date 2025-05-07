SELECT
    hr.repo_id,
    hr.browse_url,
    hr.main_language,
    hr.classification_label,
    hr.activity_status,
    hr.status,
    STRING_AGG(DISTINCT bt.tool || ':' || bt.tool_version, ',') AS build_tools_versions
FROM public.harvested_repositories hr
         LEFT JOIN public.build_tools bt ON hr.repo_id = bt.repo_id
GROUP BY hr.repo_id, hr.browse_url, hr.main_language, hr.classification_label, hr.activity_status, hr.status
