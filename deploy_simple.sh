#!/bin/bash

# Simple deployment script for GitHub Pages

echo "🐴 Caballo Web Deployment (Simple Method)"
echo ""

# Commit the build
echo "📦 Committing build..."
git add build/web -f
git add web/index.html
git commit -m "Update web build with loading indicator" || echo "No changes to commit"

# Create or update gh-pages branch
echo "🚀 Deploying to gh-pages..."

# Remove old gh-pages if it exists
git branch -D gh-pages 2>/dev/null || true

# Create new gh-pages branch from build/web
git subtree split --prefix build/web -b gh-pages

# Force push to origin
echo "📤 Pushing to GitHub..."
git push -f origin gh-pages

echo ""
echo "✅ Deployment complete!"
echo "📱 Your app should be live at: https://crypto1181.github.io/Caballo/"
echo ""
echo "Note: It may take 1-2 minutes for GitHub Pages to update."
echo "If you still see a blank screen, try:"
echo "1. Hard refresh: Ctrl+Shift+R (or Cmd+Shift+R on Mac)"
echo "2. Clear browser cache"
echo "3. Open in incognito/private window"

