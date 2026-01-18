#!/bin/sh

if [ -z "$REPO_URL"]; then
	echo "Missing 'REPO_URL' environment variable"
	exit 1
fi

echo "[Backend BOOT] Removeing old git pull, if it exists"
rm -fr /backend

echo "[Backend BOOT] Cloning repo..."
gix clone https://github.com/MagicBOTAlex/ZCollection.git /backend/

echo "[Backend BOOT] Entered repo"
cd /backend/

echo "[Backend BOOT] Starting using nix flake..."
nix run .#host --extra-experimental-features nix-command --extra-experimental-features flakes
