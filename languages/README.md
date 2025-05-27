Source: https://github.com/github-linguist/linguist/blob/main/lib/linguist/languages.yml



```yaml
yq eval -o=csv '
["language","type","color","extensions","tm_scope","ace_mode","language_id"],
(to_entries[]
  | [
      .key,
      .value.type,
      .value.color,
      (.value.extensions // [] | join(";")),
      .value.tm_scope,
      .value.ace_mode,
      .value.language_id
    ]
)
' languages.yaml > languages.csv


