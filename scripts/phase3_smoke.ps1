$ErrorActionPreference = "Stop"

function Assert-Ok($name, $response) {
  if (-not $response -or $response.StatusCode -lt 200 -or $response.StatusCode -ge 300) {
    throw "Smoke check failed: $name"
  }
  Write-Host "[ok] $name -> $($response.StatusCode)"
}

Write-Host "Running BrainOS Phase 3 smoke checks..."

$voiceApi = Invoke-WebRequest -Uri "http://localhost:8787/healthz" -Method GET
Assert-Ok "voice_api healthz" $voiceApi

$voiceWeb = Invoke-WebRequest -Uri "http://localhost:8088/healthz" -Method GET
Assert-Ok "voice_web healthz" $voiceWeb

$normaliser = Invoke-WebRequest -Uri "http://localhost:8000/health" -Method GET
Assert-Ok "intent_normaliser health" $normaliser

Write-Host "Smoke checks completed."
