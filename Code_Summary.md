# Tile War - Code Summary and Documentation

**Project:** Tile War
**Engine:** Godot 4.5 (Forward+)
**Version:** 0.01.02.09
**Date:** February 15, 2026

---

## Overview

**Tile War** is a turn-based strategy game built in Godot where multiple claims (players and AI) compete to capture territory on a hex tile board. Supports singleplayer/hotseat, LAN multiplayer with server browser, headless dedicated server mode, a mod system for custom music, and an experimental WebRTC online multiplayer system.

---

## Core Components

### Data Models

#### tile_data.gd - Tile Information Resource
**Path:** `scripts/data/tile_data.gd`
**Class:** `tile_data` (extends Resource)

Represents individual tile state, scoring, and generates contextual BBCode tooltips.

**Properties:**
- `coords: Vector2i` - Grid position
- `type: int` - Ownership state: -1=unavailable, 0=empty, 1=enemy, 2=self-owned, 3=wall
- `tile_type: String` - Display label: "claim", "capital", "fuel"
- `available: bool` - Can the active player claim this tile?
- `points / oppose_points` - Attack/defense strength from surrounding tiles
- `fuel / oppose_fuel` - Combat modifiers from fuel resources
- `final_score: int` - Combined score for claimability evaluation
- `cap_list: Array` - Connected capitals (for capital boost calculations)
- `move_to_value: int` - AI heuristic score (higher = more valuable target)
- `opposite_claim_data: ClaimData` - Reference to opposing claim
- `opposite_claim: String` - Enemy claim display name

**Key Function:**
- `get_info() -> String` - Generates rich BBCode tooltip based on tile type, showing ownership, combat calculations, capital boosts, and claimability status.

---

#### claim_data.gd - Base Claim Resource
**Path:** `scripts/claims/claim_data.gd`
**Class:** `ClaimData` (extends Resource)

Abstract base class for all claims (player and AI).

**Signals:**
- `changed_info` - Emitted when any claim property changes (reactive UI updates)
- `move_made` - Emitted when moves are decremented

**Properties:**
- `name: String` - Display name
- `claim_colour: int` (1-5) - Color ID mapping to tilemap atlas columns
- `claim_turn_slot: int` (0-3) - Turn order position
- `moves: int` - Remaining actions this turn
- `fuel_count: int` - Fuel tiles owned
- `tile_size: int` - Total territory count
- `capatal_tile: Array[Vector2i]` - Capital coordinates
- `claim_dead: bool` - Elimination flag
- `claim_active: bool` - Currently taking turn
- `claim_had_turn: bool` - Already acted this round
- `claim_dangered: int` - CDAN protection counter
- `claim_mp_ip_linked: int` - Multiplayer peer ID linked to this claim
- `claim_panel_normal / claim_panel_danged: Texture` - UI panel textures
- `orginal_claim: ClaimData` - Reference to unduplicated source claim

**Key Functions:**
- `refresh(turn_num) -> int` - Calculates moves using tiered formula: base tile moves (initial tier capped at `moves_tile_int_lim_boost`, secondary tier capped at `moves_tile_second_lim_boost`) + fuel bonus (capped at `moves_fuel_lim_boost`) + turn bonus (capped at `moves_turn_lim_boost`). All divisors/caps are configurable via Global settings.
- `depleate_danger_value()` - Decrements danger counter by 5 per move made
- `get_data() -> String` - Formatted claim summary for UI display
- `print_data()` - Debug logging

---

#### player_claim.gd - Human Player
**Path:** `scripts/claims/player_claim.gd`
**Class:** `PlayerClaim` (extends ClaimData)

Type marker for human-controlled claims. No additional behavior; player input is handled by board_ui.gd UI interaction.

---

#### non_player_claim.gd - AI Opponent
**Path:** `scripts/claims/non_player_claim.gd`
**Class:** `NonPlayerClaim` (extends ClaimData)

AI decision-making with configurable personality weights.

