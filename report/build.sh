#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
"$CHROME" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="nitrosend-webhooks-report.pdf" "file://$PWD/index.html"
echo "Wrote nitrosend-webhooks-report.pdf"
