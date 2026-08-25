# Nexus page setup: permissions, credits and licence

This applies to **all** the 1.7.99 patches in this series, not just this one. They all statically
link CommonLibSSE-NG 6.7.0, so they are all **GPL-3.0-or-later**.

## Formatting: Nexus uses BBCode, not Markdown

`02-full-description.bbcode.txt` is already written in Nexus's BBCode. **Paste it as-is** — do not
convert it, and do not paste the `.md` files in this folder (those are notes for you, not for the
page).

Nexus uses a **proprietary BBCode dialect**. Two things about it that trip people up:

- **It does not support tables.** None are used in the description.
- **There is no inline-code tag.** `[code]` is multiline only, so inline code is written as
  `[font=Courier New]like this[/font]` — the same trick the community's Markdown-to-Nexus converter
  uses.

Tags used here, all of them standard on Nexus: `[b]` `[i]` `[size=N]` `[font=Courier New]` `[code]`
`[list]` `[list=1]` `[*]` `[quote]` `[url=]` `[center]`.

**`[size]` scale:** on Nexus, **2 is normal body text**, not 1. The description uses `[size=5]` for
the page title and `[size=4]` for section headings, which matches the convention the community
converter follows (`clamp(6 - heading_level, 2, 5)`). Do not "fix" these to smaller numbers — you
would end up with text smaller than the body.

**Section dividers** are a plain row of `▬` characters rather than a `[line]` tag. That tag is not
in Nexus's documented set, and a row of characters renders correctly no matter what.

### After pasting, hit Preview and check two things

1. The title block is centred. `[center]` is used only twice per description (title and closing
   line). If it shows up as literal text instead of centring, just delete those four tags — nothing
   else depends on them.
2. No literal square-bracket tags are visible anywhere in the body.

If the editor escapes the tags instead of rendering them, look for the editor's BBCode / source
toggle and paste there rather than into the rich-text view.

## The short version

Nexus's permission dropdowns predate open-source licences and don't map onto GPL-3 cleanly. Two
things fix that:

1. Put the real licence in the **Author's instructions** free-text box.
2. Set the dropdowns to be **at least as permissive as GPL-3 requires** — never more restrictive.

This is exactly what Exit-9B and JPSteel2 already do on their own pages ("This project is licensed
under the MIT License" in Author's instructions).

## Author's instructions — paste this

```
This patch is licensed under the GNU General Public License v3.0 or later, with the
Modding Exception and GPL-3.0 Linking Exception granted by CommonLibSSE-NG.

Source code: https://github.com/Juan-MZ/DragonbornsBestiary-1.7.99-Patch

Why GPL-3: the DLL statically links CommonLibSSE-NG 6.7.0, which is GPL-3.0-or-later,
so the combined work has to be GPL-3 as well.
JPSteel2's original mod is already GPL-3.0, so there is no change in licence here at all.

The complete corresponding source is published in the repository linked above,
as GPL-3 section 6(d) allows.
```

## Permission dropdowns

GPL-3 §7 forbids adding restrictions on top of the licence, so options that *require* credit are
technically stricter than the licence allows. Ask for credit in the description instead — people
give it anyway.

| Setting | Set it to | Why |
|---|---|---|
| **Other user's assets** | *Assets belong to the author or are free-to-use* | The DLL is your build of JPSteel2' code plus GPL/BSD libraries, all credited |
| **Upload permission** | ✅ **Allowed** (ideally without the credit requirement) | GPL-3 explicitly permits redistribution anywhere |
| **Modification permission** | ✅ **Allowed** (ideally without the credit requirement) | GPL-3 explicitly permits modification and release |
| **Conversion permission** | ✅ Allowed | GPL-3 permits it |
| **Asset use permission** | ✅ Allowed | GPL-3 permits it |
| **Assets in mods being sold** | ✅ Allowed | **GPL-3 permits commercial use.** Forbidding it contradicts the licence |
| **Assets earning Donation Points** | ✅ Allowed | No conflict |

> If a "without credit" variant isn't offered for a given dropdown, pick the permissive option that
> exists and let the Author's instructions carry the actual terms. The licence text is what governs.

## File credits — fill this in

Credits in the long description are good, but Nexus also has a dedicated **File credits** field,
and that is where people and moderators look. Paste:

```
JPSteel2 — creator of The Dragonborn's Bestiary. The mod is entirely their work.
Nozomu Katō — SRELL regex library (BSD).
meh321 — Address Library for SKSE Plugins.
CharmedBaryon, alandtse, powerof3, Ryan-rsm-McKenzie — CommonLibSSE-NG.
The SKSE team — SKSE64.
```

## Donation Points

Consider leaving the mod **not opted in**. The description says you want nothing out of this;
opting in contradicts it, and the work is overwhelmingly the original author's.

## Files to upload

| File | Role |
|---|---|
| `*-Compatibility-Patch.zip` | Main file. Contains the DLL plus `Docs/` with the GPL-3 text, the CommonLibSSE-NG exceptions, the upstream licence and the notice of changes |
| `symbols/*.pdb` | Optional file. Only useful for crash logs |
| Source | Not a Nexus upload. GPL-3 §6(d) lets you offer the corresponding source from a designated place — that is the GitHub repo, which the archive and the page both link |
