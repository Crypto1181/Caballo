#!/bin/bash

# Caballo Web Deployment Script

echo "🐴 Caballo Web Deployment Starting..."
echo ""

# Check if GitHub remote is set
if ! git remote | grep -q origin; then
    echo "❌ No GitHub remote found!"
    echo "Please run this command first (replace YOUR_USERNAME with your GitHub username):"
    echo "git remote add origin https://github.com/YOUR_USERNAME/caballo.git"
    exit 1
fi

# Build web app
echo "📦 Building web app..."
flutter build web --release --base-href="/Caballo/"

# Deploy to gh-pages
echo "🚀 Deploying to GitHub Pages..."
git add build/web -f
git commit -m "Build web app"
git subtree push --prefix build/web origin gh-pages

echo ""
echo "✅ Deployment complete!"
echo "📱 Your app will be live at: https://YOUR_USERNAME.github.io/caballo/"
echo ""
echo "Note: It may take a few minutes for GitHub Pages to update."

