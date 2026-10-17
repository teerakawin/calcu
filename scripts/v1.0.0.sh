
#!/usr/bin/env bash
set -Eeuo pipefail

VERSION="1.0.0"
ARCHIVE="calcu-${VERSION}.tar.xz"
URL="https://github.com/teerakawin/calcu/releases/download/v${VERSION}/${ARCHIVE}"

printf '%s\n' \
    "Calcu ${VERSION} installer" \
    "If errors occur, please check the script and report them." \
    "Installation prefix: /usr" \
    "Press Ctrl+C to cancel."

for seconds in {15..1}; do
    printf '\rStarting in %2d seconds...' "$seconds"
    sleep 1
done
printf '\nStarting build...\n'

# Work in a temporary directory so we don't clutter the caller's folder.
WORKDIR=$(mktemp -d)
trap 'rm -rf -- "$WORKDIR"' EXIT

cd "$WORKDIR"

printf 'Downloading %s...\n' "$ARCHIVE"
curl -fL --retry 3 -o "$ARCHIVE" "$URL"

printf 'Extracting archive...\n'
tar -xf "$ARCHIVE"

# Assumes the archive contains calcu-1.0.0/
cd "calcu-${VERSION}"

printf 'Configuring...\n'
./configure --prefix=/usr

printf 'Compiling...\n'
make

printf 'Installing...\n'
sudo make install

printf '\nCalcu %s installed successfully!\n' "$VERSION"
echo "return code: " $?