**AI Personality Weights (exported):**
- `fuel_beeline: int = 2` - Priority for fuel tiles
- `stratigic_beeline: int = 1` - Priority for capturable enemy tiles
- `blindless_beeline: int = 0` - Priority for any enemy tiles
- `teratory_beeline: int = -1` - Priority for own territory (negative = avoidance)
- `capital_beeline: int = 0` - Priority for enemy capitals
- `wall_beeline: int = 0` - Priority for wall tiles

**Key Functions:**
- `claim_surounding_tiles(available: Array[tile_data]) -> tile_data` - Main AI entry point. AI Level 0 picks randomly; Level 1+ uses `get_best_paths()` to filter to highest-value tiles, then picks randomly from the best pool.
- `get_best_paths(available) -> Array[tile_data]` - Filters to tiles matching the maximum `move_to_value`.

---

#### claim_lookup_table.gd - Claim Registry
**Path:** `scripts/claims/claim_lookup_table.gd`
**Class:** `claim_lookup_table` (extends Resource)

**Properties:**
- `pc_claim_data: Array[PlayerClaim]` - Player claim templates (indexed by `claim_colour - 1`)
- `npc_claim_data: Array[NonPlayerClaim]` - AI claim templates (indexed by `claim_colour - 1`)

---

#### profile_data.gd - Settings Profile
**Path:** `scripts/data/profile_data.gd`
**Class:** `profile_data` (extends Resource)

Stores complete game configuration as a serializable resource. Used by the profile loader for save/load of game presets.

**Properties:**
- `profile_name / profile_discription: String` - Display metadata
- `profile_type: int` - 0=external (user-created), 1=internal (built-in)
- `profile_path: String` - File path
- `settings: Dictionary` - All game settings (map, wall, fuel, cap, ai, lms, bran, cdan, blz, move_settings)

---

### Configuration & Startup

#### global.gd - Global Configuration Singleton
**Path:** `scripts/global.gd`
**Autoload:** `Global`

Persists game settings across scenes. Parses CLI arguments on startup.

**Map/Generation:**
- `map_type: int` - Map selection
- `wall_count: int` (74) - Impassable wall tile count
- `fuel_count: int` (16) - Fuel tile count
- `cap_list: Array[int]` ([2,2,2,2]) - Capitals per claim

**Claim Configuration:**
- `claim_list: Array[int]` ([2,1,1,1]) - Per-claim status: 0=disabled, 1=bot, 2=player
- `claim_names: Array[String]` - Custom display names
- `claim_colours: Array[int]` ([1,2,3,4]) - Color assignment per claim slot (allows remapping colours)
- `claim_name_num` enum - SPECTATOR(0), GREENWICH(1), PLUM_VALLEY(2), YORK_STREET(3), RIVER_SOLME(4)
- Legacy toggles: `player_enabled`, `purple_enabled`, etc. (@deprecated)

**AI:**
- `ai_level: int` (1) - Difficulty: 0=random, 1=strategic (dist=2), 2=deep strategic (dist=3)
- `dist: int` - AI look-ahead distance (auto-set by ai_level setter)

**Audio:**
- `music_type: int`, `music_list: Array` - Music track selection
- `music_vol: float` (10.0), `SFX_vol: float` (10.0) - Volume settings

**Game Rules:**
- `lms_enabled: bool` (true) - Last Man Standing win condition
- `bran_enabled: bool` (false) - Battle Random: d20 roll on contested captures
- `cdan_enabled: bool` (true) - Capital Danger Protection after capital loss
- `cdan_duration: int` (10), `cdan_capture_duration: int` (5) - Protection durations
- `blz_enabled: bool` (true) - Blitz attack mode
- `blz_move_requrement: int` (5) - Move cost for blitz

**Movement Formula (all configurable):**
- `moves_tile_int_reduction_boost` (2) / `moves_tile_int_lim_boost` (15) - Initial tier
- `moves_tile_second_reduction_boost` (5) / `moves_tile_second_lim_boost` (20) - Secondary tier
- `moves_fuel_reduction_boost` (2) / `moves_fuel_lim_boost` (5) - Fuel bonus
- `moves_turn_reduction_boost` (2) / `moves_turn_lim_boost` (10) - Turn bonus

