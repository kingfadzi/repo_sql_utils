SELECT
    (vc.project_key || '/' || vc.repo_slug) AS repo_id,
    vc.component_id,
    vc.component_name,
    vc.transaction_cycle,
    vc.name AS version_control_name,
    vc.identifier AS version_control_identifier,
    vc.web_url,
    string_agg(ba.identifier, ', ') AS app_identifiers
FROM
    component_mapping vc
        LEFT JOIN
    component_mapping ba
    ON vc.component_id = ba.component_id
        AND ba.mapping_type = 'business_application'
WHERE
    vc.mapping_type = 'version_control'
GROUP BY
    vc.project_key,
    vc.repo_slug,
    vc.component_id,
    vc.component_name,
    vc.transaction_cycle,
    vc.name,
    vc.identifier,
    vc.web_url;
