# AGENTS.md — SkyWars SEASON 3 (decompiled Roblox game reconstruction)

This file is the authoritative orientation document for any agent (or human) working in this repository. It describes **what this project is**, **how the game works**, **exactly what has been done to it so far**, **what is still missing**, and **the rules you must follow** so you never break the work or get confused about its state.

Read this file fully before doing anything else in the repo.

---

## 1. What this project is

- **Source artifact:** `place 8542259458 SkyWars SEASON 3.rbxlx` (+ `.rbxl` binary), a Roblox game called "SkyWars SEASON 3". The `.rbxlx`/`.rbxl` files sit in the workspace root, **outside** this git repo (they are large; do not commit them).
- **How it was obtained:** saved **client-side** by `UniversalSynSaveInstance` ("Join to Copy Games" executor). Because Roblox `FilteringEnabled` blocks clients from seeing server code, **all server scripts are missing** (see §5).
- **How it was converted to a filesystem:** the directory `src/` was generated with **Rojo 7.7.0 `syncback`** — every Instance in the place became files on disk (`.luau` scripts, `.rbxm` binary model blobs, `.model.json` per-instance JSON, `.meta.json` property files). `default.project.json` maps the Rojo tree; `rojo build` round-trips to the original place (77,589 Instances).
- **The game was originally written in TypeScript** using **Roblox-TS (`rbxts`) + Flamework** (dependency injection, controllers, components, networking), then compiled to Luau and deployed. The decompile therefore contains **compiled Luau** whose original TS identifier names were destroyed by the compiler (locals became `v1`, `p4`, `v_u_4`, `p_u_28`, …). Reconstructing human-readable names/types is the central ongoing task.
- **Git repo:** the git root is the **workspace root** `/home/peter/Documents/skywars-decompile/` (branch `main`), remote `origin` = `https://github.com/coolpeter98/skywars-decompile.git`. The original place files (`.rbxlx`/`.rbxl`) are kept outside the repo.

---

## 2. Repository layout

```
skywars-project/
├── default.project.json      # Rojo project file (maps src/ to the DataModel)
├── README.md                 # original syncback README (provenance, layout, rename_duplicates notes)
├── AGENTS.md                 # this file
├── .game_scripts.txt         # manifest: all 734 game-code scripts (relative paths), 1 per line
├── .game_scripts_remaining.txt # 730 of the above (the 4 pilot files removed)
├── .batch_00 … .batch_04     # 5 split batches of the remaining manifest (164/140/140/145/141)
├── .events_rewrite.txt       # 58 files that had Events["<uuid>"] refs (all rewritten)
├── missing-assets.json       # Asset Delivery-confirmed inaccessible assets with aliases and source references
├── tools/probe_missing_assets.py # Rebuilds missing-assets.json by probing every rbxassetid under src/
└── src/                      # the synced Instance tree
    ├── README.server.luau    # decompiler's readme Script (not game code)
    ├── ReplicatedFirst/      # loading.client.luau (custom teleport loading screen)
    ├── ReplicatedStorage/    # ← the important shared code (see §4)
    ├── ServerStorage/        # EMPTY (server code never saved)
    ├── StarterPlayerScripts/ # ← the client game code (see §4)
    ├── StarterGui/, StarterPack/, Teams/, Workspace/, Light/, … # services & world data
    └── … (other services)
```

### Script count facts (verify with `find`, don't trust stale numbers)

