param()

$ErrorActionPreference = 'Stop'

$baseUrl = $env:INTENT_BASE_URL
if (-not $baseUrl) {
  $baseUrl = 'http://localhost:8000'
}

$token = $env:INTENT_SERVICE_TOKEN
if (-not $token) {
  $token = 'change-me'
}

$requestId = '2f4cf4c1-7b79-4d24-9bfa-1e2a4b4d6f3e'
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$title = "Phase 1 smoke test $timestamp"

$payload = @{
  kind = 'intent'
  intent_type = 'create_task'
  request_id = $requestId
  natural_language = "Create a task: $title"
  fields = @{
    title = $title
  }
}

$headers = @{
  Authorization = "Bearer $token"
  'Content-Type' = 'application/json'
}

$bodyJson = $payload | ConvertTo-Json -Depth 6

try {
  $response1 = Invoke-RestMethod -Method Post -Uri "$baseUrl/v1/intents" -Headers $headers -Body $bodyJson
} catch {
  throw "First request failed: $($_.Exception.Message)"
}

$notionTaskId1 = $null
if ($response1.details -and $response1.details.notion_task_id) {
  $notionTaskId1 = [string]$response1.details.notion_task_id
}

if (-not $notionTaskId1) {
  throw "Missing notion_task_id in first response (expected response.details.notion_task_id)."
}

try {
  $response2 = Invoke-RestMethod -Method Post -Uri "$baseUrl/v1/intents" -Headers $headers -Body $bodyJson
} catch {
  throw "Second request failed: $($_.Exception.Message)"
}

$notionTaskId2 = $null
if ($response2.details -and $response2.details.notion_task_id) {
  $notionTaskId2 = [string]$response2.details.notion_task_id
}

if (-not $notionTaskId2) {
  throw "Missing notion_task_id in second response (expected response.details.notion_task_id)."
}

if ($notionTaskId1 -ne $notionTaskId2) {
  throw "Idempotency check failed. First notion_task_id='$notionTaskId1', second notion_task_id='$notionTaskId2'."
}

Write-Host "Phase 1 smoke test succeeded. notion_task_id=$notionTaskId1"
