# Deploying Caballo Web App to GitHub Pages

This guide will help you deploy the Flutter web app to GitHub Pages so you can test it on iOS devices.

## Prerequisites

- A GitHub repository (already set up)
- GitHub Actions enabled in your repository
- Flutter SDK installed locally (for manual deployment)

## Automatic Deployment (Recommended)

The repository includes a GitHub Actions workflow that automatically builds and deploys your web app whenever you push to the `main` branch.

### Step 1: Enable GitHub Pages

1. Go to your GitHub repository: `https://github.com/YOUR_USERNAME/caballo`
2. Click on **Settings** (top right)
3. Scroll down to **Pages** in the left sidebar
4. Under **Source**, select:
   - **Source**: `GitHub Actions`
5. Click **Save**

### Step 2: Push Your Code

The workflow will automatically trigger when you push to the `main` branch:

```bash
git add .
git commit -m "Deploy web app"
git push origin main
```

### Step 3: Monitor Deployment

1. Go to the **Actions** tab in your GitHub repository
2. You should see the "Deploy Flutter Web to GitHub Pages" workflow running
3. Wait for it to complete (usually takes 2-5 minutes)
4. Once complete, your app will be available at:
   ```
   https://YOUR_USERNAME.github.io/Caballo/
   ```

### Step 4: Test on iOS

1. Open Safari on your iOS device
2. Navigate to: `https://YOUR_USERNAME.github.io/Caballo/`
3. The app should load and be fully functional

## Manual Deployment (Alternative)

If you prefer to deploy manually, you can use the provided script:

```bash
./deploy.sh
```

Or manually:

```bash
# Build the web app
flutter build web --release --base-href="/Caballo/"

# Deploy to gh-pages branch
git add build/web -f
git commit -m "Build web app"
git subtree push --prefix build/web origin gh-pages
```

## Troubleshooting

### App not loading
- Check the browser console for errors
- Ensure GitHub Pages is enabled in repository settings
- Verify the base-href matches your repository name (case-sensitive)

### Build fails
- Make sure Flutter is up to date: `flutter upgrade`
- Check that all dependencies are installed: `flutter pub get`
- Review the Actions tab for detailed error messages

### iOS Safari issues
- Clear Safari cache: Settings > Safari > Clear History and Website Data
- Try in a private browsing window
- Check if JavaScript is enabled

## Updating the App

Simply push changes to the `main` branch, and the workflow will automatically rebuild and redeploy:

```bash
git add .
git commit -m "Update app"
git push origin main
```

The deployment usually takes 2-5 minutes to complete.

## Custom Domain (Optional)

If you want to use a custom domain:

1. Add a `CNAME` file in the `build/web` directory with your domain
2. Update DNS settings to point to GitHub Pages
3. Configure the custom domain in GitHub Pages settings

## Notes

- The app is deployed to the `/Caballo/` path (case-sensitive)
- Make sure your repository name matches (if different, update the `--base-href` in the workflow)
- The first deployment may take longer than subsequent ones