**Multiplayer State:**
- `mp_enabled / mp_host / mp_server / mp_connected: bool` - Connection state
- `mp_dedicated: bool` (false) - Headless server mode (`--dedicated` flag)
- `mp_port: int` (7777) - Server port (`--port=N`)
- `mp_server_name: String` - Server display name (`--server_name=X`)
- `mp_player_id: int` - This peer's multiplayer ID
- `mp_player_list: Dictionary` - `{peer_id: {name, id, current_claim}}`
- `mp_claims_colours: Dictionary` - Maps claim numbers to Color objects (includes SPECTATOR grey)
- `mp_ended_sesion: bool` - Session end flag

**Signals:**
- `mp_player_list_changed()` - Emitted when player list updates

**CLI Parsing (_ready()):** Supports `--dedicated`, `--port=N`, `--server_name=X`, `--music_type=N`, `--map_type=N`

---

#### init_screen.gd - Scene Router
**Path:** `scripts/init_screen.gd`

Routes startup based on CLI arguments:
1. `--help_tw` / `-h` → Print help and quit
2. `--dedicated` / `--mp_start_server` → menu_mp.tscn (multiplayer lobby)
3. `--multiplayer` / `--mp` → menu_mp.tscn
4. `--brc_testing` → brc_testing.tscn (WebRTC experimental)
5. Default → menu.tscn (singleplayer)

---

#### mod_loader.gd - Mod System
**Path:** `scripts/mod_loader.gd`
**Autoload:** `ModLoader`

Discovers and loads mods from the `./mods/` directory.

**Properties:**
- `mod_path = "./mods"` - Root mod directory
- `music_path = "/audio"` - Audio subfolder within mods
- `mod_paths_list = []` - All discovered file paths
- `disable_list = [".disabled", ".break", ".remove", ".no", ".none"]` - Suffixes that disable mods

**Functions:**
- `get_mods_paths(path)` - Recursively scans mods directory, populates `mod_paths_list`. Creates the directory if it doesn't exist.
- `get_mods_list(wants: int) -> String` - Filters mods by type. `wants=0` returns the first `main.ogg` audio file not matching any disable suffix. Returns empty string if no match.

**Expected Mod Structure:**
```
mods/
  my_mod/
    audio/
      audio_music_my_song.main.ogg
  disabled_mod.disabled/    <- skipped due to suffix
```

---

### Menu System

#### menu.gd - Base Menu Controller
**Path:** `scripts/menus/menu.gd`
**Class:** `menu_class` (extends Control)

Settings menu for singleplayer/hotseat. Base class for `menu_mp_class`.

**Key Behavior:**
- `_ready()` calls `ModLoader.get_mods_paths()` to initialize the mod system
- When `Global.mp_dedicated` is true, all UI initialization and audio are skipped
- When not updating for multiplayer, resets all `mp_*` flags

**Music System (`music_play()`):**
- Checks `ModLoader.get_mods_list(0)` for mod music
- If a mod provides music: loads as `AudioStreamOggVorbis` with loop enabled
- Otherwise: loads default `"res://audio/music/On the house/On the house.ogg"`
- Guarded: returns immediately on dedicated server

**RPC Pattern:** All settings handlers are `@rpc("any_peer")` with `mp_player_source` flag to prevent infinite relay loops. UI node accesses are guarded with `if not Global.mp_dedicated:` while `Global.*` data updates remain unconditional.

**Profile System:**
- `save_profile_data(mp_for_client) -> Dictionary` - Exports all settings
- `load_profile_data(profile, refresh)` @rpc - Loads settings from dictionary, optionally refreshes UI

**Enum:**
- `movement_edits` - ti_lim, ti_red, ts_lim, ts_red, fl_lim, fl_red, tn_lim, tn_red (used by unified `_on_movement_setting_changed()` handler)

---

#### menu_mp.gd - Multiplayer Lobby Controller
**Path:** `scripts/menus/menus_mp/menu_mp.gd`
**Class:** `menu_mp_class` (extends menu_class)

Manages LAN multiplayer lobby: hosting, joining, server browser, claim picking, game lifecycle.

**Networking:**
- `peer: ENetMultiplayerPeer` - Main networking peer
- `peerUDP: PacketPeerUDP` - UDP socket for LAN broadcast discovery (null on dedicated)
- `address / address_broadcast: String` - LAN IP addresses (broadcast = last octet → 255)
- `port: int` - ENet listener port

