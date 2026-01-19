#!/bin/sh

if [ -z "$REPO_URL" ]; then
	echo "Missing 'REPO_URL' environment variable"
	exit 1
fi

if [ -z "$BRANCH" ]; then
	echo "Missing 'BRANCH' environment variable"
	exit 1
fi

# CHECK: If FRESH_PULL is set OR the git repo doesn't exist yet
if [ -n "$FRESH_PULL" ] || [ ! -d "/backend/.git" ]; then
	echo "[Backend BOOT] FRESH_PULL defined or repo missing. Cloning from scratch..."

	# Remove old folder if it exists
	rm -fr /backend

	# Clone specific branch
	gix clone -b "$BRANCH" "$REPO_URL" /backend/

else
	echo "[Backend BOOT] Repo exists. Force resetting to remote..."
	cd /backend/

	# The "Force Reset" logic from your previous question
	git fetch --all
	git reset --hard "origin/$BRANCH"
	git clean -fd
fi

echo "[Backend BOOT] Entered repo"
cd /backend/

echo "[Backend BOOT] Starting using nix flake..."
nix run .#host --extra-experimental-features nix-command --extra-experimental-features flakes
