#!/usr/bin/env bash

curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $MY_GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/actions/artifacts/ARTIFACT_ID/ARCHIVE_FORMAT