**Dedicated Server Setup (_ready()):**
When `Global.mp_dedicated`:
1. Sets `client_name = "DedicatedServer"`, `server_name` from env/CLI
2. Sets `port = Global.mp_port`
3. Skips UDP binding, client signals, and all UI initialization
4. Connects `mp_player_list_changed` to `_dedicated_log_player_list()` (console output)
5. Auto-calls `_on_host_button_down()` to start immediately

**Console Output (Dedicated):** Startup banner with port/name/IPs, player connect/disconnect events, player list with claim assignments, game start/end notifications.

**Claim Picker RPCs:** Guard all UI accesses with `if not Global.mp_dedicated:` while always updating `Global.claim_list` and `Global.claim_names`.

**Player Management:**
- `player_connected(id)` - Adds peer, sends existing player data
- `player_disconnected(id)` - Removes peer, frees claim slot
- `send_player_data() / remove_player_data()` @rpc - Sync claim assignments

**Game Lifecycle:**
- `start_game()` @rpc - Instantiates game scene, hides lobby
- `end_game()` - Returns to lobby, restarts broadcast

**LAN Broadcast:**
- `update_broadcast_server_staius()` - Sends server info via UDP (timer-driven)
- `_process()` - Receives broadcast packets for server browser (guarded on dedicated)

---

### Game Logic

#### board_ui.gd - Board Controller (~900 lines)
**Path:** `scripts/main_ui/board_ui.gd`
**Class:** `board` (extends PanelContainer)

The core game engine: manages the tile grid, validates moves, handles AI pathfinding, and tracks board state.

**Signals:**
- `game_state_change` - Notifies game manager of board state updates
- `tile_info(data: tile_data)` - Sends tile info for tooltip display
- `board_decrese_move_count(increments: int)` - Requests move deduction from game manager

**Key Properties:**
- `main_grid / overlay_grid / action_grid: TileMapLayer` - Game board layers
- `game: game_manger` - Reference to parent game manager
- `enabled_claims: Array[bool]` - Which claims are active this game
- `hovered / lock_mode / off_input: bool` - Input state flags
- `lot: Vector4i` - Map bounds (max_x, max_y, min_x, min_y)

**Initialization (_ready()):**
1. Builds `enabled_claims` from `Global.claim_list`
2. Maps each claim slot to PC/NPC data from `claim_lookup` using `Global.claim_colours` for colour assignment
3. Sets custom names from `Global.claim_names` or multiplayer player names
4. Populates `game.claims_order` indexed by `claim_colour` for O(1) lookup
5. Creates sound player (guarded for dedicated)
6. Calculates map bounds
7. **Generation (host/singleplayer only):** Loads map pattern, spawns capitals, walls, fuel tiles with separation validation
8. Syncs board state to clients via `mp_update_board_state.rpc()`

**Input Handling:**
- `_process()` - Mouse tracking and overlay updates (early return on dedicated)
- `_on_gui_input()` - Left-click claims tile (1 move), right-click for blitz or claim (early return on dedicated)
- `_on_mpui_input()` @rpc - Remote player input. Sound guarded with `if not Global.mp_dedicated:`

**Core Functions:**

`on_claim_tile(coords, claim, type, update, terain, force_do, blz_fired, mp_player_source, mp_did_claim, mp_ran_results) -> bool`
- Sets tile ownership on main_grid
- **Bran system:** Rolls attacker (0-10 + points + fuel) vs defender (0-10 + oppose_points + oppose_fuel). Attack fails if attacker < defender.
- **CDAN system:** Sets `claim_dangered` timer on capital capture
- **Blitz system:** Requires `blz_move_requrement` moves
- Capital capture cascades to surrounding tiles
- Logs results via `game.print_data_to_game()`, relays via RPC

`check_tile_claimably(coords, claim, test_suroundings, wants_tile_data, blz_fired, no_emition)`
- Central validation function returning `tile_data` or `bool`
- Checks connectivity via `find_linked_tiles()`, calculates attack/defense scores from neighbors
- Applies capital boost (+cap_buff), disconnection penalty (-10), CDAN modifier, blitz bonus
- Available if score >= 0 (or > -10 with bran) AND connected to own territory
- Accepts both `int` and `ClaimData` for the `claim` parameter

