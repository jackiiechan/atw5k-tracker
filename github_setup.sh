#!/bin/bash
# ── All Around the World 5K — GitHub Setup Script ──────────────────

echo ""
echo "🌍 All Around the World 5K — GitHub Setup"
echo "────────────────────────────────────────────"
echo ""

# ── 1. Homebrew ────────────────────────────────────────────────────
if ! command -v brew &> /dev/null; then
  echo "📦 Homebrew not found. Installing it now..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon Macs
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
else
  echo "✓ Homebrew already installed"
fi

# ── 2. GitHub CLI ──────────────────────────────────────────────────
if ! command -v gh &> /dev/null; then
  echo "📦 Installing GitHub CLI..."
  brew install gh
else
  echo "✓ GitHub CLI already installed"
fi

echo ""

# ── 3. GitHub Auth ─────────────────────────────────────────────────
if ! gh auth status &> /dev/null; then
  echo "🔐 Logging you into GitHub..."
  echo "   → Choose: GitHub.com → HTTPS → Yes → Login with a web browser"
  echo ""
  gh auth login
else
  echo "✓ Already logged into GitHub"
fi

echo ""

# ── 4. Repo details ────────────────────────────────────────────────
GITHUB_USER=$(gh api user --jq '.login' 2>/dev/null)
echo "👤 GitHub user: $GITHUB_USER"
echo ""
read -p "📁 Repo name (press Enter to use 'atw5k-tracker'): " REPO_NAME
REPO_NAME=${REPO_NAME:-atw5k-tracker}

echo ""
echo "Creating repository: $GITHUB_USER/$REPO_NAME"

# ── 5. Create repo ─────────────────────────────────────────────────
gh repo create "$REPO_NAME" \
  --public \
  --description "All Around the World 5K — Runner Tracker" \
  2>/dev/null || echo "  (repo may already exist — continuing)"

# ── 6. Push tracker file ───────────────────────────────────────────
cd "$(dirname "$0")"

git init -q
git add relic_tracker.html
git commit -q -m "ATW 5K Relic Tracker — initial deploy"
git branch -M main
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
git push -u origin main --force -q

echo ""

# ── 7. Enable GitHub Pages ─────────────────────────────────────────
echo "🌐 Enabling GitHub Pages..."
gh api "repos/$GITHUB_USER/$REPO_NAME/pages" \
  --method POST \
  -f "source[branch]=main" \
  -f "source[path]=/" \
  --silent 2>/dev/null || \
gh api "repos/$GITHUB_USER/$REPO_NAME/pages" \
  --method PUT \
  -f "source[branch]=main" \
  -f "source[path]=/" \
  --silent 2>/dev/null || true

echo ""
echo "────────────────────────────────────────────"
echo "✅ All done! Your tracker is live at:"
echo ""
echo "   https://$GITHUB_USER.github.io/$REPO_NAME"
echo ""
echo "GitHub Pages takes about 60 seconds to go live."
echo "Bookmark that URL — it works on any device."
echo "────────────────────────────────────────────"
echo ""
