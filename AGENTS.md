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

- **The recovered `ServerStorage/` was empty; the original place had no `ServerScriptService`.** The client-side save (FilteringEnabled) made server scripts impossible to save (the decompiler's own `src/README.server.luau` says so verbatim). Newly written server code now lives under `src/ServerScriptService/`, and placeholder-map configuration lives under `src/ServerStorage/Maps/` (§4.4–§4.5).
- **28 game-code modules decompiled to empty/`return nil`** — server-only or type-only modules. Notably: `TS/communication/communication.luau`, the entire **trade feature** (`TS/trade/trade-state.luau`, `trade-update.luau`, `StarterPlayerScripts/TS/controllers/trade-controller.luau` — no trade UI survives, it's dead on the client), `TS/gems/transaction-type.luau`, `TS/event/player-event.luau`, `TS/tele/tele.luau`, `TS/leaderboard/local-leaderboard.luau`, both `flamework/on-*-start.luau`, `TS/chunk/chunk-shared.luau`, plus small type-only modules (`cosmetic-types.luau`, `bundle-id.luau`, `crate-id.luau`, `title-data.luau`, `update-id.luau`, `lobby-type.luau`, `shop-tab-id.luau`, `text-size.luau`, `name-tag-wip.luau`, `animation-keyframe.luau`, `projectile-animation.luau`, `roblox-constant.luau`, `changelog-util.luau`, `buffer-constant.luau`, `collection-tag.luau`, `play-sound-props.luau`, `item-animation.luau`, `local-leaderboard.luau`, `trade-state.luau`, `trade-update.luau`). **None of these are imported by surviving client code** — they don't affect boot.
- **Zero client references** to `DataStoreService`, `MessagingService`, `ProcessReceipt`, `MemoryStoreService`, raw `RemoteEvent` creation. All persistence/economy is server-side by design.
- **Implemented server layers:** canonical remote resolution/routing, initial profile/party replication, character spawning, MemoryStore matchmaking, same-place reserved-server teleport/context, authoritative inventory, authoritative combat, parties, and SkyWars custom games are present. Custom games cover server creation/listing/code admission, party warping, privacy and moderation, teams, settings, placeholder arenas, chests, countdowns, elimination, results, and return-to-lobby flow. Inventory covers initial replication, item grants/removals, client prediction acknowledgement, held tools, armour, world drops/pickups, chest transfers, item/upgrade shop purchases, game-currency derivation, and minimal predicted-block reconciliation. Combat (`server/combat/CombatService.luau`) covers melee (sword) and arrow damage through one shared pipeline: character combat hitboxes (`Hitbox`/`ProjectileHitbox` parts the client's raycast whitelists require), round-state/cooldown/range/line-of-sight/friendly-fire validation, armour mitigation, shield absorption, Health/Shield attribute replication, `DamageDealt` indicators, one universal knockback system (`DamageImpulse`) used by both melee and bows, entity (egg) strikes, elimination kill credit, and `PlayerKilled` kill-feed events. Block breaking (`server/world/BlockWorldService.luau`, §4.7) covers mining player-placed blocks and greedy-meshed map geometry with face re-culling. Remaining priorities include combat power-ups/FX, public-match round orchestration, richer lobby services, developer-product purchases (`MarketplaceService.ProcessReceipt`, gems ledger, `Profile.ProcessedReceipts`), persistence, and FX events.

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
- **Server foundation:** `src/ServerScriptService/Server.server.luau` starts modular remote routing, validation, player sessions, outbound replication, and subsystem handler extension points under `ServerScriptService/server/`. It resolves the canonical UUID remotes by `id`, covers all 53 client→server events and `GetCustomServers`, deep-copies the default profile per player, uses bounded idempotent bootstrap retries, and loads characters. Matchmaking and inventory are implemented; persistence, developer-product purchases, parties, combat, full game rounds/maps, and private-session gameplay remain user-owned.
- **Authoritative inventory:** `server/inventory/InventoryService.luau` mirrors the client's 23-slot layout and upgrade-placement rules, replicates `Inventory`/`ActiveSlot`/`GameCurrency` during bootstrap, acknowledges or reverts prediction UUIDs, validates held tools and armour ownership, renders equipped armour, creates and collects tagged world drops, transfers signed chest quantities, and executes item/gear shop transactions atomically. Inventory replication serializes slot keys as **strings** (`Outbound.sendInventory`): Roblox remote replication drops non-contiguous numeric table keys beyond the dense array part (e.g. a `{[0]=A,[1]=B,[22]=C}` payload arrives as `{[1]=B}` only), which silently deleted swords on better-tier/bow pickups; the client's `RoduxController.normalizeInventoryPayload` converts the string keys back to slot numbers, matching the original game's wire format. `WorldHandlers` also performs the minimal server block creation needed to commit a valid placement prediction; full chunk and breaking authority is still separate work.
- **MemoryStore matchmaking + single-place transfer:** `server/matchmaking/` contains strict-Luau configuration, MemoryStore access, runtime-context, and orchestration modules. Parties enter as atomic tickets; cancellation/stale/duplicate records are filtered through a hash map; short per-mode coordinator leases serialize queue consumption; matches fill to capacity or start at the mode minimum after a bounded wait; and origin servers transfer their local parties to one reserved server of the current PlaceId. Match/private-server records use short TTLs and bounded retry backoff. Unpublished Studio sessions use an isolated in-memory adapter because Roblox rejects MemoryStore access there.
- **RbxCharacterSounds:** restored the official default LocalScript source and reimplemented the default `AtomicBinding` module (the decompiled stubs returned no value and errored at require).
- **Known remaining noise (environment, not code):** sound/animation assets owned by the original universe fail to load in an unpublished place (`User is not authorized` / `serverplaceid=0`); "Unknown class UIInlineLayout" warnings come from Studio-side instance data. Both disappear in a published place.

### 4.5 SkyWars custom games implementation

- **Extensible mode boundary:** `server/custom/modes/ModeRegistry.luau` is the only mode-dispatch layer. `SkyWarsMode.luau` supplies the five SkyWars team layouts, defaults, starter inventory, map configuration, and presentation settings; adding a later mode does not require rewriting the session store or transport layer.
- **Session lifecycle:** `CustomGameService.luau` implements all private-session remotes: create, join by six-character code, leave, start, settings, team changes, owner transfer, kick, ban/unban, public browser listing, and spectator requests. Public/private records and short-lived code claims are stored in MemoryStore in published servers, with an isolated in-memory Studio adapter. Reserved-server identity is recovered before player initialization, and admitted party members are validated on arrival.
- **Party support:** `PartyService.luau` implements invites, accept/decline, promotion, removal, leaving, owner transfer, four-player limits, and `PartyUpdated` replication. Creating or joining a custom game atomically admits and teleports every online member of the creator's or joiner's same-server party.
- **Teams and rounds:** team assignment observes `AllowTeamSelection`, owner authority, membership, and capacity. With team selection enabled, unassigned players remain spectators; zero selected players and single-player rounds are valid. Disabling team selection opts into automatic balancing. The server replicates the client's exact `CustomGame`, `GameSettings`, `GameTeams`, `Players`, `GameState`, and `Spectating` shapes; starts assigned characters on team islands; positions spectators on the active map; tracks alive players and teams; declares a winner after eliminations; publishes `GameResult`; and resets the session for another round.
- **Client lifecycle:** `LifecycleController` observes `CustomGame.ServerData.InGame` even when the client originally booted as a lobby (the Studio local-custom path). Entering a round invokes the existing game-start listeners, closes both `LobbyScreen` and `SidebarScreen`, and mounts the normal health bar/hotbar/scoreboard; private-round spectators do not reopen the lobby advertisement/dock. Returning to pregame invokes the existing lobby-start listeners. Custom creation also cancels any active public queue, and delayed lobby Auto Queue is suppressed after the runtime role becomes `Private`.
- **Maps:** `server/custom/MapService.luau` is the single map layer for custom-game rounds. It prefers **real recovered maps**: a model at `ServerStorage/Maps/SkyWars/<MapName>` (the original game's convention, read by `ReplicatedStorage/TS/game/map/map-info.luau` — e.g. `Airport.rbxm`). A real map is parsed as `WorldData.Spawn` CFrameValue (the anchor — the map is placed so it lands at `MAP_ORIGIN` (0,300,0), then shifted down 1.5 studs because the client's block grid places block bottoms on world Y ≡ 1.5 (mod 3) while the map's build surfaces sit at local Y ≡ 1.5 (mod 3)), `SpawnLocations` (SpawnLocation parts numbered 1..12 → team ordinals 1..12; fewer teams spread evenly), and `WorldData.Chest.Tier.1..4` CFrameValues (each value's name is its tier; a fresh `ReplicatedStorage/Misc/ChestTierOne..Four` prefab chest is placed at every value, yawed 180° from the value's rotation because the prefab's lock faces opposite the generator's convention, with its base on the floor the value marks). The map's own `Chests` folder (generator-placed chest templates without the AnimationController rig the client's ChestComponent requires) and the SpawnLocation parts are discarded after reading; `WorldData.GameSpawn`/`ContestSpawn` are currently unused. When the selected map has no imported model (or the empty "random" selection), the per-mode **placeholder template** (`src/ServerStorage/Maps/SkyWars/<GameMode>/MapConfig.luau` + cached `Template` model) is generated as before: one island per team, a center island, and loot chests from `server/world/ChestLoot.luau` (island tiers 1-2, center tiers 3-4). Either way the arena is cloned into `Workspace.BlockContainer` (a Model), named after the selected map (placeholder fallbacks are named `Placeholder`), a sibling of player-placed blocks — the client's block raycast whitelists exactly `Workspace.BlockContainer`. (The former `PlaceholderMapService.luau` was folded into `MapService.luau` when real-map support landed.)

#### Recovered real map format (e.g. `Airport.rbxm`, 8,240 instances — the layout `MapService.loadMap` consumes)

```
<MapName> (Model)                        ← sits at ServerStorage.Maps.SkyWars.<MapName>
├── WorldData (Folder)
│   ├── Spawn (CFrameValue)              ← the map's anchor point (Airport: (0, 64.5, 0));
│   │                                      the map is placed so this lands at MAP_ORIGIN
│   ├── Chest (Folder) > Tier (Folder)
│   │   ├── 1..4 (Folder)                ← one folder per chest tier; every CFrameValue
│   │   │   └── <n> (CFrameValue)        ←   inside is named after its tier ("1".."4")
│   │   │                                  Airport: 24×tier1, 24×tier2, 16×tier3, 16×tier4
│   ├── GameSpawn (Folder)               ← E/N/S/W folders; each holds a subfolder "E"
│   │   ├── E/N/S/W                         with 2 CFrameValues "E" (the two side islands)
│   │   │   └── E (2× "E") / "P"            plus a CFrameValue "P" (the pushed-back island)
│   └── ContestSpawn (Folder)            ← 4 CFrameValues E/N/S/W on the semi-middle islands
├── SpawnLocations (Folder)              ← SpawnLocation parts named 1..12, 30 studs above
│                                           their islands, facing outward
├── SpawnLocation                        ← top-level part mirroring WorldData.Spawn
├── Chests (Folder)                      ← 80 generator-placed chest models (24/24/16/16);
│                                           MeshParts (Base/Lid/Lock) + ProximityPrompt but
│                                           NO AnimationController → discarded by the loader
└── Default / E / N / S / W / <dir> E ×2 / <dir> P  ← island geometry models
```

Verified interpretations (all measured from the file, not guesses):

- **Spawn number ↔ team:** SpawnLocations 1..12 map 1:1 onto the twelve SkyWars team ordinals (Solo uses all 12; Duos/Octos are also 12 teams; Trios/Quads spread 8 teams over the 12 spawns via `round(1 + (i-1)·12/teams)`). The 12 spawns are the 4 `P` islands + the 8 `<dir> E` side islands; the four semi-middle islands (`E/N/S/W` alone) and `Default` (center) have **no spawns**. `GameSpawn` CFrameValues sit at island-surface level directly under each of those 12 spawn points; `ContestSpawn` sits on the semi-middle islands.
- **Chest placement:** each tier CFrameValue marks a floor point (its Y is the floor top the chest stands on) and a yaw facing the map center. The map's own pre-placed chests sit with their base bottom at the value's Y and pivot 1.5 studs above it — the loader reproduces that with the Misc prefabs, plus the 180° yaw correction noted above.
- **Block grid:** the client places block centers on world multiples of 3 (bottoms at Y ≡ 1.5 mod 3); the map's build surfaces (chest floors, island decks) are all at local Y ≡ 1.5 (mod 3), so the map root must land at Y ≡ 0 (mod 3) — hence the 1.5-stud downward shift (Airport root = 234.0). Only parts named after block items (Airport has 11 `StoneBricks` pillars) are direct placement targets; elsewhere the assist/void-cast paths anchor off the world grid. `tools/analyze_grid.mjs` / `analyze_islands.mjs` re-verify a newly imported `.rbxm` against these rules.
- **Format provenance:** the `.rbxm` files begin with the `<roblox!` magic (the `<` is part of it) and end with a stray `</roblox>` — both Rojo's parser and the vendored `tools/rbxm-parser-ts/` accept them; `tools/dump_rbxm.mjs` dumps an imported map's tree.

### 4.6 Authoritative combat (melee + projectiles)

- **Character combat hitboxes:** the client's melee raycast is a whitelist of parts named `Hitbox` (and `ProjectileHitbox` for ranged) on other players' characters — without them the client can never find a player to swing at and fires `MeleeStrike(nil)`. `CombatService` welds a transparent, massless hitbox part onto every character on spawn using the classic `Weld` joint (`Weld.C0` is scriptable; `WeldConstraint.C0` is NOT — it errors at runtime), keeps the part a **direct child of the character model** (the whitelist uses `Character:FindFirstChild("Hitbox")`), and self-heals by re-attaching if anything removes a hitbox while the character lives; drops already carry their own `Hitbox` via the shared `ItemDropUtil`.
- **`server/combat/CombatService.luau`** is the single damage pipeline every damage source goes through. `CombatHandlers.meleeStrike`/`meleeStrikeEntity` validate and resolve sword hits; `ProjectileService` routes player collisions into `dealProjectileHit`. Both end in `dealDamage`, which applies friendly-fire rejection (uniform for every source), armour mitigation (additive per-piece `DamageMitigation`, matching `ArmourController`), shield absorption, `Health`/`Shield` attribute updates (the client's health bar/name tags read those attributes), the `DamageDealt` indicator broadcast, and elimination with kill credit.
- **Universal knockback:** `getKnockback(direction, strength)` is the single knockback system — melee passes attacker→target direction, bows pass the arrow's velocity; both get the same horizontal flattening/upward bias and flow out as `DamageImpulse` for `PlayerVelocityController`. Strength is **fixed per damage type**, not scaled by hit damage — the recovered client never ties knockback magnitude to damage (`DamageImpulse` is a bare Vector3, sword definitions carry only `Damage`, and no client code derives knockback from it), so every hit shoves the same. Shipped constants: `KNOCKBACK_BASE = 80` × melee 8 = 640 (~44.7 studs/s) / × projectile 10 = 800 (~55.8 studs/s), `KNOCKBACK_UPWARD_BIAS = 0.6` (the client divides by 14.332 effectively). Zero-damage hits (e.g. Snowball) skip health/shield/elimination but still deliver full knockback. `getProjectileKnockback(direction)` exposes the fixed projectile impulse (explosions reuse it), and `dealExplosionDamage` applies damage without its own impulse.
- **All projectile types** (`server/projectile/ProjectileService.luau`): `fireProjectile` resolves the held ranged weapon into its projectile definition, ammo (`RequiresAmmo` defaults true; FishingRod opts out) and per-weapon cooldown (`Ranged.Cooldown`, else the shared micro-cooldown), keyed by weapon name for the client's `CooldownUpdated`. Collision behavior lives in the `HIT_BEHAVIORS` registry (one entry per projectile item type; `registerHitBehavior` extends it). Shipped behaviors: **Arrow** (default — deals `Projectile.Damage`, welds on environment hits so the client completes its visual simulation; the only client-predicted type), **Snowball** (zero damage, fixed projectile knockback), **Dynamite** (knockback-only explosion: recovered `ExplosionSound` via `SoundPlayed`, server-owned particle burst from the recovered `ExplosionParticles` config, full impulse within `KnockbackRadius` 5, plus the spherical block carve), **Capybara** (same blast + 50 damage with linear falloff across `ExplosionRadius` 3, plus the spherical block carve), **Teleporter** (shooter moves to the exact impact point, zeroed velocity), **Fish/FishingRod** (pulls the victim toward the caster with the recovered `KnockbackScalar` (-1.5, 1, -1.5) applied component-wise to the fish's velocity). Explosions follow the uniform combat rules (no self/teammate hits).
- **Universal cooldown registry:** melee and ranged cooldowns share one per-player registry in CombatService (`ProjectileService` delegates to it); only replicated cooldowns (e.g. `"Bow"`) fire `CooldownUpdated` for the client UI.
- **Melee validation:** attacker must be alive, in a custom round (`record.InGame` + `roundState == "InGame"`), holding a melee item, off the 0.4 s damage cooldown, within range (client's loosest desktop bound + 1.5 studs slack), with line of sight (the ray stops 1.5 studs short of the target so terrain behind the target never blocks a clean hit), and the target must be an alive, non-teammate player (or a tagged `entity`/`egg` with a `Health` attribute — eggs publish `EggEliminated` on death).
- **Kills:** `CustomGameService.eliminatePlayer` now takes a `killer` and publishes both `PlayerEliminated` (spectating/round end, with killer) and `PlayerKilled` (kill feed) for every damage type; the victim ragdolls without entering the auto-respawn cycle (`Dead` state disabled + Physics). Projectile hits apply their `Projectile.Damage` with the travel direction as knockback.
- **Untouched:** the client was only *read* (events.luau schema, query-util raycast whitelists, health/armour/velocity controllers, melee-controller, kill-feed UI) to derive the contract; no client file was modified.
- **Test-harness gotcha:** the Studio MCP `execute_luau` tool runs scripts through the Assistant's sandbox, which silently removes instances those scripts create (parts vanish with `Parent = nil`, no `Destroying`) — never use it to judge whether server-created parts persist; verify with a real Script instead.
- **Real game assets:** all 92 sound IDs in `ReplicatedStorage/TS/asset/roblox/roblox-sound.luau` and all 253 animation IDs in `roblox-animation.luau` were replaced with user-owned re-uploads (sound map in `sound-id-replacements.json`, animation map in `animation-id-replacements.json`; name/id/file references in `sound-asset-names.json`; dumped sound files under `tools/sounds/mapped/`; the animation dump/upload workflow lives in `tools/dump_animations.luau`). The original universe's assets are unauthorized in local/unpublished places, so these swaps are what make combat/UI/music audio and animations work in Studio. Image assets still use the original IDs and remain broken locally.

### 4.7 Authoritative block breaking (mining into greedy-meshed maps)

- **The problem:** the recovered maps (e.g. Airport) are greedy-meshed — runs of same-material block cells are one axis-aligned `Part` (dims are multiples of 3, corners land on cell boundaries, centers on cell midpoints), and only the exposed faces carry `Texture`s (all tiled `StudsPerTile = 3`, offset 0; one consistent asset id per material+face across the whole map; 0 multi-id faces). The client's pickaxe flow raycasts `Workspace.BlockContainer` (whitelist) for parts named after block items, snaps the hit to the 3-stud cell grid, and fires `HitBlock(position)` **every heartbeat while the mouse is held**; the server accumulates break progress and drives the crack overlay via `BlockBreakProgress(position, progress)` / `BlockBreakStatusCleared(position)` / `BlockRemoved(position)` (all three payloads: single `Vector3`; progress is a `number` 0..1). Break time = `Items[name].Block.BreakTime` (Blocks-folder items default 0.5; StoneBricks 1.75, AquaBricks 2.5, Iron 3, ShimBlock ∞) × the held pickaxe's `Pickaxe.TimeMultiplier` (Bronze 1 → Onyx 0.3).
- **`server/world/BlockWorldService.luau`** is the whole feature. On map load (`CustomGameService.startMatch` → `rebuild(mapModel)`) it indexes **every block cell** (cell index = world position / 3) to `{ part, itemType, breakTime }` and builds the per-material per-face texture registry by scanning all block-named parts (decor slabs contribute textures but are not indexed; chest MeshParts and thin/non-aligned geometry are skipped). `BlockPlacementService` registers player-placed blocks with the same index so they are minable and hide neighbouring faces like map blocks. `registerHit` (from `WorldHandlers.hitBlock`) validates: alive + not spectating, the same placement role gate (`customGameService:isBlockPlacementAllowed` for private rounds — i.e. only inside the arena's build-constraint whitelist), grid-aligned position, a live voxel entry, held pickaxe, and ≤48 studs range (the client itself stops at 18); deltas between hits are clamped to 0.25 s so lag cannot fast-forward a break; stale targets are swept after `BLOCK_HIT_EXPIRE` (5 s).
- **Mining merged geometry** (`mineCell` → `removeBlocks`): removals are **batched** — a pickaxe break removes one cell, an explosion removes a whole sphere — and every part that lost a cell is rebuilt exactly **once**: its cells are cleared from the index, the part is **destroyed first**, then replacement geometry is created (individual 3×3×3 parts inside the removed region's bounding box whose 1×1 faces cull exactly, plus up to six slabs for the remainder via `BlockGeometry.decomposeBoxMinusBox` — pure Luau, unit-tested under Lune by `tools/test_block_geometry.luau`, 16.5k checks). Destroy-first ordering means the replication burst never renders old and new geometry overlapping — the fix for the carve texture flicker. Face culling matches the recovered map's own style, measured from the file: a face is textured when **any** across-cell is air/removed **and** the material ships a texture for that orientation (the shipped Airport itself has 723 partially-covered textured faces — full-face overdraw is native; and 679 exposed plain faces from materials like Grass that only carry a Top texture — registry misses stay plain, no fallback). Neighbour parts that a removed cell used to hide get their missing face texture re-added (`exposeNeighbourFaces`, add-if-missing; the ±Z NormalId mapping — a neighbour at +Z shows its **Front** (-Z) face — was fixed during this pass).
- **Replication & loot:** progress fires to the miner per heartbeat; on break the server fires `BlockBreakStatusCleared` + `BlockRemoved` to the miner and grants the mined block to their inventory (`inventoryService:changeItem(player, itemType, 1)` — full inventories simply don't receive it). No client file was modified; the client contract was read-only (`block-controller`, `block-raycast-controller`, events.luau guards, item.luau break times).
- **Explosions (`mineExplosion`):** Dynamite and Capybara blasts carve a **spherical** hole through the same batched path — every cell whose center lies within `ExplosionRadius` (3, in **block** units, matching the recovered projectile data; ≈6 blocks side-to-side) of the exact impact point is collected first, then `removeBlocks` rebuilds every affected part **once** (destroy-first, so the carve appears as a single swap instead of progressive overlapping rebuilds). Centered on the raw impact point (which sits on block surfaces, i.e. cell boundaries), so the carve hugs the sphere rather than snapping to a cell. Explosions grant no items (they destroy, they don't gather); chests are not carved (they're not block cells); player damage/knockback radii are untouched (still read the raw values in studs — see below).
- **Known limits:** break FX (sound/particles) are not wired yet; cracks are visible only to the miner (progress is targeted, not broadcast); rotated multi-cell parts are not minable (the client's grid snap filters them anyway — only 3×3×3 rotated blocks, e.g. placed launch pads, are targets); the synced `ReplicatedStorage/Blocks/*` templates lost their Texture ids in syncback, so player-placed blocks render untextured and split faces fall back to the map-scanned registry (map parts keep their ids and are unaffected). `ExplosionRadius`/`KnockbackRadius` are block-unit values in the client data; the block carve scales them by `BLOCK_SIZE`, while the older player-damage/knockback falloff still reads them as studs — scaling those two lines is a one-line balance change if the originals used block units there too.

---

## 5. Current status & known gaps

- **Done:** full rename + types on 734 scripts; named event access; **the client boots in Studio and shows a fully interactable lobby UI**; all eight public modes share one PlaceId and route through MemoryStore-backed matchmaking/reserved servers; character spawn + profile replication, an authoritative inventory/drop/chest/shop foundation, and authoritative combat (melee + all six projectile weapons: Bow, Snowball, Dynamite, Capybara, Teleporter, FishingRod) are provided by the server; parties and SkyWars custom games are implemented end to end (§4.4–§4.5); authoritative block breaking with greedy-mesh mining and face re-culling works for both map blocks and player-placed blocks (§4.7).
- **Open / planned:**
  - Flamework controller dependency ids — `Flamework.resolveDependency("1LA")` strings could be replaced with named constants (same pattern as event rename). Known id→controller map exists (e.g. `zG`=Rodux, `lB5`=Screen, `Xlg`=Content, `7xl`=PlayerSettings, `rB8`=Game, `yAg`=ABTest, `jL9`=Sound, `MMv`=Matchmaking, `1LA`=Spectator, `x5`=Team, …) but is incomplete/unverified.
  - `SetValue` store `Key` strings → named access (same pattern).
  - **Domain services:** matchmaking, session plumbing, inventory, combat, block breaking, parties, and SkyWars private-session rounds are present. Persistence, developer-product purchases, combat power-ups/FX, full public-match rounds/maps, team upgrades, and non-SkyWars custom modes remain incomplete extension points (per §3.8 priority list).
  - Runtime testing loop: Rojo 7.7.0 occasionally crashes on file replacement (see §8); when Studio's Rojo plugin is disconnected, sync files through the MCP HTTP bridge instead.
- **Known behavioral quirk preserved intentionally:** `AwaitHumanoid` in `StarterPlayerScripts/TS/util/util.luau` has a duplicated nil-check from the decompile — kept byte-identical on purpose.
- **Known environment noise (not code):** in an unpublished Studio place, the original universe's *image* assets fail to load (`User is not authorized` / `serverplaceid=0` spam). Audio and animations are already replaced with user-owned uploads (§4.6).

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
12. **`WeldConstraint.C0`/`C1` are NOT scriptable** in current Roblox builds (`weld.C0 = ...` errors at runtime with "not a valid member"). Use the classic `Weld` joint (its `C0` is scriptable) for offset welds, or pre-position parts before creating a WeldConstraint. Also: combat hitboxes must stay **direct children of the character model** — the client's melee raycast whitelist looks them up with `Character:FindFirstChild("Hitbox")`, not `GetDescendants`.

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
| `ServerScriptService/server/inventory/InventoryService.luau` | Authoritative inventory, currency, armour, drops, chests, predictions, and item-shop transactions |
| `ServerScriptService/server/combat/CombatService.luau` | Authoritative damage pipeline: melee/arrow validation, armour/shield, universal knockback, cooldown registry, elimination kill credit |
| `ServerScriptService/server/custom/CustomGameService.luau` | Custom-session admission, settings, moderation, teams, rounds, replication, and teleport flow |
| `ServerScriptService/server/custom/modes/` | Extensible custom-mode registry and the SkyWars mode adapter |
| `ServerScriptService/server/custom/MapService.luau` | The custom-round map layer: loads real recovered maps from `ServerStorage/Maps/SkyWars/<MapName>` (anchor, team spawns, tier chests) with the per-mode placeholder template as fallback |
| `ServerScriptService/server/party/PartyService.luau` | Party membership, invitations, ownership, replication, and custom-game warp support |
| `ServerStorage/Maps/SkyWars/` | Per-SkyWars-mode placeholder map configurations |
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
- **"Is the game playable right now?"** — The lobby and SkyWars custom-session lifecycle are playable locally: parties can create or join by code, select teams, start a round on a generated placeholder arena, use inventory/chests/building, fight with swords and bows (authoritative damage, armour, shields, knockback, kill feed), be eliminated, receive results, and reset. Full public-match rounds/maps, persistence, developer-product purchases, and other domain behavior still need implementation (§5).
- **"Where are the pilot files?"** — `ReplicatedStorage/TS/event/event.luau`, `StarterPlayerScripts/TS/util/util.luau`, `StarterPlayerScripts/TS/controllers/hotbar-controller.luau`, `StarterPlayerScripts/TS/controllers/block-raycast-controller.luau` — the first 4 files renamed; they set the quality bar.