**AI Support:**
- `get_all_avalable_tiles(claim) -> Array[tile_data]` - Full board scan for claimable tiles (60ms time limit)
- `get_all_local_avalable_tiles(coords, claim, distance) -> Array[tile_data]` - Local radius scan (120ms time limit)
- `start_search(tile, coords, claim) -> tile_data` - Applies AI personality weights to tile scoring
- `search_surounding_tiles(tile, distance, claim) -> int` - Recursive neighbor scanning applying fuel/strategic/blindness/territory/capital/wall weights with timeout protection
- `find_linked_tiles(tile, other, claim, limit) -> bool` - BFS connectivity check to capitals

**Board Sync:**
- `serialize_pattern() / deserialize_pattern()` - Converts TileMapPattern to/from Dictionary for RPC
- `mp_update_board_state()` @rpc - Syncs full board state to clients

---

#### game.gd - Game Manager (~460 lines)
**Path:** `scripts/main_ui/game.gd`
**Class:** `game_manger` (extends BoxContainer)

Orchestrates turn flow, manages claim states, and updates UI.

**Signal:**
- `mp_back_to_lobby()` - Emitted to return to multiplayer lobby

**Key Properties:**
- `claims: Array[ClaimData]` - All claims indexed by turn order
- `claims_order: Array[ClaimData]` - Claims indexed by colour for quick lookup
- `active_player: ClaimData` - Currently active claim (duplicated from source)
- `claim_lookup: claim_lookup_table` - PC/NPC claim templates
- `panels: Array[ClaimDataPanel]` - UI panels per claim
- `avaible_moves: Array[tile_data]` - Claimable tiles for active player
- `done_moves: Array[Vector2i]` - Tiles claimed this turn
- `turn: int` - Current turn number
- `failed_move: bool` - Bran roll failure flag
- `dead_number: int` - Count of living claims

**Initialization (_ready()):**
- Creates music player and starts playback (guarded for dedicated)
- Calls `game_state_changed(true)` to initialize first turn

**Turn Management:**

`on_next_turn()` @rpc:
1. Marks current player's turn complete, disables next_turn button
2. Iterates all claims:
   - **NonPlayerClaim (AI):** Sets as active, loops moves with clock delays, calls `board_ui.on_claim_tile()` for each AI decision, syncs via RPC
   - **PlayerClaim:** Sets as active, breaks to wait for input
3. Re-enables button, calls `game_state_changed()`

`game_state_changed(refresh)`:
1. Checks dead status for all claims (no capitals = dead)
2. Updates tile_size, fuel_count, capital positions
3. On refresh: resets turns, recalculates moves via `claim.refresh(turn)`, syncs via RPC
4. Picks next active player (PlayerClaim priority, handles bot-first turn order)
5. Sets `board_ui.off_input` based on whose turn / multiplayer claim linking
6. Updates all UI elements (all guarded for dedicated)
7. LMS win detection: triggers win screen or prints to console on dedicated

`set_active_player(claim)`:
- Disconnects previous signal handlers
- Duplicates claim data, stores `orginal_claim` reference
- Scans available moves via `board_ui.get_all_avalable_tiles()`
- Connects `depleate_danger_value` for CDAN tracking

`remove_active_player_moves(increments, set_as, bot_only)`:
- Decrements both `active_player` and `orginal_claim` moves
- Syncs via `mp_sync_movement.rpc()`

**Chat/Events:**
- `print_data_to_game(str)` @rpc - Appends to event log, relays to all peers
- `_on_chat_input_text_submitted(new_text)` - Formats chat with player colour

**Game End:**
- `new_game()` @rpc - Resets all claims. Dedicated: prints to console and emits `mp_back_to_lobby`. Client: plays fade animation.

---

### UI Components

#### claim_data_panel.gd - Claim Display Panel
**Path:** `scripts/object/claim_data_panel.gd`
**Class:** `ClaimDataPanel` (extends Control)

