#!/usr/bin/env bash
#
# Deploys files listed in a "source|destination" tag file to their target
# paths on this server.
#
# This script is checked into the repo and runs FROM the cloned copy on
# the target server (invoked by the CI pipeline right after `git clone`).
# Its own location is used to resolve the repo root, so it works no matter
# what directory it's invoked from.
#
# Usage:
#   deploy.sh <deployment-tag-filename>
#
# Example:
#   deploy.sh deployement_tag_20260901.txt
#
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <deployment-tag-filename>" >&2
  exit 1
fi

TAG_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TAG_FILE="${SCRIPT_DIR}/${TAG_NAME}"

if [ ! -f "${TAG_FILE}" ]; then
  echo "ERROR: deployment tag file not found: ${TAG_FILE}" >&2
  exit 1
fi

echo "Repo root             : ${REPO_DIR}"
echo "Using deployment tag file: ${TAG_FILE}"
echo ""

deploy_count=0

while IFS='|' read -r src dst || [ -n "${src:-}" ]; do
  src="$(echo "${src:-}" | xargs)"
  dst="$(echo "${dst:-}" | xargs)"

  [ -z "${src}" ] && continue
  case "${src}" in
    \#*) continue ;;
  esac

  if [ -z "${dst}" ]; then
    echo "ERROR: no destination path for source '${src}' in ${TAG_FILE}" >&2
    exit 1
  fi

  src_path="${REPO_DIR}/${src}"

  if [ ! -e "${src_path}" ]; then
    echo "ERROR: source path not found in repo: ${src}" >&2
    exit 1
  fi

  echo "Deploying: ${src} -> ${dst}"
  mkdir -p "$(dirname "${dst}")"
  cp -rf "${src_path}" "${dst}"
  deploy_count=$((deploy_count + 1))
done < "${TAG_FILE}"

echo ""
echo "Deployed ${deploy_count} path(s) from tag file."
