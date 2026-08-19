# SkyWars SEASON 3 — Rojo project (decompiled via `rojo syncback`)

This directory is a full filesystem representation of the game
`place 8542259458 SkyWars SEASON 3.rbxlx`, generated with Rojo 7.7.0's
`syncback` command. Every Instance in the place is preserved: **all 1,398
scripts** (1,393 ModuleScripts, 4 LocalScripts, 1 Script) are on disk as
individual `.luau` / `.client.luau` / `.server.luau` files, and everything
else is kept as `.rbxm` model blobs, `.model.json` files, directories, and
`.meta.json` property files.

Round-trip check: `rojo build` of this project reproduces a place with
**77,589 Instances and an identical class distribution** to the original.

## Layout

- `default.project.json` — Rojo project file. Each top-level service maps to
  `src/<Service>`; `StarterPlayerScripts` maps to `src/StarterPlayerScripts`
  (see below); the top-level `README` Script maps to `src/README.server.luau`.
  Non-default service properties were written into the project nodes by
  syncback.
- `src/` — the synced instance tree:
  - `src/ReplicatedStorage/rbxts_include/…` and `src/ReplicatedStorage/TS/…` —
    the compiled TypeScript (rbxts) modules, every module as a `.luau` file.
  - `src/StarterPlayerScripts/…` — the 536 client-side scripts.
  - `src/ReplicatedFirst/loading.client.luau` — the loading LocalScript.
  - `src/README.server.luau` — the top-level `README` Script.
  - `src/Workspace/Lobby.rbxm`, `…/Terrain.rbxm`, `…` — workspace contents that
    are Models/Terrain are stored as single `.rbxm` binary blobs (lossless).

## Why two Instances were renamed

Rojo's filesystem format cannot represent two siblings with the same name
(they would collide on disk), so syncback refuses such places. The original
place file contains exactly two such pairs, both non-script Instances created
by the save tool:

- `Workspace/Folder`: two children named `Sound` → second renamed to `Sound_2`
- `ReplicatedStorage`: two children named `zssssssdss55` (identical rig Models)
  → second renamed to `zssssssdss55_2`

All other duplicate-name children in the file live *inside* Models, which
syncback serializes wholesale into a single `.rbxm` file, so they are
preserved untouched.

`rename_duplicates.py` (in the parent directory) performs exactly these
renames; re-running it reproduces the synced input file:

```sh
python3 rename_duplicates.py \
  "place 8542259458 SkyWars SEASON 3.rbxlx" \
  .tmp/skywars_renamed.rbxlx
```

## How this was generated

```sh
# 1. create the synced input (renames the two duplicate-name pairs above)
python3 rename_duplicates.py "place 8542259458 SkyWars SEASON 3.rbxlx" .tmp/skywars_renamed.rbxlx

# 2. pre-create the target directories (paths must exist for syncback)
mkdir -p src/{Workspace,Players,Lighting,MaterialService,ReplicatedFirst,ReplicatedStorage,ServerStorage,StarterGui,StarterPack,StarterPlayer,Teams,SoundService,Chat,TextChatService,LocalizationService,JointsService,StarterPlayerScripts}
touch src/README.server.luau

# 3. sync the place back to the file system
rojo syncback --input .tmp/skywars_renamed.rbxlx -y .

# 4. rebuild the place from the project (round-trip)
rojo build .
```

## Notes

- Only the `.rbxlx` was used as input. The `.rbxl` (binary) copy is missing
  `JointsService` (a default service the engine auto-creates at runtime), so
  the XML place file is the complete superset.
- Rojo's syncback drops properties that are at their default values or are
  engine-internal (e.g. `FogColor`, `Capabilities`, `SourceAssetId`, `Tags`).
  The engine restores defaults when the place loads, so the rebuilt game is
  equivalent.
# skywars-decompile