Displays claim info (name, tiles, fuel, capitals) with animated turn indicators. Listens to `claim.changed_info` for reactive updates. Swaps panel texture between normal/endangered/dead states.

#### moves_plate.gd - Move Counter
**Path:** `scripts/object/moves_plate.gd`
**Class:** (extends Node2D, @tool)

Displays remaining moves with number textures and player colour indicator. Animates on change ("drop_move", "out_of_moves", "change_claim").

#### lobby_chat.gd - Multiplayer Chat
**Path:** `scripts/object/lobby_chat.gd`

Handles multiplayer lobby chat via `mp_lobby_print_chatmsg()` @rpc with colour-coded sender names.

#### lobby_player_nameplate.gd - Player Nameplate
**Path:** `scripts/object/lobby_player_nameplate.gd`

Displays player name with claim colour formatting.

#### profile_loader.gd - Profile Manager
**Path:** `scripts/object/profile_loader.gd`

Discovers profiles from `./profiles/` (user) and `res://Resources/profiles` (built-in). Supports `.tres` and `.json` formats. Handles save/load/delete operations.

#### profile_button.gd - Profile Entry
**Path:** `scripts/object/profile_button.gd`

Individual profile button with select/delete actions. Delete only available for external profiles.

---

### Tutorial System

#### toutorial.gd - Tutorial Controller
**Path:** `scripts/toutorial/toutorial.gd`

Manages tutorial progression with menu panels and state changes. Uses `requirements` enum (none, movement, movement_no_move, next_turn) and `value_name` enum for effects (highlight, place, show_moves, activate_player, kill_player, etc.).

#### board_toutorial.gd - Tutorial Board
**Path:** `scripts/toutorial/board_toutorial.gd`

Simplified tile board for tutorial with highlight/claim mechanics. Emits `took_tile` signal for tutorial progression tracking.

---

### WebRTC Online Multiplayer (Experimental)

#### brc_mpol_tutorial.gd - Shared State
**Path:** `webrtc_toutorial/brc_mpol_tutorial.gd`
**Autoload:** `brc_mpol`

Shared state singleton for WebRTC system. Defines `broadcast_msg` enum for signaling protocol.

#### brc_client.gd - WebRTC Client
**Path:** `webrtc_toutorial/brc_client.gd`
**Class:** `brc_testing_client`

Connects to signaling server via WebSocket, establishes peer-to-peer WebRTC connections. Uses STUN servers for NAT traversal. Creates mesh network topology for multiplayer.

#### brc_server.gd - Signaling Server
**Path:** `webrtc_toutorial/brc_server.gd`
**Class:** `brc_testing_server`

WebSocket signaling server that routes WebRTC offer/answer/candidate messages between peers. Manages lobbies with random IDs. No game logic, only network mediation.

#### brc_lobby.gd - Lobby Data
**Path:** `webrtc_toutorial/brc_lobby.gd`
**Class:** `brc_testing_lobby` (RefCounted)

Lobby data structure tracking host and players.

---

## Dedicated Server Architecture

### Design Decision
The dedicated server reuses the same scene tree (`menu_mp.tscn`, `main_ui.tscn`) with `if not Global.mp_dedicated:` guards on all UI/audio/animation accesses. This ensures all RPC node paths match between client and server (Godot RPCs are path-based).

### Server Role
- ENet peer ID 1 with `current_claim = 0` (spectator)
- Runs all host-authoritative logic: board generation, AI turns, move refresh, state sync
- Never takes a turn, never renders UI
- Console logging for player connections, game events, and errors

### Protocol
- **ENetMultiplayerPeer** (UDP-based, reliable-ordered)
- Default port 7777, configurable via `--port=N`
- LAN broadcast (UDP ports 4433/4444) is disabled on dedicated server

### Guard Pattern
Every UI node access is wrapped: `if not Global.mp_dedicated: <node>.property = value`
Data-only operations on `Global.*` variables remain unconditional for game logic consistency.

### How to Run

**Dedicated Server:**
```
tile_war_server.exe --dedicated --port=7777 --server_name="My Server"
```

**Client (WAN):**
Open game → Multiplayer → Enter server IP and port → Join

