# Adding GitHub Actions Workflow

The workflow file couldn't be pushed automatically because your Personal Access Token needs the `workflow` scope.

## Option 1: Add via GitHub Web Interface (Easiest)

1. Go to: https://github.com/Crypto1181/Caballo
2. Click on **Add file** → **Create new file**
3. Enter the path: `.github/workflows/deploy-web.yml`
4. Copy and paste the contents from `.github/workflows/deploy-web.yml` in your local project
5. Click **Commit new file**

## Option 2: Update Your Personal Access Token

1. Go to: https://github.com/settings/tokens
2. Edit your existing token or create a new one
3. Make sure to check the **workflow** scope
4. Update your git credentials with the new token
5. Then push the workflow file:

```bash
git add .github/workflows/deploy-web.yml
git commit -m "Add GitHub Actions workflow for web deployment"
git push origin main
```

## Option 3: Use GitHub CLI

If you have GitHub CLI installed:

```bash
gh auth login
git add .github/workflows/deploy-web.yml
git commit -m "Add GitHub Actions workflow for web deployment"
git push origin main
```

After adding the workflow file, GitHub Actions will automatically build and deploy your web app on the next push to `main`.

