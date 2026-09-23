# Instala os hooks de git do projeto em .git/hooks
# Uso: powershell -ExecutionPolicy Bypass -File scripts/git-hooks/install.ps1
# (ou: ./scripts/git-hooks/install.ps1 no pwsh)

$ErrorActionPreference = "Stop"
$repoRoot = git rev-parse --show-toplevel
if ($LASTEXITCODE -ne 0) { Write-Error "Nao e um repo git." }

$hookDir = Join-Path (Join-Path $repoRoot ".git") "hooks"
$sourceDir = Join-Path (Join-Path $repoRoot "scripts") "git-hooks"
$hooks = @("pre-commit", "commit-msg", "pre-push")

if (-not (Test-Path (Join-Path $sourceDir "pre-commit"))) {
  Write-Error "Arquivos de hooks nao encontrados (procure por scripts/git-hooks/ no repo)."
}

foreach ($hook in $hooks) {
  $src = Join-Path $sourceDir $hook
  $dst = Join-Path $hookDir $hook

  if (Test-Path $dst) {
    $existing = Get-Content $dst -Raw
    $ours = Get-Content $src -Raw
    if ($existing -eq $ours) {
      Write-Host "= $hook ja instalado (identico)."
    } else {
      $backup = "$dst.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
      Copy-Item $dst $backup
      Write-Host "o $hook existente diferente - backup em $backup"
      Copy-Item $src $dst
      Write-Host "  instalado novo hook."
    }
  } else {
    Copy-Item $src $dst
    Write-Host "+ $hook instalado."
  }
}

Write-Host ""
Write-Host "Hooks instalados: pre-commit (dart format), commit-msg (Conventional Commits), pre-push (analyze + test)."