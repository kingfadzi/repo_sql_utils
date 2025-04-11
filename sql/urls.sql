UPDATE Bitbucket_Repositories
SET browse_url =
'https://' ||
regexp_replace(
    regexp_replace(clone_url_ssh, '^git@(.*?):', '\1/'),
    '\.git$', '', 'g'
)

UPDATE Your_Table
SET browse_url =
        CASE
            -- GitLab Pattern (git@domain:path)
            WHEN clone_url_ssh ~ '^git@([^/:]+):([^/]+/[^/]+)(\.git)?$' THEN
                regexp_replace(
                        clone_url_ssh,
                        '^git@([^/:]+):([^/]+/[^/]+)(\.git)?$',
                        'https://\1/\2',
                        'g'
                )

            -- BitBucket Pattern (ssh://git@domain:port/path)
            WHEN clone_url_ssh ~ '^(ssh://)?git@([^/:]+?)(:\d+)?/([^/]+)/([^/]+?)(\.git)?$' THEN
                regexp_replace(
                        clone_url_ssh,
                        '^(ssh://)?git@([^/:]+?)(:\d+)?/([^/]+)/([^/]+?)(\.git)?$',
                        'https://\2/scm/\4/\5',
                        'g'
                )

            -- Fallback: Leave unchanged
            ELSE browse_url
            END
WHERE clone_url_ssh ~ 'git@';  -- Only process SSH URLs
