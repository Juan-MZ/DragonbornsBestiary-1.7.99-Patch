# The Dragonborn's Bestiary — 1.7.99 Compatibility Patch

**This is not a mod. It is only the recompiled DLL.**
**It REQUIRES the original mod installed** — [The Dragonborn's Bestiary](https://www.nexusmods.com/skyrimspecialedition/mods/123521) v1.4.0 by JPSteel2.

It ships none of the original author's assets: no `.esp`, no `.ini`, no `.swf`, no translations, no
Papyrus scripts. All of that still comes from the original mod. The only file installed here is a
rebuilt `DragonbornsBestiary.dll`.

**This patch's source:** <https://github.com/Juan-MZ/DragonbornsBestiary-1.7.99-Patch>
**Upstream (JPSteel2's original):** <https://github.com/jpsteel/skyrimbestiary> (last commit 2024-11-26)

The mod is licensed **GPL-3.0**, so the complete corresponding source for this build ships in
`source/complete-source/` and lives in the patch repo above, as GPL-3 requires.
Not affiliated with JPSteel2 or Bethesda.

The mod's permissions explicitly allow modifying and releasing fixes without asking, so no
permission request was needed for this one.

## Who needs this

You are on **Skyrim SE/AE 1.7.99** (the 20 August 2026 update) and the Bestiary throws:

```
REL/Relocation.h(1104): failed to open address library file
```

If you are still on 1.6.x or 1.5.97, you do **not** need this patch — keep using the official
release.

## Requirements

Same as the original mod:

- **The Dragonborn's Bestiary 1.4.0** (the original mod — required)
- SKSE64 **2.3.0** (the 1.7.99 build)
- Address Library for SKSE Plugins (updated — must include `versionlib-1-7-99-0.bin`)
- Whatever the original mod lists (SPID / KID for the distributor `.ini` files, SkyUI)

## Installation

Use **`DragonbornsBestiary-1.7.99-Compatibility-Patch.zip`** as-is, without extracting it.

### Vortex

1. Install the original mod 1.4.0 normally first.
2. Mods tab → *Install From File* → pick the zip → Enable.
3. Vortex will report a **file conflict** with the original mod (both ship the same DLL).
   When prompted, set this patch to *Load After* the original mod so **this patch wins**.

> If you pick the other option, Vortex keeps deploying the old DLL and it will look like the patch
> did nothing.

### Mod Organizer 2

*Install a new mod from an archive*, then place this patch **below** the original mod in the left
pane (in MO2, lower wins).

### Manual

Copy `SKSE\Plugins\DragonbornsBestiary.dll` over the existing one — only if you installed the mod
manually. If you use Vortex or MO2, always go through the manager.

### Verifying it worked

Launch the game. If it reaches the main menu with no error box, it worked. The plugin also writes
`Documents\My Games\Skyrim Special Edition\SKSE\DragonbornsBestiary.log`, which should end with
`Bestiary is in Player's pocket!` and no address library errors.

## What was broken

Skyrim 1.7.99 shipped a new Address Library format (**format 5** — a 96-byte header and a dense
array indexed directly by ID; a 1.7.99 `versionlib-1-7-99-0.bin` starts with the bytes
`05 00 00 00`). The released DLL was built against an older CommonLibSSE-NG that only understands
formats 1 and 2, so it cannot read the file at all. That is the error above.

1.7.99 also recompiled Skyrim and moved several internal structures, which needs an updated
CommonLib to model correctly.

## What was changed

- **Rebuilt against CommonLibSSE-NG 6.7.0** — format 5 support plus the 1.7.99 layouts. The vcpkg
  port in the colorglass registry is still on 3.7.0, so CommonLib is now built from source instead.
- **`NOMINMAX` / `WIN32_LEAN_AND_MEAN`** added. `SimpleIni.h` pulls in `<windows.h>`, whose macros
  broke two things with the newer toolchain: the `max` macro broke
  `std::numeric_limits<size_t>::max()`, and the `PlaySound` macro rewrote `RE::PlaySound` into
  `RE::PlaySoundA`, which does not exist.
- **Plugin declaration written by hand.** CommonLib's `add_commonlibsse_plugin()` helper generates a
  `SKSEPluginInfo()` declaration whose `StructCompatibility` field occupies the same offset as
  `versionIndependenceEx`, so it can only ever write 0 or 1 — it cannot set the Address Library v5
  compatibility flag. The declaration now uses `SKSE::PluginVersionData` directly, so the DLL
  correctly advertises that it can read format 5.

**No feature was added, removed, or redesigned.** The DLL still reports itself as version 1.4.0.

## Verification

- The plugin declares `versionIndependenceEx = 3` (struct-independent + Address Library v5) and
  `versionIndependence = 1` (uses Address Library), confirmed by reading the built DLL's export.
- The mod uses **no** hardcoded offsets: no `RELOCATION_ID`, no `write_call`/`write_branch`, no
  vtable hooks. Every game address it touches is resolved by CommonLib itself, so there was nothing
  mod-specific to re-derive for 1.7.99 — unlike patches for mods that hook mid-function.

**It has not been play-tested in-game.** Back up your save before using this on a main playthrough,
and please report anything odd.

## Building from source

`source/complete-source/` holds the complete corresponding source for this build (GPL-3
requirement). `source/DragonbornsBestiary-1.7.99-compat.patch` is the diff against upstream `main`.

```sh
git clone https://github.com/jpsteel/skyrimbestiary.git
cd skyrimbestiary
git apply ../DragonbornsBestiary-1.7.99-compat.patch
git clone --depth 1 --branch ng https://github.com/alandtse/CommonLibVR.git external/CommonLibNG
set VCPKG_ROOT=<path to vcpkg>
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
  -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake ^
  -DVCPKG_TARGET_TRIPLET=x64-windows-static-md -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL
cmake --build build --config RelWithDebInfo
```

Requires Visual Studio 2022 (or Build Tools) with MSVC v143, Windows SDK 10, CMake and vcpkg.
Built with CommonLibSSE-NG 6.7.0 (commit `3d81614`), MSVC 14.44, Windows SDK 10.0.26100.

`symbols/DragonbornsBestiary.pdb` (full download only) makes crash logs show function names. It is
not needed to play.

## Credits

- **JPSteel2** — creator of The Dragonborn's Bestiary. The mod is entirely their work.
- **meh321** — Address Library for SKSE Plugins.
- **CommonLibSSE-NG** contributors (CharmedBaryon, alandtse, powerof3, Ryan-rsm-McKenzie) — the
  1.7.99 and format-5 support this patch depends on.
- **The SKSE team** — SKSE64.

Made for the community. Nothing asked in return. If JPSteel2 updates the mod, use their version —
this patch only exists so the mod can keep being played in the meantime.
