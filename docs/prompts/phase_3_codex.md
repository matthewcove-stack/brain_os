# Codex Phase Prompt — Phase 3 (URL + file capture MVP)

You are implementing **Phase 3 only** as defined in `brain_os/docs/phase_plans/phase_3.md`.

## Goal
Add URL capture and MVP file capture to the voice client and pipeline.

## Repos / edit map
- lambic_voice_client/apps/web/src (file input, packet fields for attachment)
- intent_normaliser/app (route URL/file packets to note capture)
- notion_gateway (notes capture workflow verification only)
- tests under intent_normaliser/tests

## Implementation tasks
1) Client:
   - Add file picker / drag-drop.
   - For text-like files, read as text and include in packet fields. For non-text, include metadata only.
   - Ensure existing audio/text flow still works.

2) Normaliser:
   - Detect URLs in natural_language and/or explicit fields.url(s).
   - Detect fields.attachment metadata.
   - Route to capture_note and add tags accordingly (url/file).
   - Build useful note content with metadata.

3) Tests:
   - URL inference routes to capture_note with tag url.
   - Text attachment routes to capture_note with tag file and includes text in content.

## Verification
- Paste a URL and confirm a note appears with the URL and tags.
- Drop a .txt file and confirm note contains file content.
- Drop a .pdf file and confirm placeholder note created.

## Mandatory enforcement (Drift Guard MCP)
Call:
- repo_contract_validate()
- verify_run(profile="default")
- drift_check()
Include JSON outputs in final report.
