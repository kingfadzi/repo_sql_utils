INSERT INTO component_mapping (
    component_id,
    component_name,
    transaction_cycle,
    mapping_type,
    instance_url,
    tool_type,
    name,
    identifier,
    web_url,
    project_key,
    repo_slug
)
VALUES
    -- Component: Alpha (Component ID: 1001)
    (1001, 'Alpha', 'Cycle A', 'business_application', 'https://bitbucketdatacenter.example.com:8443', 'AppToolAlpha', 'Alpha App 1', 'APP_A1', NULL, NULL, NULL),
    (1001, 'Alpha', 'Cycle A', 'business_application', 'https://bitbucketdatacenter.example.com:8443', 'AppToolAlpha', 'Alpha App 2', 'APP_A2', NULL, NULL, NULL),
    (1001, 'Alpha', 'Cycle A', 'version_control',      'https://bitbucketdatacenter.example.com:8443', 'RepoToolAlpha',   'Alpha Repo 1', 'REPO_A1', 'https://bitbucketdatacenter.example.com:8443/projects/ALPHA1/repos/ALPHA_REPO1/browse', 'ALPHA1', 'ALPHA_REPO1'),
    (1001, 'Alpha', 'Cycle A', 'version_control',      'https://bitbucketdatacenter.example.com:8443', 'RepoToolAlpha',   'Alpha Repo 2', 'REPO_A2', 'https://bitbucketdatacenter.example.com:8443/projects/ALPHA1/repos/ALPHA_REPO2/browse', 'ALPHA1', 'ALPHA_REPO2'),
    (1001, 'Alpha', 'Cycle A', 'version_control',      'https://bitbucketdatacenter.example.com:8443', 'RepoToolAlpha',   'Alpha Repo 3', 'REPO_A3', 'https://bitbucketdatacenter.example.com:8443/projects/ALPHA2/repos/ALPHA_REPO3/browse', 'ALPHA2', 'ALPHA_REPO3'),

    -- Component: Beta (Component ID: 1002)
    (1002, 'Beta', 'Cycle B', 'business_application', 'https://bitbucketdatacenter.example.com:8443', 'AppToolBeta', 'Beta App 1', 'APP_B1', NULL, NULL, NULL),
    (1002, 'Beta', 'Cycle B', 'version_control',      'https://bitbucketdatacenter.example.com:8443', 'RepoToolBeta',  'Beta Repo 1', 'REPO_B1', 'https://bitbucketdatacenter.example.com:8443/projects/BETA/repos/BETA_REPO1/browse', 'BETA', 'BETA_REPO1'),
    (1002, 'Beta', 'Cycle B', 'version_control',      'https://bitbucketdatacenter.example.com:8443', 'RepoToolBeta',  'Beta Repo 2', 'REPO_B2', 'https://bitbucketdatacenter.example.com:8443/projects/BETA/repos/BETA_REPO2/browse', 'BETA', 'BETA_REPO2'),

    -- Component: Gamma (Component ID: 1003)
    (1003, 'Gamma', 'Cycle C', 'business_application', 'https://bitbucketdatacenter.example.com:8443', 'AppToolGamma', 'Gamma App 1', 'APP_G1', NULL, NULL, NULL),
    (1003, 'Gamma', 'Cycle C', 'business_application', 'https://bitbucketdatacenter.example.com:8443', 'AppToolGamma', 'Gamma App 2', 'APP_G2', NULL, NULL, NULL),
    (1003, 'Gamma', 'Cycle C', 'business_application', 'https://bitbucketdatacenter.example.com:8443', 'AppToolGamma', 'Gamma App 3', 'APP_G3', NULL, NULL, NULL),
    (1003, 'Gamma', 'Cycle C', 'version_control',      'https://bitbucketdatacenter.example.com:8443', 'RepoToolGamma', 'Gamma Repo 1', 'REPO_G1', 'https://bitbucketdatacenter.example.com:8443/projects/GAMMA/repos/GAMMA_REPO1/browse', 'GAMMA', 'GAMMA_REPO1'),

    -- Component: Delta (Component ID: 1004)
    (1004, 'Delta', 'Cycle D', 'version_control', 'https://bitbucketdatacenter.example.com:8443', 'RepoToolDelta', 'Delta Repo 1', 'REPO_D1', 'https://bitbucketdatacenter.example.com:8443/projects/DELTA1/repos/DELTA_REPO1/browse', 'DELTA1', 'DELTA_REPO1'),
    (1004, 'Delta', 'Cycle D', 'version_control', 'https://bitbucketdatacenter.example.com:8443', 'RepoToolDelta', 'Delta Repo 2', 'REPO_D2', 'https://bitbucketdatacenter.example.com:8443/projects/DELTA2/repos/DELTA_REPO2/browse', 'DELTA2', 'DELTA_REPO2'),
    (1004, 'Delta', 'Cycle D', 'version_control', 'https://bitbucketdatacenter.example.com:8443', 'RepoToolDelta', 'Delta Repo 3', 'REPO_D3', 'https://bitbucketdatacenter.example.com:8443/projects/DELTA3/repos/DELTA_REPO3/browse', 'DELTA3', 'DELTA_REPO3'),
    (1004, 'Delta', 'Cycle D', 'version_control', 'https://bitbucketdatacenter.example.com:8443', 'RepoToolDelta', 'Delta Repo 4', 'REPO_D4', 'https://bitbucketdatacenter.example.com:8443/projects/DELTA4/repos/DELTA_REPO4/browse', 'DELTA4', 'DELTA_REPO4'),

    -- Component: Epsilon (Component ID: 1005)
    (1005, 'Epsilon', 'Cycle E', 'business_application', 'https://bitbucketdatacenter.example.com:8443', 'AppToolEpsilon', 'Epsilon App 1', 'APP_E1', NULL, NULL, NULL),
    (1005, 'Epsilon', 'Cycle E', 'business_application', 'https://bitbucketdatacenter.example.com:8443', 'AppToolEpsilon', 'Epsilon App 2', 'APP_E2', NULL, NULL, NULL),
    (1005, 'Epsilon', 'Cycle E', 'version_control',      'https://bitbucketdatacenter.example.com:8443', 'RepoToolEpsilon', 'Epsilon Repo 1', 'REPO_E1', 'https://bitbucketdatacenter.example.com:8443/projects/EPSILON1/repos/EPSILON_REPO1/browse', 'EPSILON1', 'EPSILON_REPO1'),
    (1005, 'Epsilon', 'Cycle E', 'version_control',      'https://bitbucketdatacenter.example.com:8443', 'RepoToolEpsilon', 'Epsilon Repo 2', 'REPO_E2', 'https://bitbucketdatacenter.example.com:8443/projects/EPSILON2/repos/EPSILON_REPO2/browse', 'EPSILON2', 'EPSILON_REPO2'),
    (1005, 'Epsilon', 'Cycle E', 'version_control',      'https://bitbucketdatacenter.example.com:8443', 'RepoToolEpsilon', 'Epsilon Repo 3', 'REPO_E3', 'https://bitbucketdatacenter.example.com:8443/projects/EPSILON3/repos/EPSILON_REPO3/browse', 'EPSILON3', 'EPSILON_REPO3');
