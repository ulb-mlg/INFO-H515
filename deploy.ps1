# deploy.ps1
# Windows PowerShell script to build and deploy a Jupyter Book 2.x site to gh-pages

# 1️⃣ Make sure we're on main
$branch = git branch --show-current
if ($branch -ne "main") {
    Write-Error "You must run this script from the 'main' branch. Current branch: $branch"
    exit 1
}

# 2️⃣ Activate virtual environment
$venvPath = ".\.venvH515\Scripts\Activate.ps1"
if (Test-Path $venvPath) {
    Write-Host "Activating virtual environment..."
    & $venvPath
} else {
    Write-Warning "Virtual environment not found at $venvPath. Make sure Jupyter Book is installed."
}

# 3️⃣ Clean old builds
Write-Host "Cleaning previous builds..."
jupyter-book clean
if ($LASTEXITCODE -ne 0) {
    Write-Error "Clean failed. Aborting."
    exit 1
}

# 4️⃣ Build HTML strictly
Write-Host "Building Jupyter Book..."
jupyter-book build --html --strict
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed. Aborting."
    exit 1
}

# 5️⃣ Delete gh-pages branch locally if exists
git branch -D gh-pages 2>$null

# 6️⃣ Delete gh-pages branch on origin if exists (ignore errors)
git push origin --delete gh-pages 2>$null

# 7️⃣ Recreate gh-pages branch from main
git checkout -b gh-pages

# 8️⃣ Remove all tracked files (source files)
git rm -rf .

# 9️⃣ Copy built site to root of gh-pages
$buildPath = "_build/html"
if (-Not (Test-Path $buildPath)) {
    Write-Error "Build directory '$buildPath' not found. Aborting."
    exit 1
}

Write-Host "Copying built site to gh-pages root..."
Copy-Item -Recurse -Force "$buildPath\*" .

# 10️⃣ Commit and push
git add .
git commit -m "Deploy Jupyter Book 2.x site"
git push -u origin gh-pages -f

# 11️⃣ Switch back to main
git checkout main

Write-Host "✅ gh-pages branch deployed successfully!"
Write-Host "Your site should now be live at https://ulb-mlg.github.io/INFO-H515/"