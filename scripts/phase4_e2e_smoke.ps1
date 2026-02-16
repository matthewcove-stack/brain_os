param(
  [string]$EnvFile = ".env"
)

$ErrorActionPreference = "Stop"

function Get-DotEnvValue {
  param(
    [string]$Path,
    [string]$Key
  )
  if (-not (Test-Path $Path)) {
    throw "Env file not found: $Path"
  }
  $escaped = [regex]::Escape($Key)
  $line = Get-Content $Path | Where-Object { $_ -match "^$escaped=" } | Select-Object -First 1
  if (-not $line) {
    throw "Missing required env key: $Key"
  }
  return ($line -split "=", 2)[1].Trim()
}

function Assert-Status {
  param(
    [string]$Name,
    [int]$Actual,
    [int]$Expected
  )
  if ($Actual -ne $Expected) {
    throw "$Name expected HTTP $Expected but got $Actual"
  }
  Write-Host "[ok] $Name -> $Actual"
}

function Invoke-JsonRequest {
  param(
    [string]$Method,
    [string]$Uri,
    [hashtable]$Headers,
    [object]$Body
  )
  $jsonBody = $Body | ConvertTo-Json -Depth 10 -Compress
  return Invoke-WebRequest -Method $Method -Uri $Uri -Headers $Headers -Body $jsonBody -UseBasicParsing
}

Write-Host "Running BrainOS Phase 4 E2E smoke checks..."

$intentToken = Get-DotEnvValue -Path $EnvFile -Key "INTENT_SERVICE_TOKEN"
$voiceHost = "https://voice.lambiclabs.com"
$voiceApiHost = "https://voice-api.lambiclabs.com"
$intakeHost = "https://intake.lambiclabs.com"

$voiceResp = Invoke-WebRequest -Uri "$voiceHost/healthz" -Method GET -UseBasicParsing
Assert-Status -Name "voice_web healthz" -Actual $voiceResp.StatusCode -Expected 200

$voiceApiResp = Invoke-WebRequest -Uri "$voiceApiHost/healthz" -Method GET -UseBasicParsing
Assert-Status -Name "voice_api healthz" -Actual $voiceApiResp.StatusCode -Expected 200

$intakeResp = Invoke-WebRequest -Uri "$intakeHost/health" -Method GET -UseBasicParsing
Assert-Status -Name "intent_normaliser health" -Actual $intakeResp.StatusCode -Expected 200

$sampleText = "brain_os e2e smoke $(Get-Date -Format 'yyyyMMdd-HHmmss')"
$payload = @{
  kind = "intent"
  schema_version = "v1"
  source = "voice_intake_app"
  natural_language = $sampleText
  target = @{
    kind = "list"
    key = "shopping_list"
  }
  fields = @{
    item = $sampleText
  }
}

$headers = @{
  Authorization = "Bearer $intentToken"
  "Content-Type" = "application/json"
  "X-Actor-Id" = "voice_intake_app"
}

$submitResp = Invoke-JsonRequest -Method POST -Uri "$intakeHost/v1/intents" -Headers $headers -Body $payload
Assert-Status -Name "intent submit" -Actual $submitResp.StatusCode -Expected 200

$submitJson = $submitResp.Content | ConvertFrom-Json
if ($submitJson.status -ne "executed") {
  throw "Expected executed status but got '$($submitJson.status)'"
}

$execResults = $submitJson.details.execution_results
if (-not $execResults -or $execResults.Count -eq 0 -or -not $execResults[0].success) {
  throw "Expected successful execution_results in intent response"
}

Write-Host "[ok] intent executed -> $($submitJson.intent_id)"
if ($submitJson.details.notion_task_id) {
  Write-Host "[ok] notion object id -> $($submitJson.details.notion_task_id)"
}

Write-Host "Phase 4 E2E smoke checks completed."
