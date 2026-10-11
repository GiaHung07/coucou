# Maintaining the Vietnamese (`vi`) localization

Coucou's UI is translated from a single table keyed by the English text. Adding
or updating Vietnamese means touching the **sources**, never the generated file.

## Where strings live

| File | Holds | Edit? |
|---|---|---|
| `NotchBuddy/Resources/Localizable.xcstrings` | the Mac catalog — source of truth for every platform | **yes** |
| `windows/src/i18n/extra.json` | strings only Windows/Linux show | **yes** |
| `windows/src/i18n/strings.json` | derived from the catalog | **no — generated** |

## Add or fix a `vi` string

1. **Shared string.** In `Localizable.xcstrings`, find the entry and add a `vi`
   localization next to the others (same `%@` / `%lld` specifiers as English):
   ```json
   "vi": { "stringUnit": { "state": "translated", "value": "…" } }
   ```
2. **Windows/Linux-only string.** In `extra.json`, add `"vi": "…"` to the entry
   (placeholders are `{name}`, `{0}`, `{count}`…).
3. **Regenerate** and check:
   ```
   cd windows
   node scripts/gen-strings.mjs          # rewrites strings.json
   node scripts/gen-strings.mjs --check  # must print "up to date"
   npm test
   ```

## Rules

- Keep every placeholder **exactly** (`{name}`, `{0}`, `%lld`…), and keep the
  leading/trailing space some keys carry (they are concatenated).
- Keep loanwords as-is: *pill, hook, notch, island, relay, agent, model, token*,
  and product names. Distinguish **môi trường desktop** from **màn hình**.
- A string the Mac catalog has **must not** also be in `extra.json`
  (`extra.json never shadows a string of the Mac's` test).

## Language lists (only when first adding a language)

`windows/src/i18n/i18n.ts`, `windows/src-tauri/src/i18n.rs` and
`windows/scripts/gen-strings.mjs` each list the shipped languages; `vi` is
already there. The macOS picker is `NotchBuddy/Sources/App/SettingsView.swift`.

## Coverage

`strings.json` (401 entries) and `extra.json` (346 entries) each carry `vi`,
plus the 10 original languages. The Windows/Linux UI and the shared macOS
strings are translated; the **Android app** (`android/i18n/`) is a separate
catalog and is **not** part of this localization.
