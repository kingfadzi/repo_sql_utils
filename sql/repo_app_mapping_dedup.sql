WITH distinct_business_apps AS (
    SELECT DISTINCT component_id, identifier
    FROM component_mapping
    WHERE mapping_type = 'business_application'
),
     result AS (
         SELECT
             (vc.project_key || '/' || vc.repo_slug) AS repo_id,
             vc.component_id,
             vc.component_name,
             string_agg(DISTINCT vc.transaction_cycle, ', ') AS transaction_cycle,
             vc.name AS version_control_name,
             vc.identifier AS version_control_identifier,
             vc.web_url,
             string_agg(DISTINCT dba.identifier, ', ') AS app_identifiers
         FROM
             component_mapping vc
                 LEFT JOIN
             distinct_business_apps dba
             ON vc.component_id = dba.component_id
         WHERE
             vc.mapping_type = 'version_control'
         GROUP BY
             vc.project_key,
             vc.repo_slug,
             vc.component_id,
             vc.component_name,
             vc.name,
             vc.identifier,
             vc.web_url
         HAVING
             COUNT(dba.identifier) > 0
     ),
     dupe_repo_ids AS (
         SELECT
             repo_id
         FROM
             result
         GROUP BY
             repo_id
         HAVING
             COUNT(*) > 1
     )
SELECT
    r.*
FROM
    result r
        JOIN
    dupe_repo_ids d
    ON r.repo_id = d.repo_id
ORDER BY
    r.repo_id;