**Client (LAN):**
Open game → Multiplayer → Server browser auto-discovers via UDP broadcast

### Export
`export_presets.cfg` contains three presets:
1. **"Dev Windows Desktop"** - Main game build (`tile war.exe`), excludes builds/profiles/mods
2. **"macOS NEEDS PORT DATA"** - Partially configured macOS build
3. **"Dedicated Server (Windows)"** - Headless server (`tile_war_server.exe`), `dedicated_server=true`, excludes builds/profiles

---

## Game Mechanics

### Board Setup
1. Loads map pattern from tileset based on `Global.map_type`
2. Spawns capitals for each enabled claim (ensures 3+ tile separation via `check_tile_neutralty()`)
3. Spawns walls and fuel tiles until reaching Global counts
4. Host generates board; clients receive via `mp_update_board_state.rpc()`

### Claim Setup
Each claim slot is mapped to a colour via `Global.claim_colours` and instantiated from `claim_lookup_table` as either `PlayerClaim` or `NonPlayerClaim` based on `Global.claim_list`. Claims are stored in both `claims` (turn order) and `claims_order` (colour-indexed) arrays.

### Turn System
1. Player makes moves (limited by move count from `ClaimData.refresh()`)
2. Next Turn → AI claims execute sequentially with clock delays
3. Move count refreshes each turn based on configurable tiered formula

### Tile Claiming
- Must be connected to your capital via owned tiles (`find_linked_tiles()`)
- **Empty tiles:** Claimable if adjacent to own territory
- **Enemy tiles:** Requires positive score from neighboring tile counts + fuel + capital boosts
- **Walls:** Impassable, never claimable
- Capital capture cascades to surrounding tiles and eliminates the claim

### Combat Scoring
- Each adjacent friendly tile: +1 point, +2 for capitals, +1 for fuel
- Each adjacent enemy tile: +1 oppose_points, +2 for capitals
- Disconnection from capital: -10 penalty
- Fuel bonus: `min(4, fuel_tile_count)` for attacker, full count for defender
- Attacker always gets +1 attack boost
- Capital linkage bonus: +1 per connected capital

### Battle Random (BRAN)
When enabled, contested captures add a d20 roll: attacker rolls `randi(0,10) + points + fuel`, defender rolls `randi(0,10) + oppose_points + oppose_fuel`. Attack fails if attacker < defender. Tiles with negative scores (down to -10) become claimable but risky.

### Capital Danger Protection (CDAN)
When a capital is captured, the losing claim gets `5 * (cdan_duration + 1)` protection points. The attacker gets `5 * (cdan_capture_duration + 1)` protection. Protection decrements by 5 per move made and adds to the protected claim's defense score.

### Blitz Attack (BLZ)
Right-click on an enemy tile to perform a blitz attack costing `blz_move_requrement` moves. Adds `blz_move_requrement * 10` to attacker's score, enabling capture of otherwise impossible tiles.

### AI Strategy
Recursive neighbor scanning (`dist` tiles deep) applies personality weights per `NonPlayerClaim`. Scores are accumulated using fuel/strategic/blindness/territory/capital/wall beeline multipliers. AI picks randomly from the pool of highest-scoring tiles. Time-limited to prevent frame drops (60-120ms).

### Win Condition
Last Man Standing: game ends when only one claim has capitals remaining.

---

## Mod System

### Overview
The `ModLoader` autoload scans `./mods/` on startup for custom content. Currently supports music replacement.

### Mod Structure
```
mods/
  my_music_mod/
    audio/
      audio_music_custom_track.main.ogg    <- loaded as menu music
  disabled_mod.disabled/                    <- skipped (disable suffix)
```

### Disable Suffixes
Mods with these suffixes in their path are skipped: `.disabled`, `.break`, `.remove`, `.no`, `.none`

### Integration
- `menu.gd` calls `ModLoader.get_mods_paths()` in `_ready()`
- `music_play()` checks `ModLoader.get_mods_list(0)` for mod music before falling back to default
- Mod music is loaded as `AudioStreamOggVorbis` with looping enabled

---

## Game Flow Summary

