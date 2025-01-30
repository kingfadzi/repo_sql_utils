UPDATE bitbucket_repositories
SET status = 'NEW'
    FROM combined_repo_metrics
WHERE bitbucket_repositories.repo_id = combined_repo_metrics.repo_id
  AND combined_repo_metrics.main_language = 'Java'
