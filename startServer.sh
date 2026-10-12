#!/bin/sh
export DOCKER=true
export NPM_CONFIG_STORE_DIR=/node_modules

if [ -z "$REPO_URL" ]; then
	echo "Missing 'REPO_URL' environment variable"
	exit 1
fi

if [ -z "$BRANCH" ]; then
	echo "Missing 'BRANCH' environment variable"
	exit 1
fi

# If a token is provided, rewrite https URLs for the repo's own host to embed
# credentials. Applied via the environment so nothing is persisted to
# .git/config. x-access-token is accepted as the username by both GitHub and
# self-hosted forges (e.g. Gitea at git.deprived.dev).
if [ -n "$GITHUB_TOKEN" ]; then
	echo "[Backend BOOT] GITHUB_TOKEN set. Enabling authenticated git access."
	REPO_HOST="${REPO_URL#*://}"
	REPO_HOST="${REPO_HOST%%/*}"
	GIT_CONFIG_COUNT=1
	GIT_CONFIG_KEY_0="url.https://x-access-token:${GITHUB_TOKEN}@${REPO_HOST}/.insteadOf"
	GIT_CONFIG_VALUE_0="https://${REPO_HOST}/"
	export GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
fi

# CHECK: If FRESH_PULL is set OR the git repo doesn't exist yet
if [ -n "$FRESH_PULL" ] || [ ! -d "/backend/.git" ]; then
	echo "[Backend BOOT] FRESH_PULL defined or repo missing. Cloning from scratch..."

	# Remove old folder if it exists
	rm -fr /backend

	# Clone specific branch
	git clone -b "$BRANCH" "$REPO_URL" /backend/

else
	echo "[Backend BOOT] Repo exists. Force resetting to remote..."
	cd /backend/

	# The "Force Reset" logic from your previous question
	git fetch --all
	git reset --hard "origin/$BRANCH"
	git clean -fd
fi

# If a .env was mounted/copied at the container root, put it in the repo
if [ -f "/.env" ]; then
	echo "[Backend BOOT] Copying /.env into /backend/.env"
	cp /.env /backend/.env
fi

echo "[Backend BOOT] Entered repo"
cd /backend/

echo "[Backend BOOT] Starting using nix flake..."
nix run .#host --extra-experimental-features nix-command --extra-experimental-features flakes
