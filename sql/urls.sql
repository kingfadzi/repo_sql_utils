UPDATE Bitbucket_Repositories
SET browse_url =
'https://' ||
regexp_replace(
    regexp_replace(clone_url_ssh, '^git@(.*?):', '\1/'),
    '\.git$', '', 'g'
)

UPDATE Bitbucket_Repositories
SET browse_url =
        regexp_replace(
                regexp_replace(clone_url_ssh,
                               '^git@(.*?):',
                               'https://\1/',
                               'g'
                ),
                '\.git$',
                '',
                'g'
        )

UPDATE Bitbucket_Repositories
SET browse_url =
        regexp_replace(  -- Remove .git from final URL
                regexp_replace(  -- Convert SSH to HTTPS
                        clone_url_ssh,
                        '^(ssh://)?git@([^/:]+?)(:\d+)?/([^/]+)/([^/]+?)(\.git)?$',
                        'https://\2/scm/\4/repos/\5',
                        'g'
                ),
                '\.git$',
                '',
                'g'
        )
