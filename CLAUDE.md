# DoctorApp

Flutter web app (Firebase) + n8n/Ollama AI assistant. Overview in README.md.

## Keep README in sync

Any change that adds, removes or changes user-visible behaviour, setup steps, run commands, dependencies or the AI server must update **both** `README.md` (Vietnamese) and `README.en.md` (English) in the same commit. The two files must cover the same content.

- Feature for patients or doctors → the matching table and instructions in "Hướng dẫn sử dụng" / "User guide". Use the exact button labels from `lib/l10n/app_strings.dart` (Vietnamese in README.md, English in README.en.md).
- New package, service or folder → "Công nghệ" / "Tech stack" and "Cấu trúc thư mục" / "Project layout".
- AI workflow or server change → "Trợ lý AI" / "AI assistant" and `n8n/README.md`.

Bug fixes and refactors with no visible change do not need a README update.

## Checks

```
flutter analyze
flutter test
node n8n/test-workflow.cjs
```

New UI strings go through `context.tr()` and need a Vietnamese entry in `lib/l10n/app_strings.dart`.
