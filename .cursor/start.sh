#!/usr/bin/env bash
###############################################################################
# Per-boot reconciliation for the Pi-Star dashboard environment.
#
# The static config fixtures are created by install.sh (and baked into the
# environment snapshot). The only thing that must run on every boot is
# refreshing the date-stamped activity log so the "Last Heard" table shows
# data for the current day. The dashboard web server itself runs as a
# persistent terminal (see .cursor/environment.json).
###############################################################################
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Guard: if the snapshot didn't include the fixtures (e.g. first run without a
# build), lay them down now so the dashboard is never left in "No Mode" state.
if [ ! -f /etc/mmdvmhost ]; then
    echo "==> Fixtures missing; running install.sh"
    "$REPO_ROOT/.cursor/install.sh"
else
    "$REPO_ROOT/.cursor/gen-sample-log.sh"
fi

echo "==> start.sh complete"
