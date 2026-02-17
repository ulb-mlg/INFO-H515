# deploy.ps1
# Build Jupyter Book on main, delete gh-pages, recreate it from main, deploy site

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

# 6. Remove everything tracked (there will be source files at this point)
git rm -rf .

# 7. Copy built site to repo root
Copy-Item -Recurse _build/html/* .

# 8. Commit and push
git add .
git commit -m "Deploy Jupyter Book"
git push origin gh-pages

# 9. Go back to main
git checkout main

Write-Host "✅ gh-pages branch recreated and site deployed successfully!"