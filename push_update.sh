#!/bin/bash
cd "$(dirname "$0")"

# Clear stale lock
rm -f .git/index.lock

# Always keep index.html in sync with relic_tracker.html
cp relic_tracker.html index.html

# Configure identity
git config user.email "jackiechan.cal@gmail.com"
git config user.name "Jackie Chan"

# Stage everything in the folder
git add -A

# Only commit if there are actual changes
if git diff --cached --quiet; then
  echo "✅ Nothing new to push — site is already up to date."
else
  git commit -m "Sync: $(date '+%Y-%m-%d %H:%M')"
  git push
  echo ""
  echo "✅ Done! Check https://jackiiechan.github.io/atw5k-tracker/ in ~60 seconds"
fi