- **Total `.luau`/`.lua` files under `src/`: 1,398** (this is the README's "1,398 scripts").
- Of those, **734 are "game code"** (everything except the `rbxts_include` framework libraries). Breakdown:
  - `ReplicatedStorage/TS/` → **196** (shared client/server modules)
  - `StarterPlayerScripts/TS/` → **490** (client controllers/components/UI)
  - `StarterPlayerScripts/PlayerModule/` → **43** (Roblox default PlayerModule — mostly decompiled to `-- Ignored`, i.e. empty; they are Roblox's built-in camera/control modules, **not game code**)
  - 5 misc: `src/README.server.luau`, `ReplicatedFirst/loading.client.luau`, `StarterPlayerScripts/PlayerScriptsLoader.client.luau`, `StarterPlayerScripts/RbxCharacterSounds/*` (2)
- **664 files are framework libraries** under `ReplicatedStorage/rbxts_include/` (Flamework core/components/networking, ReactLua, LuauPolyfill, rodux, Maid, `@rbxts/services`, etc.). **These were deliberately NOT renamed** — they are third-party compiled packages, not game code. Do not "reconstruct" them.
- Note: `.game_scripts.txt` lists 734 paths **as of the rename pass**; `ReplicatedStorage/TS/event/event-ids.luau` (added later, §6.3) is a 735th file not in the manifest. The `aYZ`/`dYE` `.model.json` files and `rbxts_include` are not in the manifest either (by design).

---

## 3. How the game works — architecture (from client code, authoritative)

Everything in this section was **recovered by reading the client/shared code** (the server is absent). Treat it as ground truth for the client's expectations.

### 3.1 Single-place topology (rewritten from the original multi-place layout)

- The recovered game originally used separate Lobby, SkyWars, Duels, EggWars, and Private PlaceIds. That topology has now been removed: **the lobby and every public game mode run under the current `game.PlaceId`**, using public servers for lobbies and reserved servers for matches.
- `ReplicatedStorage/TS/place/runtime-context.luau` defines the replicated role/game-mode attributes and teleport-data contract. `place-util.luau` reads that runtime context instead of comparing `game.PlaceId` against a hard-coded place registry. `getLobbyId()` and `getGameId()` both intentionally return the current PlaceId.
- A match server recovers its context from a MemoryStore private-server index before players initialize, then validates each arriving player against the match record. Teleport data carries the same role/mode/match identifiers as a compatibility and consistency check.
- Game modes: `TS/game/game-mode.luau` — `SkyWarsSolo/Duos/Trios/Quads/Octos`, `DuelsSolo/Duos`, `EggWarsQuads` with team sizes, max teams, respawn rules, per-position XP tables.
- Queue IDs: `TS/matchmaking/queue-id.luau` — `solo/duos/trios/quads/private/duels_solo/duels_duos/eggwars_quads` + `testing_*` variants.
- Game state machine: `TS/game/game-state.luau` — `Pregame → Countdown → InGame → Ended`.

### 3.2 The client boot path (exact)

1. `StarterPlayerScripts/TS/runtime.client.luau` (LocalScript):
   - requires `ReplicatedStorage.rbxts_include.RuntimeLib`
   - imports `TS/place/place-util`
   - `Flamework._addPaths(...)` for 7 directories: `StarterPlayerScripts/TS/{components, controllers, cosmetics}` and `ReplicatedStorage/TS/{components, cosmetic/cage, modules}`
   - `Flamework.ignite()` then `PlaceUtil.isProduction()`.
   - **Gotcha:** `_addPaths` resolves each path with a timeout-less `WaitForChild` — if any of those directories is missing from the place, the client **hangs before ignite** (not an error).
2. Flamework instantiates all `@Controller` classes (104 files under `StarterPlayerScripts/TS/controllers/`, incl. subdirs `advert/`, `cosmetic-display/`, `crate/`) and `@Component` classes (16 in `StarterPlayerScripts/TS/components/` + 1 `disposable-component.luau` in `ReplicatedStorage/TS/components/`), then runs each controller's `onStart` in its own coroutine.
3. `StarterPlayerScripts/TS/flamework/on-game-start.luau` and `on-lobby-start.luau` are **empty (`return nil`)** — the real lifecycle is `LifecycleController` (fires `LobbyStart`/`GameStart` based on `PlaceUtil`).

### 3.3 Networking contract (the crown jewel — READ THIS)

- All networking is **Flamework networking** (`@flamework/networking`), compiled to **RemoteEvents** (and one RemoteFunction-style flow over a RemoteEvent — Flamework implements functions over RemoteEvents with a request/response protocol, there are **no real `RemoteFunction` instances** and **no `InvokeServer` calls** anywhere).
- **Remote instances live in the place at:**
  - `ReplicatedStorage/aYZ/` — **101 `RemoteEvent` instances**, one per event, filename = UUID, each `.model.json` = `{"className":"RemoteEvent","attributes":{"id":"<uuid>"}}`.
  - `ReplicatedStorage/dYE/` — **1 RemoteEvent** (the "function" namespace), `a8ed47d9-…`.
- **CRITICAL GOTCHA:** remotes are discovered by their **`id` attribute, not their Name**. `createRemoteInstance` (`rbxts_include/node_modules/@flamework/networking/out/event/createRemoteInstance.luau`) does `findByAttribute` (server) / `waitByAttribute` (client). Any server code that recreates them **must `SetAttribute("id", "<uuid>")`** with the exact UUIDs, or clients hang forever waiting.
- **The schema file** `StarterPlayerScripts/TS/events.luau` (~3,300 lines) is the client's compiled networking schema:
  - `incomingIds` (48 UUIDs, server→client) with per-UUID `t`-guard payload validators (`incomingEvents` table),
  - `outgoingIds` (53 UUIDs, client→server; no client-side guards — validated server-side),
  - 1 outgoing function `a8ed47d9-…` returning `tArray(serverListEntryDefinition)` (private-server list).
  - `incomingUnreliable = {}` and `outgoingUnreliable = {}` — **everything is reliable**.
- **The shared contract module** `ReplicatedStorage/TS/events.luau` (16 lines) is just: `GlobalEvents = Networking.createEvent("aYZ")`, `GlobalFunctions = Networking.createFunction("dYE")`.
- **The named access layer (added by us, §6.3):** `StarterPlayerScripts/TS/events.luau` now returns **proxy tables** `Events`/`Functions` so game code reads `Events.PlayerEliminated:connect(...)` / `Functions.GetCustomServers():expect()`. The proxies map names→UUIDs via `ReplicatedStorage/TS/event/event-ids.luau` (102 entries) and fall back to raw UUID keys. **The UUID strings themselves are the wire protocol and must never change.**

### 3.4 The rodux global store (how the server drives the client UI)

- Client state lives in one **rodux store** (`StarterPlayerScripts/TS/ui/rodux/global-store.luau`), whose reducer is `ReplicatedStorage/TS/rodux/rodux.luau` (`GlobalReducer`, combining sub-reducers in `TS/rodux/{inventory,game,queue,profile,screen}-store.luau`).
- **The server pushes state through a single event: `Events.SetValue` (`4e368d35-…`)**. `RoduxController.onStart` (`StarterPlayerScripts/TS/controllers/rodux-controller.luau`) connects it and dispatches every payload straight into the store. `SetValue` is **strictly server→client** (the client's own `setValue` only dispatches locally, never fires the remote).
- **31 store keys** the server can `SetValue` (whitelisted in `events.luau`): `Players, Party, CustomGame, ActiveSlot, Inventory, Chest, ActionBarMap, GameState, GameStateChangeTime, GameSettings, GameTeams, GameStats, PowerUps, BuildConstraints, DuelsScore, IndicatorPosition, GameCurrency, NearbyEgg, Spectating, RespawnTime, TeamUpgrades, Zones, Cooldowns, QueueStartTime, QueueServerAcknowledged, Profile, Friends, FriendIds, Leaderboards, ShowVerify, SelectedShopProductData`.
- Special message variants on the same remote: `@@INIT`, `MoveItem`, `AddActionBar`, `RemoveActionBar`, `UpdateQueue`, `UpdateLeaderboard`.
- Default state is fully client-side (nothing errors if the server never sends anything) — see `TS/rodux/*-store.luau` defaults and `TS/profile/data-profile.luau` (`SharedDataProfileTemplate`: coins, gems, stats per queue, owned passes/products/cosmetics, season, missions, `ProcessedReceipts`, …).

### 3.5 Player attributes & CollectionService tags (server-set, client-read)

- Attribute name constants: `ReplicatedStorage/TS/attribute.luau` (~40 names: `Alive, Spectating, TeamId, Health, Shield, Rank, Level, Wins, Kills, WinStreak, Title, EggId, MapName, LobbyType, CrateId, Simulating, Shooter, DummyTitle, …`). **All client reads are nil-guarded** — UI hides missing values; none error at boot (e.g. `health == nil and 100 or health`).
- Client components attach to instances tagged by the server (Flamework `Component` decorators): tags are `character`, `character:cape`, `billboard`, `crate_advert`, `dog`, `egg`, `generator`, `animate:hover`, `item`, `proximity_prompt`, `purchase`, `quick_shop`, `scavenger_prop`, `season_pass_advert`, `shop` (plus shared `disposable-component`).

### 3.6 What the client waits for at boot (server dependencies)

The client **hangs (not crashes)** on these if the server never provides them:

1. **Remote creation** — client `waitByAttribute` yields forever (warns after 5 s) until the server creates each UUID remote under `ReplicatedStorage/aYZ` (+ `dYE`). **Without server code, the client hangs at the first `Events.<Name>` access.**
2. **Profile replication** — `RoduxController.awaitLoadedProfile()` blocks on `BindableEvent:Wait()` until the server fires `SetValue` with `Key="Profile"`. Awaited in `onStart` of `PlayerSettingsController`, `CameraController`, `ChangelogController`, `AdvertController`, `FeaturedCosmeticsController`, `MatchmakingController`. UI still renders; those features just never initialize.
3. **Character spawn** — `AwaitPlayerRoot`/`AwaitHumanoid` (`StarterPlayerScripts/TS/util/util.luau`) block until the server spawns the character (standard StarterCharacter flow).

Hard **errors** (only occur once the server is active and talking):
- `ContentController.onStart` preloads `ReplicatedStorage.{Skins,Items,Blocks,Misc}` — `table.insert(preloadList, nil)` **errors** if a folder is missing; also requires `Workspace.CurrentCamera` (errors if nil).
- Elimination handler `game-controller.luau` does `gameTeams[player:GetAttribute(TeamId)].AliveCount -= 1` — **errors** if `GameTeams` unset or `TeamId` missing (game servers must set both before eliminations).

### 3.7 Client→server request surface (for writing the server)

Every client-fired event is documented with its payload in the "client→server" map; key ones:
- Queue: `Events.JoinQueue:fire(true, queueGameMode)` / `fire(false)` — server replies `QueueStarted`, `MatchFound`, `GameStarted`, `PlayersPresent`, `GameResult`.
- Economy: `Events.PurchaseProduct` (gems purchase by product id), `Events.PrimeCosmeticPurchase`, `Events.ClaimSeasonPassTier`, `Events.ClaimScavengerProp`, 3 shop events (`ShopPurchaseItem/Upgrade/TeamUpgrade`), `Events.EquipCosmetic`, `Events.EquipItem`, `Events.EquipArmour`, `Events.ItemPickup`.
- World/combat: `Events.PlaceBlock`, `Events.HitBlock`, `Events.MeleeStrike` (+ `MeleeStrikeEntity`), `Events.FireProjectile`, `Events.ActivatePowerUp`, `Events.OpenChest/TakeChestItem/CloseChest`, `Events.UseHeldItem`, `Events.HeldItemChanged`.
- Party/private-match/social: 6 party events, 13 private-match events + `Functions.GetCustomServers` (polled every 10 s by `ui/hooks/use-custom-servers.luau`), `Events.ReportPlayer`, `Events.SendMetrics`, `Events.LoginStreak`, `Events.AcknowledgeUpdateLog`, `Events.RequestLeaderboard` (server answers with `LeaderboardUpdated`), `Events.UpdateSetting`, `Events.SetFirstPerson`, `Events.RequestSpectate`/`SpectateTargetChanged`, `Events.TeleportToHub`/`TeleportToHubInstance`, `Events.SetVerificationOpen`/`RequestVerification`.
- One outgoing UUID has **no fire site** (`46d3e37b-…`, named `LegacyUnusedEvent`) — a legacy/unused remote; keep the mapping entry but don't implement a handler.

### 3.8 Server-only code that is MISSING (do not try to "recover" it)

- **`ServerStorage/` is empty; the original place had no `ServerScriptService`.** The client-side save (FilteringEnabled) made server scripts impossible to save (the decompiler's own `src/README.server.luau` says so verbatim). A newly written server foundation now lives under `src/ServerScriptService/` (§4.4).
- **28 game-code modules decompiled to empty/`return nil`** — server-only or type-only modules. Notably: `TS/communication/communication.luau`, the entire **trade feature** (`TS/trade/trade-state.luau`, `trade-update.luau`, `StarterPlayerScripts/TS/controllers/trade-controller.luau` — no trade UI survives, it's dead on the client), `TS/gems/transaction-type.luau`, `TS/event/player-event.luau`, `TS/tele/tele.luau`, `TS/leaderboard/local-leaderboard.luau`, both `flamework/on-*-start.luau`, `TS/chunk/chunk-shared.luau`, plus small type-only modules (`cosmetic-types.luau`, `bundle-id.luau`, `crate-id.luau`, `title-data.luau`, `update-id.luau`, `lobby-type.luau`, `shop-tab-id.luau`, `text-size.luau`, `name-tag-wip.luau`, `animation-keyframe.luau`, `projectile-animation.luau`, `roblox-constant.luau`, `changelog-util.luau`, `buffer-constant.luau`, `collection-tag.luau`, `play-sound-props.luau`, `item-animation.luau`, `local-leaderboard.luau`, `trade-state.luau`, `trade-update.luau`). **None of these are imported by surviving client code** — they don't affect boot.
- **Zero client references** to `DataStoreService`, `MessagingService`, `ProcessReceipt`, `MemoryStoreService`, raw `RemoteEvent` creation. All persistence/economy is server-side by design.
- **Implemented server layers:** canonical remote resolution/routing, initial profile/party replication, character spawning, MemoryStore matchmaking, and same-place reserved-server teleport/context are present. Remaining priorities are: game-loop/map essentials; `GameSettings`/team/player replication; blocks/chunks (`Workspace.BlockContainer`); inventory/combat authority; richer lobby services; party/private-match behavior; purchases (`MarketplaceService.ProcessReceipt`, gems ledger, `Profile.ProcessedReceipts`); persistence; and FX events.

---

## 4. What has been done to this codebase so far (exact history)

Git history (branch `main`):
1. `f41d533` — **first commit**: the original `rojo syncback` output + `rename_duplicates.py` cleanup (two duplicate instance names in the place were renamed; see `README.md`).
2. `c95344e` — **"Reconstruct decompiled client scripts"**: the big rename pass (below). 3,434 files, +161k lines.
3. `07b82e4` — **"Use named event references"**: the EventIds mapping + proxy + 58-file rewrite (below).

### 4.1 The rename pass (commit `c95344e`)

- **734 game-code scripts** (everything except `rbxts_include` frameworks) were processed by **one subagent per script** (4 pilot files first, then 5 workflow batches of 164/140/140/145/141 agents; the 4 pilots were removed from the manifests afterwards).
- Each agent **renamed every decompiled identifier** (`v\d+`, `p\d+`, `v_u_\d+`, `p_u_\d+`) to a meaningful, human-written name, **added Luau type annotations** where confident, and **removed decompiler artifacts**:
  - the `-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw` header (replaced with a short `-- ModuleName` comment or nothing),
  - all `-- name: X` comments (the X is the original TS identifier — applied as the real name, e.g. `local function v7(p5) -- name: GetHumanoid` → `local function GetHumanoid(player)`),
  - all `-- upvalues: (…)` comments (decompiler noise).
- **Naming standards enforced** (a later normalization pass re-ran batch 00 to fix violations):
  - Roblox services: PascalCase matching the class exactly (`Players`, `Workspace`, `UserInputService`, …).
  - Classes/modules/enums/type aliases: PascalCase (`HotbarController`, `PlaceGroupType`, `type Event = {...}`).
  - Local functions, methods, params, vars: camelCase (`onStart`, `getHeldItemInfo`, `activeSlot`).
  - True constants: UPPER_SNAKE_CASE (`HOTBAR_SIZE`, `POST_GAME_LOBBY_ENABLED`).
  - Names from `-- name:` comments keep their original casing verbatim (exported util functions like `GetHumanoid`, `AwaitPlayerRoot` stay PascalCase).
  - Loop vars `i/j/k`; `self` stays `self`; ignored params `_`; no single-letter names otherwise; no underscores except UPPER_SNAKE_CASE constants.
- **Behavior is byte-identical**: only identifiers, comments, and type annotations changed. Require/import paths, string literals (incl. Flamework dependency ids like `"1LA"` and UUIDs), numbers, returned-module table **keys** (`return { ["Event"] = Event }`), Roblox API calls, and Instance/attribute names were all preserved.
- **Validation:** 0 leftover `v/p`-pattern identifiers in all 734 files; 0 stylua parse errors; spot-reads confirmed quality.

### 4.2 The event-name pass (commit `07b82e4`)

- **New module:** `ReplicatedStorage/TS/event/event-ids.luau` — canonical `EventIds` table, **102 entries** (48 incoming + 53 outgoing events + 1 function), name → UUID, generated by `.gen_event_ids.py` (workspace root, not in repo) with automated coverage checks. Every UUID referenced by code or listed in the schema is mapped; `LegacyUnusedEvent` (`46d3e37b`) is the known-unused one.
- **`StarterPlayerScripts/TS/events.luau`** now:
  - imports `EventIds`,
  - keeps the full compiled schema (UUID lists + `t` guards) **untouched**,
  - builds `local rawEvents` / `local rawFunctions` via `createClient`,
  - returns **proxy tables** `Events`/`Functions` whose `__index` resolves `EventIds[key] or key` — so `Events.PlayerEliminated` works **and** raw `Events["<uuid>"]` still works (fallback).
- **58 files rewritten** (one subagent per file, manifest `.events_rewrite.txt`): all **178 `Events["<uuid>"]`** references + the **1 `Functions["<uuid>"]`** call became `Events.<Name>` / `Functions.GetCustomServers`.
- **Validation:** 0 raw `Events["uuid"]`/`Functions["uuid"]` refs remain outside `events.luau`; 0 parse errors; spot-reads show `Events.QueueStarted:connect(...)`, `Events.JoinQueue:fire(true, gameMode)`, `Functions.GetCustomServers():expect()`.

### 4.3 Files deliberately NOT touched

- All 664 files under `ReplicatedStorage/rbxts_include/` (framework libraries).
- `ReplicatedStorage/aYZ/*.model.json` and `ReplicatedStorage/dYE/*.model.json` (the remote instances — protocol contract).
- `StarterPlayerScripts/PlayerModule/**` (Roblox default PlayerModule; mostly `-- Ignored` stubs).
- The 28 stripped/`return nil` modules (nothing imports them).

### 4.4 Runtime repair session (commits `2098bbc`..`a4b9373`)

The client was brought from "hangs at Flamework boot" to a fully interactable lobby in Studio. Highlights:

- **Framework repair (replaced with npm originals, never patched):** the decompiled `rbxts_include` had 19 truncated files; the worst was `@flamework/core/out/flamework.luau` (killed the whole boot). Replaced: Flamework core+components with the prebuilt `@flamework/*@1.3.2` npm output (its emit is compatible with the shipped RuntimeLib import protocol); the whole `@rbxts/ReactLua` subtree with `@rbxts/react-vendor@17.2.3`'s `react-lua.rbxmx` (extracted with the Rojo folder/init convention); `@rbxts/react` shim with `@rbxts/react@17.2.3` compiled output; `ReactRedux/utils/Subscription.luau` with `@rbxts/react-redux@0.1.0-ts.1`; `@rbxts/maid` with `@rbxts/maid@1.1.0`; topbar-plus with `@rbxts/topbar-plus@3.0.2`. `profileservice` + `raycast-hitbox` remain decompiled-broken but are never required by any code path.
- **Game-code fixes:** `__set_list` decompiler helper restored to 11 files (the rename pass dropped its definition); 3 decompiler-invented `goto`/label blocks restructured (this Luau build rejects labels entirely); `TS/ui/components/size` re-export restored (the only module syncback lost — verified by a 3,760-import resolution audit); `leaderboard-controller` uses `Reflect.decorate` like every other controller; **five self-referential single-statement table constructors split into two-step form** — this Roblox Luau build captures `local X = { f = function() return X.g() end }` upvalues as nil at call time (verified empirically in a live LocalScript); advert-billboard's lost countdown update restored; `tween-util.restoreTween` reads the fadeOutAsync group's `PropertyMap` (decompiler dropped it); cage-display `equip` nil-guards a missing cosmetic.
- **Lobby mapping + topbar:** servers default to the lobby runtime role, including unsaved Studio places; TopbarPlus icons never furl in Studio, keeping the settings gear visible and clickable while preserving TopbarPlus's native alignment with the Roblox topbar.
- **Server foundation:** `src/ServerScriptService/Server.server.luau` starts modular remote routing, validation, player sessions, outbound replication, and subsystem handler extension points under `ServerScriptService/server/`. It resolves the canonical UUID remotes by `id`, covers all 53 client→server events and `GetCustomServers`, deep-copies the default profile per player, uses bounded idempotent bootstrap retries, and loads characters. Matchmaking is implemented; persistence, purchases, parties, inventory, combat, and private-session gameplay remain user-owned.
- **MemoryStore matchmaking + single-place transfer:** `server/matchmaking/` contains strict-Luau configuration, MemoryStore access, runtime-context, and orchestration modules. Parties enter as atomic tickets; cancellation/stale/duplicate records are filtered through a hash map; short per-mode coordinator leases serialize queue consumption; matches fill to capacity or start at the mode minimum after a bounded wait; and origin servers transfer their local parties to one reserved server of the current PlaceId. Match/private-server records use short TTLs and bounded retry backoff. Unpublished Studio sessions use an isolated in-memory adapter because Roblox rejects MemoryStore access there.
- **RbxCharacterSounds:** restored the official default LocalScript source and reimplemented the default `AtomicBinding` module (the decompiled stubs returned no value and errored at require).
- **Known remaining noise (environment, not code):** sound/animation assets owned by the original universe fail to load in an unpublished place (`User is not authorized` / `serverplaceid=0`); "Unknown class UIInlineLayout" warnings come from Studio-side instance data. Both disappear in a published place.

---

## 5. Current status & known gaps

- **Done:** full rename + types on 734 scripts; named event access; **the client boots in Studio and shows a fully interactable lobby UI**; all eight public modes share one PlaceId and route through MemoryStore-backed matchmaking/reserved servers; character spawn + profile replication are provided by the server foundation (§4.4).
- **Open / planned:**
  - Flamework controller dependency ids — `Flamework.resolveDependency("1LA")` strings could be replaced with named constants (same pattern as event rename). Known id→controller map exists (e.g. `zG`=Rodux, `lB5`=Screen, `Xlg`=Content, `7xl`=PlayerSettings, `rB8`=Game, `yAg`=ABTest, `jL9`=Sound, `MMv`=Matchmaking, `1LA`=Spectator, `x5`=Team, …) but is incomplete/unverified.
  - `SetValue` store `Key` strings → named access (same pattern).
  - **Domain services:** matchmaking and session plumbing are present, while parties, persistence, purchases, inventory, combat, game rounds/maps, and private-session behavior remain intentionally incomplete extension points for the user (per §3.8 priority list).
  - Runtime testing loop: Rojo 7.7.0 occasionally crashes on file replacement (see §8); when Studio's Rojo plugin is disconnected, sync files through the MCP HTTP bridge instead.
- **Known behavioral quirk preserved intentionally:** `AwaitHumanoid` in `StarterPlayerScripts/TS/util/util.luau` has a duplicated nil-check from the decompile — kept byte-identical on purpose.
- **Known environment noise (not code):** in an unpublished Studio place, the original universe's sound/animation assets fail to load (`User is not authorized` / `serverplaceid=0` spam). The lobby UI is unaffected.

---

## 6. Working rules & gotchas (READ BEFORE EDITING)

1. **Never change UUID strings.** They are the wire protocol: schema lists in `events.luau`, `id` attributes in `aYZ`/`dYE` `.model.json` files, and the values in `event-ids.luau` must stay identical. Re-keying them is possible in theory (client↔new-server consistency is all that matters) but pointless: meaning is already recovered in `EventIds`.
2. **Never patch `rbxts_include/` by hand** — it's third-party compiled code. If a framework file is broken (decompiler truncation), replace it with the original compiled output from npm (see §4.4) rather than editing it.
3. **Never rename returned-module table keys** (`return { ["Event"] = Event }`): other files access modules by those keys (e.g. `require(...).Items`). Renaming a key breaks cross-file references.
4. **Keep behavior identical** in any reconstruction: logic, control flow, string literals, numbers, require/import paths, Roblox API calls, Instance/attribute names. Only identifiers, comments, and (additive) type annotations may change. (The §4.4 fixes are deliberate exceptions: they restore behavior that the decompiler/rename pass broke, each documented in its commit.)
5. **Remotes are found by `id` attribute, not Name** — any server-side recreation must `SetAttribute("id", "<uuid>")`.
6. **Luau, not TypeScript.** The original was TS; the user explicitly wants Luau output with Luau type annotations (`: number`, `type X = {...}`, `-> ()`). Never "convert back" to TS.
7. **Use tabs for indentation** (decompiler style, stylua default).
8. **Verify before/after editing:** `stylua --check <file>` must not report a parse error (formatting diffs alone are fine); `grep -nE '\b(v|p)[0-9]+\b|\b(v|p)_u_[0-9]+\b' <file>` must return nothing after a rename pass. **Run stylua with `syntax = "Luau"`** (`stylua.toml` or `--config-path`), otherwise Luau-only syntax (generics `>>`, if-expressions) fails the Lua 5.3 parser.
9. **Manifests:** `.game_scripts.txt` = the 734 game scripts (the authoritative list of "game code"); `.events_rewrite.txt` = the 58 event-rewritten files. The batch files are stale historical artifacts — do not trust them as current work queues.
10. **PlayerModule** files are Roblox defaults, not game code — don't waste effort reconstructing them.
11. **Luau upvalue gotcha (current Roblox builds):** `local X = { f = function() return X.g() end }` captures `X` as nil when `f` runs; split into `local X = nil; X = { ... }`. Also, Roblox Luau rejects `goto`/labels entirely — never reintroduce them.

---

## 7. Key files index (start here when exploring)

| Path | What it is |
|---|---|
| `ReplicatedStorage/TS/event/event-ids.luau` | Canonical name↔UUID mapping (102 entries) — the readable networking contract |
| `StarterPlayerScripts/TS/events.luau` | Client networking schema + named `Events`/`Functions` proxies (~3,300 lines) |
| `ReplicatedStorage/TS/events.luau` | Shared contract: `createEvent("aYZ")`, `createFunction("dYE")` (16 lines) |
| `StarterPlayerScripts/TS/runtime.client.luau` | Flamework client bootstrap (`_addPaths` + `ignite`) |
| `StarterPlayerScripts/TS/controllers/rodux-controller.luau` | SetValue → store bridge; `awaitLoadedProfile` gate |
| `StarterPlayerScripts/TS/ui/rodux/global-store.luau` | The rodux store + selector hooks |
| `ReplicatedStorage/TS/rodux/rodux.luau` | GlobalReducer + combined default state |
| `ReplicatedStorage/TS/place/place-util.luau` | Single-place runtime role / game-mode detection |
| `ReplicatedStorage/TS/place/runtime-context.luau` | Replicated server-role attributes + teleport context contract |
| `ServerScriptService/server/matchmaking/` | MemoryStore tickets, coordinator leases, match records, reserved-server transfer |
| `ReplicatedStorage/TS/profile/data-profile.luau` | Full profile schema (server must populate this shape) |
| `ReplicatedStorage/TS/attribute.luau` | All player/instance attribute name constants |
| `ReplicatedStorage/TS/items…` (Items/Skins/Blocks/Misc/Cosmetic/Crate dirs) | Content the client preloads and cosmetics catalog |
| `StarterPlayerScripts/TS/controllers/` (104 files) | All client controllers (one per game system) |
| `StarterPlayerScripts/TS/ui/` | ReactLua UI screens/hooks |

---

## 8. Environment & tooling

- Workspace root: `/home/peter/Documents/skywars-decompile/` = the git repo root (branch `main`, remote `origin` = GitHub `coolpeter98/skywars-decompile`). Commit via `git -c user.name="skywars-recon" -c user.email="recon@local" commit …` or normal git identity.
- `stylua` is available for parse checks/formatting (supports Luau types); use `syntax = "Luau"` (see §6.8).
- `rojo serve` live-syncs `default.project.json` into Roblox Studio. **Known issue:** Rojo 7.7.0 sometimes crashes on file replacement (change-processor panic); restart it and verify Studio actually received changes. When the Rojo plugin is disconnected, sync files through the MCP bridge: a local `python3 -m http.server 8765` serving the repo + `execute_luau` with `HttpService:GetAsync("http://127.0.0.1:8765/<path>")` to write `ModuleScript.Source` (set `HttpService.HttpEnabled = true` first).
- Helper scripts in workspace root (NOT in git): `.gen_event_ids.py` (regenerates `event-ids.luau` from its embedded mapping + verifies coverage), `.workflow_rename.js` / `.workflow_event_rewrite.js` (the per-file agent fan-out prompts, parameterized by `args.manifest/start/count`), plus the batch manifests. If you need to re-run a fan-out, reuse these scripts and the manifest files.
- Agent fan-out pattern used throughout: one subagent per file, prompt embedded in a workflow script, manifest line → `sed -n '<N>p' <manifest>` to get the target path; agents verify with stylua + grep before reporting.

---

## 9. Frequently asked questions (avoid re-asking)

- **"Why are the remotes still UUIDs?"** — Flamework compiles event names to deterministic UUIDs; they are the wire protocol (schema + `id` attributes). We quarantined them to `event-ids.luau` + the schema; game code never sees them.
- **"Can we recover the server code?"** — No. Client-side save under FilteringEnabled; `ServerStorage` empty, `ServerScriptService` absent. Only the client's view of the API contract survives. Writing the server is building new code against that contract, not recovery.
- **"Why are some modules `return nil`?"** — They were server-only or type-only modules; nothing in the surviving client imports them. Leave them.
- **"Is the game playable right now?"** — The lobby is playable locally: the server foundation provides profile replication + character spawn, so the client boots to a fully interactable lobby UI (play button, party section, settings, shop/missions/locker, sidebar). Matchmaking, persistence, purchases, and other domain behavior still need implementation (§5).
- **"Where are the pilot files?"** — `ReplicatedStorage/TS/event/event.luau`, `StarterPlayerScripts/TS/util/util.luau`, `StarterPlayerScripts/TS/controllers/hotbar-controller.luau`, `StarterPlayerScripts/TS/controllers/block-raycast-controller.luau` — the first 4 files renamed; they set the quality bar.
