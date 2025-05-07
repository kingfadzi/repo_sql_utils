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
         INNER JOIN public.go_enry_analysis ge ON hr.repo_id = ge.repo_id
WHERE hr.activity_status = 'ACTIVE'
  AND ge.language IN (
                      'Python', 'Java', 'JavaScript', 'Groovy', 'Go', 'ASP.NET', 'C#', 'F#',
                      'Jinja', 'Kotlin', 'Jupyter Notebook', 'Visual Basic.NET', 'TypeScript', 'Visual Basic 6.0'
    )
GROUP BY
    hr.repo_id,
    hr.browse_url,
    hr.main_language,
    hr.classification_label,
    hr.activity_status,
    hr.status;
