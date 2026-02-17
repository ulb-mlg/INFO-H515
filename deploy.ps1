# deploy.ps1
# Build Jupyter Book on main, delete gh-pages, recreate it from main, deploy site into subfolder matching repo

# 1. Must be on main
$branch = git branch --show-current
if ($branch -ne "main") {
  Write-Error "You must run this script from the 'main' branch. Current branch: $branch"
  exit 1
}

# 2. Build the book
jupyter-book build --html --strict
if ($LASTEXITCODE -ne 0) {
  Write-Error "Build failed. Aborting deploy."
  exit 1
}

# 3. Delete gh-pages locally if it exists
git branch -D gh-pages 2>$null

# 4. Delete gh-pages on origin if it exists (ignore error if not present)
git push origin --delete gh-pages 2>$null

# 5. Recreate gh-pages from main
git checkout -b gh-pages

# 6. Remove everything tracked
git rm -rf .

# 7. Create the folder for Option 1 deployment
$repoFolder = "INFO-H515"  # folder name must match your base_url
New-Item -ItemType Directory -Force -Path $repoFolder

# 8. Copy built site into the subfolder
Copy-Item -Recurse _build/html/* $repoFolder\

# 9. Commit and push
git add .
git commit -m "Deploy Jupyter Book into $repoFolder subfolder"
git push origin gh-pages

# 10. Return to main
git checkout main

Write-Host "✅ gh-pages branch recreated and site deployed successfully into '$repoFolder'!"