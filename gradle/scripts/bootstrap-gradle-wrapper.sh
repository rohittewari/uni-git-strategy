#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
WRAPPER_DIR="$REPO_ROOT/gradle/wrapper"
WRAPPER_PROPERTIES="$WRAPPER_DIR/gradle-wrapper.properties"

if [ ! -f "$WRAPPER_PROPERTIES" ]; then
    echo "Missing Gradle wrapper properties at $WRAPPER_PROPERTIES" >&2
    exit 1
fi

DISTRIBUTION_URL=$(sed -n 's/^distributionUrl=//p' "$WRAPPER_PROPERTIES" | head -n 1 | sed 's/\\:/:/g')
if [ -z "$DISTRIBUTION_URL" ]; then
    echo "distributionUrl was not found in $WRAPPER_PROPERTIES" >&2
    exit 1
fi

DISTRIBUTION_FILE=${DISTRIBUTION_URL##*/}
VERSION=$(printf '%s' "$DISTRIBUTION_FILE" | sed -n 's/^gradle-\(.*\)-\(bin\|all\)\.zip$/\1/p')
if [ -z "$VERSION" ]; then
    echo "Unable to parse Gradle version from distribution URL: $DISTRIBUTION_URL" >&2
    exit 1
fi

WRAPPER_JAR="$WRAPPER_DIR/gradle-wrapper-$VERSION.jar"
VERSIONED_WRAPPER_PROPERTIES="$WRAPPER_DIR/gradle-wrapper-$VERSION.properties"
LEGACY_WRAPPER_JAR="$WRAPPER_DIR/gradle-wrapper.jar"

if [ -f "$WRAPPER_JAR" ]; then
    if [ ! -f "$VERSIONED_WRAPPER_PROPERTIES" ]; then
        cp "$WRAPPER_PROPERTIES" "$VERSIONED_WRAPPER_PROPERTIES"
    fi
    exit 0
fi

if [ -f "$LEGACY_WRAPPER_JAR" ]; then
    mv "$LEGACY_WRAPPER_JAR" "$WRAPPER_JAR"
    cp "$WRAPPER_PROPERTIES" "$VERSIONED_WRAPPER_PROPERTIES"
    exit 0
fi

DOWNLOAD_URL=
for TAG in "v$VERSION" "v$VERSION.0"; do
    CANDIDATE_URL="https://raw.githubusercontent.com/gradle/gradle/$TAG/gradle/wrapper/gradle-wrapper.jar"
    if curl --fail --location --silent --output /dev/null "$CANDIDATE_URL"; then
        DOWNLOAD_URL=$CANDIDATE_URL
        break
    fi
done

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Unable to resolve a wrapper JAR download URL for Gradle $VERSION" >&2
    exit 1
fi

mkdir -p "$(dirname "$WRAPPER_JAR")"
TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

echo "Downloading Gradle wrapper JAR for Gradle $VERSION..."
curl --fail --location --silent --show-error --output "$TMP_FILE" "$DOWNLOAD_URL"
mv "$TMP_FILE" "$WRAPPER_JAR"
cp "$WRAPPER_PROPERTIES" "$VERSIONED_WRAPPER_PROPERTIES"
