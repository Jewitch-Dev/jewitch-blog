#!/usr/bin/env bash

set -euo pipefail

PROJECT="/var/www/jewitch-blog"
BRANCH="main"
LOCKFILE="/tmp/jewitch-blog-deploy.lock"

cd "$PROJECT"

# Prevent two deployments from running simultaneously.
exec 9>"$LOCKFILE"

if ! flock -n 9; then
    echo "[jewitch.blog] Another deployment is already running."
    exit 0
fi

echo "[jewitch.blog] Deployment check started: $(date --iso-8601=seconds)"

# Production should never silently overwrite local modifications.
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "[jewitch.blog] ERROR: Tracked local changes exist."
    echo "[jewitch.blog] Refusing to deploy."
    git status --short
    exit 1
fi

echo "[jewitch.blog] Fetching origin/$BRANCH..."
git fetch --quiet origin "$BRANCH"

LOCAL_SHA="$(git rev-parse HEAD)"
REMOTE_SHA="$(git rev-parse "origin/$BRANCH")"

echo "[jewitch.blog] Local:  $LOCAL_SHA"
echo "[jewitch.blog] Remote: $REMOTE_SHA"

if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
    echo "[jewitch.blog] Already current. Nothing to deploy."
    exit 0
fi

# Make sure deployment is a simple fast-forward.
if ! git merge-base --is-ancestor "$LOCAL_SHA" "$REMOTE_SHA"; then
    echo "[jewitch.blog] ERROR: Local and remote history have diverged."
    echo "[jewitch.blog] Manual intervention required."
    exit 1
fi

echo "[jewitch.blog] New commit detected."

# Update the source tree without merge commits.
git merge --ff-only "origin/$BRANCH"

echo "[jewitch.blog] Installing locked dependencies..."
npm ci --no-audit --no-fund

echo "[jewitch.blog] Building Eleventy..."
npm run build

echo "[jewitch.blog] Deployment completed successfully."
echo "[jewitch.blog] Live commit: $(git rev-parse HEAD)"
