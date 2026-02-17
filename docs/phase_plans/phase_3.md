# Phase 3 — URL + file capture (MVP)

## Outcomes
1. Paste a URL and it is captured as a Note in Notion.
2. Drop a text-like file and its contents are captured as a Note.
3. Drop a binary file and the system captures a safe placeholder note (no binary storage yet).

## Scope
### In
- Client: file picker / drag-drop.
- Client: include file metadata and (for text files) extracted text.
- Normaliser: detect URL/file fields and route to note capture.
- Notion: store in Notes DB with tags.

### Out
- Storing binaries in Notion or object storage (Phase 4+).
- PDF OCR, image OCR.
- Web scraping / readability extraction (optional Phase 3.1).

## Suggested data model (MVP)
For URL capture:
- Note title: derived from provided title or first 80 chars
- Content:
  - URL
  - optional user comment
- Tags: ["url"]

For file capture:
- Note title: "File: <filename>"
- Content:
  - filename, mime, size, sha256
  - if text extracted: include as fenced block
- Tags: ["file"]

## Implementation notes
### lambic_voice_client
- Add file input.
- For text-like mime types, read as text in browser and attach to packet fields:
  - fields.attachment = { filename, mime, size, sha256, text? }
- For non-text, omit binary; include metadata only.

### intent_normaliser
- If fields contain URL(s) or attachment metadata:
  - route to capture_note
  - include tags ["url"] or ["file"]
  - include structured metadata at top of content

### notion_gateway
- Notes capture already exists; ensure it supports tags multi-select.

## Verification
- Paste a URL and confirm note is created with tag url.
- Drop a .txt and confirm note contains file contents.
- Drop a .pdf and confirm placeholder note created (no crash).