1. **Startup** → `init_screen.gd` routes to correct scene based on CLI args
2. **Menu** → Player configures settings via `menu.gd` → Saves to Global
3. **Game Start** → `board_ui._ready()` maps claims via `claim_colours`, generates board (host only), syncs to clients
4. **Player Turn** → Click tiles to expand territory (move cost: 1 normal, `blz_move_requrement` for blitz)
5. **Next Turn** → `game.on_next_turn()` executes AI moves with visual delays
6. **State Refresh** → `game.game_state_changed(true)` recalculates territory, fuel, moves
7. **Win/Loss** → Capital capture eliminates claims. LMS triggers win screen.

---

## Multiplayer Flow

### LAN Game
1. **Host** → Multiplayer menu → Host → Broadcasts on UDP 4444
2. **Client** → Multiplayer menu → Server appears in browser → Join
3. **Lobby** → Players pick claims via colour pickers → Host starts game
4. **In-Game** → Board state synced via RPCs. Host runs AI. All moves relayed.

### Dedicated Server (WAN)
1. **Server** → `--dedicated --port=7777` → Auto-hosts, prints banner
2. **Client** → Multiplayer menu → Enter IP:port → Join
3. **Lobby** → Same claim picking. Server logs to console.
4. **In-Game** → Server runs all host logic headlessly. Clients render UI.
5. **End** → Server returns to lobby, clients transition back.

### WebRTC Online (Experimental)
1. **Signaling Server** → WebSocket on port 8915
2. **Clients** → Connect to signaling server → Exchange WebRTC offers/answers
3. **P2P** → Mesh network topology via `WebRTCMultiplayerPeer`

---

## File Structure
```
scripts/
  global.gd              - Autoloaded singleton, settings, CLI parsing
  init_screen.gd         - Scene router based on CLI args
  mod_loader.gd          - Mod discovery and loading system
  claims/
    claim_data.gd        - Base claim resource (ClaimData)
    player_claim.gd      - Human player type (PlayerClaim)
    non_player_claim.gd  - AI opponent with personality weights (NonPlayerClaim)
    claim_lookup_table.gd - PC/NPC claim registry
  data/
    tile_data.gd         - Tile state, scoring, and tooltip generation
    profile_data.gd      - Game settings profile resource
  menus/
    menu.gd              - Base menu class (settings UI, mod music, profiles)
    menus_mp/
      menu_mp.gd         - Multiplayer lobby (hosting, joining, LAN broadcast)
  main_ui/
    game.gd              - Game manager (turns, state, win detection)
    board_ui.gd          - Board controller (tile grid, claiming, AI, generation)
  object/
    claim_data_panel.gd  - Claim info display panel
    moves_plate.gd       - Move counter with animations
    lobby_chat.gd        - Multiplayer lobby chat
    lobby_player_nameplate.gd - Player nameplate display
    profile_loader.gd    - Profile save/load manager
    profile_button.gd    - Profile selection button
  toutorial/
    toutorial.gd         - Tutorial controller
    board_toutorial.gd   - Tutorial board
    toutorial_button.gd  - Tutorial scene launcher

webrtc_toutorial/
  brc_mpol_tutorial.gd   - WebRTC shared state autoload
  brc_client.gd          - WebRTC client
  brc_server.gd          - WebRTC signaling server
  brc_lobby.gd           - Lobby data structure

levels/
  init_screen.tscn       - Entry scene
  menu.tscn              - Singleplayer/hotseat menu
  menu_mp.tscn           - Multiplayer lobby
  main_ui.tscn           - Game scene
  toutorial/toutorial.tscn - Tutorial level
  testing/               - Test scenes

Resources/
  claims/
    claim_lookup_table.tres        - Claim registry resource
    player_claims/*.tres           - 5 player claim resources (green, purple, yellow, red, blue)
    nonplayer_claims/*.tres        - 5 NPC claim resources (green, purple, yellow, red, blue)
  profiles/
    Alpha.tres, Classic.tres,      - Built-in game mode profiles
    Forts.tres, normal_mode.tres

mods/                              - User mod directory (scanned by ModLoader)
  mod_example.no/                  - Example mod (disabled)

export_presets.cfg                 - 3 presets: Dev Windows, macOS, Dedicated Server
```
