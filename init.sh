#!/usr/bin/env bash

set -e

SOURCE_DIR="$(dirname "$(realpath "$0")")"

# Make sure we're (probably) in the right directory
#
if [[ ! -f "$SOURCE_DIR"/.envrc ]] ||
    [[ ! -f "$SOURCE_DIR"/flake.nix ]] ||
    [[ ! -d "$SOURCE_DIR"/.git ]] ||
    [[ ! -f "$SOURCE_DIR"/init.sh ]] ||
    [[ ! -d "$SOURCE_DIR"/scripts ]]; then
    echo "This script must be run from the hackenv template directory!"
    exit 1
fi

# Determine environment name
#
ENVIRONMENT_NAME_FOR_HUMANS="$1"
if [[ -z "$ENVIRONMENT_NAME_FOR_HUMANS" ]]; then
    echo "You must supply an engagement name!"
    exit 1
fi

ENVIRONMENT_NAME="$(echo "$ENVIRONMENT_NAME_FOR_HUMANS" | tr "[:upper:]" "[:lower:]" | tr -s -c "[:alnum:]" _ | sed 's/^_//;s/_$//')"

# Copy template directory
#
DESTINATION_DIR="$(realpath "$HOME")"/engagements/"$ENVIRONMENT_NAME"
mkdir -p "$(dirname "$DESTINATION_DIR")"
cp -af "$SOURCE_DIR" "$DESTINATION_DIR"
rm -rf "$DESTINATION_DIR"/.git

# Create scratch file
#
SCRATCH_FILE="$(mktemp)"

# Replace {{PLACEHOLDER}} values
#
sed "s|{{ENVIRONMENT_NAME_FOR_HUMANS}}|$ENVIRONMENT_NAME_FOR_HUMANS|g;s|{{ENVIRONMENT_NAME}}|$ENVIRONMENT_NAME|g" "$DESTINATION_DIR"/.envrc >"$SCRATCH_FILE"
cp "$SCRATCH_FILE" "$DESTINATION_DIR"/.envrc

sed "s|{{ENVIRONMENT_NAME_FOR_HUMANS}}|$ENVIRONMENT_NAME_FOR_HUMANS|g" "$DESTINATION_DIR"/flake.nix >"$SCRATCH_FILE"
cp "$SCRATCH_FILE" "$DESTINATION_DIR"/flake.nix

if [[ "$(uname -s)" == "Darwin" ]]; then
    OPERATING_SYSTEM_NAME="$(sw_vers --productName) $(sw_vers --productVersion) ($(sw_vers --buildVersion))"
else
    OPERATING_SYSTEM_NAME="$(lsb_release -ds)"
fi
sed "s|{{OPERATING_SYSTEM_NAME}}|$OPERATING_SYSTEM_NAME|g;s|{{UNAME_OUTPUT}}|$(uname -a)|g;s|{{NIX_VERSION}}|$(nix --version)|g;s|{{DIRENV_VERSION}}|direnv $(direnv version)|g" "$DESTINATION_DIR"/SYSTEM_INFO.txt >"$SCRATCH_FILE"
cp "$SCRATCH_FILE" "$DESTINATION_DIR"/SYSTEM_INFO.txt

# Remove .gitignore directive block that's only relevant for the template repo
#
sed '/^#\{72\}$/,/^#\{72\}$/d' "$DESTINATION_DIR"/.gitignore >"$SCRATCH_FILE"
cp "$SCRATCH_FILE" "$DESTINATION_DIR"/.gitignore

# Remove scratch file
#
rm -f "$SCRATCH_FILE"

# Init git in new directory
#
(
    cd "$DESTINATION_DIR"
    git init
    git add -A -v
    git commit -m "Initial commit: $ENVIRONMENT_NAME_FOR_HUMANS ($(date))"
)

# Pre-init the environment
#
(
    cd "$DESTINATION_DIR"
    direnv allow "$DESTINATION_DIR"/.envrc
    eval "$(direnv export bash)"
)

# Fin
#
echo "Environment setup complete!"
echo ""
echo "The environment directory for $ENVIRONMENT_NAME_FOR_HUMANS is:"
echo ""
echo "  $ENVIRONMENT_NAME"
echo ""
echo "You can enter the environment by simply cd'ing into this directory, or"
echo "by running running the wrapShell command:"
echo ""
echo "  $ENVIRONMENT_NAME/scripts/wrapShell"
echo ""
echo "Using the wrapShell script is recommended, as it will take care of"
echo "starting Metasploit's database and recording your terminal session."
echo ""
echo "Additional packages can be installed by editing the flake.nix"
echo "(preferred), requirements.txt (Python), package.json (Node), or Gemfile"
echo "(Ruby) files in the environment directory. The relevant components of"
echo "the environment will be automatically rebuilt after you save any of"
echo "these files."
echo ""
echo "To back up the environment, simply run the provided backupEnvironment"
echo "script. This backup will include all of your scripts and artifacts, and"
echo "should allow a client or coworker to reproduce the environment on their"
echo "system."
