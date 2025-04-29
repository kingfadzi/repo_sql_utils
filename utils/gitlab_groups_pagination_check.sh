#!/bin/bash

# Usage: ./gitlab_groups_pagination_check.sh <GITLAB_HOST> <PRIVATE_TOKEN>
# Example: ./gitlab_groups_pagination_check.sh eros.butterflycluster.com glpat-xxxxx

GITLAB_HOST="$1"
TOKEN="$2"

if [ -z "$GITLAB_HOST" ] || [ -z "$TOKEN" ]; then
  echo "Usage: $0 <GITLAB_HOST> <PRIVATE_TOKEN>"
  exit 1
fi

PER_PAGE=50
PAGE=1
TOTAL_GROUPS=0

echo "Querying GitLab groups from: https://$GITLAB_HOST"

while :; do
  echo "Fetching page $PAGE..."

  RESPONSE=$(curl -s -D - -H "PRIVATE-TOKEN: $TOKEN" \
    "https://$GITLAB_HOST/api/v4/groups?per_page=$PER_PAGE&page=$PAGE&all_available=true&include_subgroups=true")

  HEADERS=$(echo "$RESPONSE" | sed '/^\r$/q')
  BODY=$(echo "$RESPONSE" | sed '1,/^\r$/d')

  COUNT=$(echo "$BODY" | jq 'length')
  TOTAL_GROUPS=$((TOTAL_GROUPS + COUNT))

  echo " → Fetched $COUNT groups from page $PAGE"

  NEXT_PAGE=$(echo "$HEADERS" | grep -i ^X-Next-Page | cut -d' ' -f2 | tr -d '\r')

  if [ -z "$NEXT_PAGE" ]; then
    echo "No more pages."
    break
  fi

  PAGE=$NEXT_PAGE
done

echo "✅ Total groups fetched: $TOTAL_GROUPS"
