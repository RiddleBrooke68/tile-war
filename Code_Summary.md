# Tile War - Code Summary and Documentation

**Project:** Tile War  
**Engine:** Godot 4.5  
**Date:** February 15, 2026  

---

## Overview

**Tile War** is a turn-based strategy game built in Godot where multiple claims (players and AI) compete to capture territory on a tile-based board. Supports singleplayer/hotseat, LAN multiplayer, and **headless dedicated server** mode for WAN play.

---

## Core Components

### Data Models

#### tile_data.gd - Tile Information Resource
**Purpose:** Represents individual tile state and generates contextual tooltips.

**Core Properties:**
- `coords` - Grid position (Vector2i)
- `type` - Ownership state: 0=empty, 1=enemy, 2=player, 3=wall, -1=unavailable
- `tile_type` - Display label: "claim", "capital", "fuel", "wall"
- `available` - Can the player claim this tile this turn?

**Combat Calculation Properties:**
- `points` / `oppose_points` - Strength from surrounding tiles
- `fuel` / `oppose_fuel` - Combat modifiers from fuel resources
- `move_to_value` - AI heuristic score (higher = more valuable target)

**Key Function:**
- `get_info()` - Generates rich BBCode tooltip text based on tile type:
  - **Empty tiles:** Shows if claimable and tile type
  - **Enemy tiles:** Displays opponent name, their strength calculation, your attack strength, +1 attacker bonus
  - **Player tiles:** Shows your ownership and point generation
  - **Walls:** Simply states impassable

**Text Templates:** Uses string formatting with dictionaries to inject dynamic values into predefined tooltip templates.

---

#### claim_data.gd - Base Claim Resource
**Purpose:** Abstract base class defining common properties and behaviors for all claims.

**Properties:**
- `name` - Display name of the claim (e.g., "Red Kingdom")
- `claim_colour` (1-4) - Color ID mapping to tilemap layers
- `moves` - Remaining actions this turn
- `fuel_count` - Number of fuel tiles owned (boosts moves)
- `tile_size` - Total territory owned (all tiles controlled)
- `capatal_tile` - Grid coordinates of the capital (lose if captured)
- `claim_dead` - Elimination status flag
- `claim_mp_ip_linked` - Multiplayer peer ID linked to this claim

**Key Functions:**
- `refresh()` - Recalculates available moves using formula: `min(tile_size/2, max(tile_size/10, 15)) + fuel_count`. This ensures small territories get at least some moves, large territories don't get infinite moves, and fuel provides linear boost.
- `print_data()` - Debug logging of claim status
- `get_data()` - Formats claim info for UI display (tiles, fuel, name)

---

#### player_claim.gd - Human Player
**Purpose:** Identifies human-controlled claims (currently no special behavior, inherits everything from ClaimData).

**Note:** Empty implementation means player behavior is handled by UI interaction in board_ui.gd rather than scripted actions.

---

#### non_player_claim.gd - AI Opponent
**Purpose:** Implements AI decision-making for computer-controlled claims.

**Key Functions:**
- `claim_surounding_tiles(available)` - Main AI entry point. Takes array of claimable tiles, selects target based on AI level, returns chosen coordinates.
  - **AI Level 0 (Random):** Picks any available tile
  - **AI Level 1 (Strategic):** Filters to highest-value tiles, then randomly picks from best options
  
- `get_best_paths(available)` - Filters tile array to only include tiles matching the highest `move_to_value`. This creates a pool of equally good moves, adding variety while maintaining strategic play.

**Decision Output:** Prints selected tile and its value for debugging AI behavior.

---

### Configuration & Startup

#### global.gd - Global Configuration Singleton
**Purpose:** Autoloaded singleton that persists game settings across scenes.

**Pre-Generation Settings:**
- `map_type` (1) - Which map will be played

**Generation Settings:**
- `wall_count` (74) - Number of impassable wall tiles spawned on the board
- `fuel_count` (16) - Number of fuel tiles that boost movement/combat strength
- `cap_list` ([2,2,2,2]) - Number of capitals per claim

**Claim Configuration:**
- `claim_list : Array[int]` ([2,1,1,1]) - Per-claim status: 0=disabled, 1=bot, 2=player
- `claim_names : Array[String]` - Display names for each claim
- `claim_name_num` enum - Named constants: SPECTATOR(0), GREENWICH(1), PLUM_VALLEY(2), YORK_STREET(3), RIVER_SOLME(4)
- `player_enabled/purple_enabled/yellow_enabled/red_enabled` - Legacy toggles (@deprecated, use `claim_list`)

**AI Settings:**
- `ai_level` (1) - AI difficulty: 0=random, 1=strategic, 2=deep strategic (increases search `dist`)
- `dist` (2) - AI look-ahead tile scanning distance (auto-set by ai_level setter)

**Music/Audio:**
- `music_type` (0) - Active music track index
- `music_list` - Array of music file paths
- `music_vol` (10.0), `SFX_vol` (10.0) - Volume settings

**Game Rule Settings:**
- `lms_enabled` (true) - Last Man Standing: game ends when one claim remains
- `bran_enabled` (false) - Battle Random Result: adds d20 roll to combat
- `cdan_enabled` (true) - Capital Danger Protection: blocks attacks on a claim after losing a capital until their next turn
- `cdan_duration` (10) - Protection duration
- `cdan_capture_duration` (5) - Capital capture protection duration
- `blz_enabled` (true) - Blitz attack mode
- `blz_move_requrement` (5) - Moves required for blitz

**Movement Formula Settings:**
- `moves_tile_int_reduction_boost` (2) - Tile move divisor
- `moves_tile_int_lim_boost` (15) - Tile move cap
- `moves_tile_second_reduction_boost` (5) - Secondary tile divisor
- `moves_tile_second_lim_boost` (20) - Secondary tile cap
- `moves_fuel_reduction_boost` (2) - Fuel move divisor
- `moves_fuel_lim_boost` (5) - Fuel move cap
- `moves_turn_reduction_boost` (2) - Turn-based move divisor
- `moves_turn_lim_boost` (10) - Turn-based move cap

**Multiplayer State:**
- `mp_enabled` - Whether multiplayer is active
- `mp_host` - Whether this peer is the host
- `mp_server` - Whether this peer is acting as a server
- `mp_connected` - Connection status
- `mp_dedicated` (false) - **Headless dedicated server mode** (set by `--dedicated` CLI flag)
- `mp_port` (7777) - **Dedicated server port** (set by `--port=N`)
- `mp_server_name` ("") - **Dedicated server display name** (set by `--server_name=X`)
- `mp_player_id` - This peer's multiplayer ID
- `mp_player_list` (dict) - Connected peers: `{peer_id: {name, id, current_claim}}`
- `mp_ended_sesion` - Session end flag
- `mp_claims_colours` - Color mapping for each claim (including SPECTATOR grey)

**Multiplayer Online (WIP/WebRTC):**
- `mpol_svr_users`, `mpol_svr_lobbies` - Server-side lobby tracking
- `mpol_svr_host` - Whether this peer is the online server host
- `mpol_clnt_lobbies`, `mpol_clnt_connected` - Client-side lobby tracking

**CLI Argument Parsing (`_ready()`):**  
Parses `OS.get_cmdline_args()` into `cmd_args` dictionary. Supports:
- `--dedicated` → Sets `mp_dedicated = true`, `mp_server = true`
- `--port=N` → Sets `mp_port` (validated 1024-65535)
- `--server_name=X` → Sets `mp_server_name`
- `--music_type=N` → Sets music track
- `--map_type=N` → Sets map type

---

#### init_screen.gd - Scene Router
**Purpose:** Entry point that routes to the correct scene based on CLI arguments.

**Routing Priority:**
1. `--help_tw` / `-h` → Print CLI help text and quit
2. `--dedicated` → `screen = 1` (menu_mp.tscn) — **highest priority game route**
3. `--mp_start_server` → `screen = 1` (menu_mp.tscn)
4. `--multiplayer` / `--mp` → `screen = 1` (menu_mp.tscn)
5. `--brc_testing` → `screen = 2` (brc_testing.tscn)
6. Default → `screen = 0` (menu.tscn)

**Available CLI Help Flags Documented:**
- `--dedicated` — Starts a headless dedicated server
- `--port=N` — Server port (default 7777, range 1024-65535)
- `--server_name=X` — Server display name
- `--mp_start_server` — Starts multiplayer and auto-hosts a LAN server

---

### Menu System

#### menu.gd - Base Menu Controller
**Purpose:** Manages the settings menu and game initialization. Base class extended by `menu_mp_class`.

**Dedicated Server Guards:** When `Global.mp_dedicated` is true, the entire `_ready()` UI initialization is skipped. `sound_play()` and `music_play()` return immediately. All RPC functions that touch UI nodes (`_on_map_setting_item_selected`, `_on_wall_slider_value_changed`, `_on_fuel_slider_value_changed`, all claim type/cap selectors, `_on_change_ai_level`, `_on_music_type_setting_item_selected`, `_on_lms_setting_toggled`, `_on_bran_setting_toggled`, `_on_cdan_setting_toggled`, `_on_cdan_slider_value_changed`, `_on_cdan_cd_slider_value_changed`, `_on_blz_setting_toggled`, `_on_blz_slider_value_changed`, `_on_movement_setting_changed`) guard their UI node accesses with `if not Global.mp_dedicated:` while still updating `Global.*` data variables for game logic consistency.

**Key Functions:**
- `_ready()` - Initializes UI sliders and dropdowns with saved Global values (skipped on dedicated)
- `_on_wall_slider_value_changed(value)` - Updates wall count in real-time, syncs to Global
- `_on_fuel_slider_value_changed(value)` - Updates fuel count display and Global storage
- `_on_[color]_setting_toggled(toggled_on)` - Enables/disables specific claims from participating
- `_on_start_game()` - Transitions to main game scene (main_ui.tscn)
- `_on_change_ai_level(index)` - Sets AI difficulty level
- `sound_play(type)` - Plays click SFX (guarded: no-op when dedicated)
- `music_play()` - Starts background music (guarded: no-op when dedicated)

**RPC Pattern:** All settings are `@rpc("any_peer")` with `mp_player_source` flag to prevent infinite relay loops. The host broadcasts setting changes; clients apply them.

---

#### menu_mp.gd - Multiplayer Lobby Controller (778 lines)
**Purpose:** Manages LAN/WAN multiplayer lobby — hosting, joining, server browser, claim picking, game start. Extends `menu_class`.

**Key Properties:**
- `peer : ENetMultiplayerPeer` - The networking peer
- `peerUDP : PacketPeerUDP` - UDP socket for LAN broadcast discovery (null on dedicated)
- `address` / `address_broadcast` - IP addresses for LAN connectivity
- `port` - ENet listener port
- `server_name` / `client_name` - Display names

**Dedicated Server Mode (`_ready()`):**
When `Global.mp_dedicated` is true:
1. Sets `client_name = "DedicatedServer"`, `server_name` from env or `--server_name`
2. Sets `port = Global.mp_port`
3. Connects `mp_player_list_changed` to `_dedicated_log_player_list()` instead of the UI updater
4. Skips peerUDP binding (no LAN broadcast)
5. Skips client-only signal connections (`connected_to_server`, `connection_failed`)
6. Skips all UI node initialization
7. Auto-calls `_on_host_button_down()` to start the server immediately

**Console Output (Dedicated):**
- Startup banner with port, name, and IP
- Player connect/disconnect events
- Player list with claim assignments (via `_dedicated_log_player_list()`)
- Game start/end notifications

**Claim Picker RPCs (`_on_green/purple/yellow/red_picker_toggled`):**
Guard all `.item_selected.emit()`, `.disabled`, `picker.disabled`, `name.text` with `if not Global.mp_dedicated:`. Always update `Global.claim_list` and `Global.claim_names` for data consistency.

**Player Management:**
- `player_connected(id)` - Adds peer to `mp_player_list`, sends existing player data via RPCs
- `player_disconnected(id)` - Removes peer, frees their claim slot
- `send_player_data()` / `load_profile_data()` / `remove_player_data()` - Sync claim assignments. Dedicated path updates Global data directly.
- `server_disconnected()` - Dedicated prints to console instead of showing `OS.alert()`

**Game Lifecycle:**
- `start_game()` - Instantiates the game scene. Guards `timer.stop()` and `self.hide()`.
- `end_game()` - Returns to lobby. Guards `timer.start()` and `self.show()`.

**Host Button (`_on_host_button_down()`):**
- Creates `ENetMultiplayerPeer`, calls `create_server(port)` 
- On dedicated: prints startup banner with port/name/IPs, skips LAN broadcast/UI
- On client: shows lobby UI, starts broadcast timer

**LAN Broadcast:**
- `update_broadcast_server_staius()` - Sends server info via UDP broadcast (guarded: no-op on dedicated)
- `update_broadcast_server_closed()` - Broadcasts server shutdown (guarded: no-op on dedicated)
- `_process()` - Reads incoming broadcast packets for server browser (guarded: no-op on dedicated)

---

### Game Logic

#### board_ui.gd - Board Controller (~850 lines - Core Game Logic)
**Purpose:** The brain of the game - manages the tile grid, validates moves, handles AI pathfinding, and tracks game state.

##### Signals
- `game_state_change` - Notifies game manager when board state updates
- `tile_info(data)` - Sends tile information for tooltip display

##### Initialization (_ready())
1. **Sound creation** - Guarded with `if not Global.mp_dedicated:` (sound is null on dedicated)
2. Loads enabled claims from Global settings
3. Calculates board boundaries from tilemap
4. Uses `rcoord()` callable to generate random valid spawn positions
5. Places capitals for each enabled claim (ensures 3+ tile separation)
6. Spawns walls and fuel tiles until reaching Global counts
7. Validates final counts with debug prints
8. `OS.alert()` calls on generation errors are guarded for dedicated (print-only)
9. Serializes board state and sends to clients via `mp_update_board_state.rpc()`

##### Input Handling
- `_process()` - Tracks mouse position, updates overlay grid. **Early return on dedicated.**
- `_on_gui_input()` - Left-click attempts to claim tile, plays success/failure sounds. **Early return on dedicated.**
- `_on_mpui_input()` - Remote player input via RPC. Sound accesses guarded with `if not Global.mp_dedicated:`.
- `hovered` / `lock_mode` / `off_input` - Flags controlling interaction state

##### Core Claiming Function
**`on_claim_tile(coords, claim, type, update, terain)`**
- Sets tile ownership on main_grid
- If claiming capital (`type=1`), automatically claims surrounding tiles in cascade
- Emits `game_state_change` signal to update UI and refresh claim data
- Calls `game.print_data_to_game()` for event logging

##### Validation System

**`check_tile_claimably(coords, claim, test_suroundings)`** - Central validation function (100+ lines)
1. **Connectivity Check:** Uses `find_linked_tiles()` to ensure tile is adjacent to your territory
2. **Null Check:** Returns false if tile doesn't exist
3. **Own Tile:** If already owned, calculates point generation from neighbors
4. **Enemy Tile (Combat):** Calculates attack vs defense with full modifiers
5. **Empty Tile:** Simply checks if adjacent to your territory
6. **Wall Tile:** Always returns false

##### AI Support Functions

**`get_all_avalable_tiles(claim)`** - Scans entire board for claimable tiles, scores with `move_to_value`

**`search_surounding_tiles(tile, distance, claim)`** - Recursive neighbor scanning for AI heuristics

**`find_linked_tiles(tile, other, claim)`** - Recursive pathfinding to verify tile connectivity

##### Multiplayer Board Sync

**`serialize_pattern()`** - Serializes the full board state into a transmittable format.

**`mp_update_board_state.rpc()`** - Sends serialized board to all clients after generation (host/dedicated only).

---

#### game.gd - Game Manager (~426 lines)
**Purpose:** Orchestrates turn flow, manages claim states, and updates UI displays.

##### Node References
- `board_ui` - The board controller
- `next_turn` - Button to advance turns
- `tile_info` - Label showing hovered tile details
- `game_info` - Label for game status messages
- `claims_info` - Multi-line display of all claims' statistics
- `clock` - Timer for AI move delays (creates visible turn animations)
- `moves_plate` - Displays remaining moves with color
- `winers_name` / `win_animiate` - Win screen elements
- `game_event_recorder` - Chat/event log display
- `music` - AudioStreamPlayer (null on dedicated — creation guarded)
- `fade_anim` - Scene transition animation

##### Dedicated Server Guards
All UI-updating functions guard node accesses with `if not Global.mp_dedicated:`:
- `next_turn.disabled` assignments
- `claims_info.text`, `winers_name.text` assignments
- `moves_plate.number`, `moves_plate.colour`, `moves_plate.update_plate_display()` calls
- `board_ui.action_grid.clear()` and `board_ui.action_grid.set_cell()` calls
- `win_animiate.play("win")` animation
- `game_event_recorder.text` assignment
- `tile_info.text`, `game_info.text` assignments

##### Key Functions

**`on_next_turn()`** - Turn execution sequence:
1. Disables next_turn button (guarded)
2. For each living AI claim: executes moves with clock delays
3. For each living player claim: sets them as active and breaks
4. Re-enables next_turn button (guarded)
5. Calls `game_state_changed()` to refresh state

**`game_state_changed(refresh)`** - Central state update:
1. Iterates all claims, checks dead status via capital check
2. Updates `tile_size`, `fuel_count` from board
3. Refreshes moves when `refresh=true`
4. Picks next active player, syncs via `mp_sync_movement.rpc()`
5. Sets `board_ui.off_input` based on whose turn it is
6. Updates UI elements (all guarded for dedicated)
7. LMS win detection: prints winner name to console when dedicated

**`print_data_to_game(_str)`** - `@rpc("any_peer")` - Event log function. Relays text to all peers. Guards `game_event_recorder.text` for dedicated. Keeps `game_event_text` string updated for data consistency.

**`gui_board_events(target)`** - Updates available move display after a tile claim. Guards `board_ui.action_grid` and `moves_plate` for dedicated.

**`_on_board_tile_info(data)`** - Tooltip handler. **Early return on dedicated.**

**`_on_chat_input_text_submitted(new_text)`** - Chat input handler. **Early return on dedicated.**

**`set_active_player(claim)`** - Sets the current active claim, duplicates it, scans available moves. Guards `moves_plate.colour` for dedicated.

**`new_game()`** - `@rpc("any_peer")` - Resets all claims. On dedicated: prints to console and emits `mp_back_to_lobby` immediately (no fade animation). On client: plays fade-out animation and music tween.

**`mp_sync_movement.rpc()`** - Syncs claim move counts between peers.

**`update_active_player.rpc()`** - Host tells clients which claim is currently active.

---

## Dedicated Server Architecture

### Design Decision
The dedicated server reuses the same `menu_mp.tscn` scene with `if not Global.mp_dedicated:` guards on all UI/audio/animation accesses. This ensures all RPC node paths match between client and server (Godot RPCs are path-based).

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

**Client (LAN, existing):**
Open game → Multiplayer → Server browser auto-discovers via UDP broadcast

### Export
`export_presets.cfg` contains `[preset.2]` "Dedicated Server (Windows)" with `dedicated_server=true`. This strips rendering libraries for a smaller server binary.

---

## Game Mechanics

### Board Setup
1. Creates 7x10 grid with randomly placed capitals for each enabled claim
2. Spawns walls (impassable tiles) and fuel tiles (boost movement/attack) based on global settings
3. Each placement ensures minimum 3-tile separation between special tiles

### Turn System
1. Player makes moves (limited by move count calculated from territory size + fuel)
2. AI claims execute their moves sequentially with visual delays
3. Move count refreshes each turn based on configurable formula using tile size, fuel count, and turn number

### Tile Claiming
- Must be adjacent to your existing territory
- Attacking enemy tiles requires superior neighboring tile count + fuel bonus
- Capital tiles provide +3 strength, fuel tiles provide +2/-1 modifiers
- Capturing enemy capital eliminates that claim

### Capital Danger Protection (CDAN)
When enabled, a claim that loses a capital is protected from further attacks for a configurable number of turns.

### Blitz Attack (BLZ)
When enabled, allows special attack moves if the player has enough remaining moves.

### Strategic Value Calculation
The AI evaluates tiles using recursive neighbor scanning (`dist` tiles deep, set by AI level), with 2x multipliers for enemy tiles and fuel tiles, creating a heuristic for optimal expansion.

### Win Condition
Last claim with a capital standing wins. Claims are eliminated when their capital is captured.

---

## Game Flow Summary

1. **Menu** → Player configures settings → Saves to Global
2. **Game Start** → board_ui spawns capitals, walls, fuel (host generates, syncs to clients)
3. **Player Turn** → Click tiles to expand (limited by move count)
4. **Next Turn Button** → AI claims execute moves with visual delays
5. **State Refresh** → Recalculate territory sizes, fuel bonuses, move counts
6. **Win/Loss** → When capital captured, claim is eliminated. LMS triggers win screen.

---

## Multiplayer Flow

### LAN Game
1. **Host** → Opens MP menu → Clicks Host → Broadcasts on UDP 4444
2. **Client** → Opens MP menu → Server appears in browser → Click Join
3. **Lobby** → Players pick claims via color pickers → Host starts game
4. **In-Game** → Board state synced via RPCs. Host runs AI. All moves relayed.

### Dedicated Server (WAN)
1. **Server** → Launched with `--dedicated --port=7777` → Auto-hosts, prints banner
2. **Client** → Opens MP menu → Types server IP:port → Click Join
3. **Lobby** → Same claim picking flow. Server logs to console.
4. **In-Game** → Server runs all host logic headlessly. Clients get UI.
5. **End Game** → Server returns to lobby state, clients transition back.

---

## Architecture Notes

The architecture separates concerns cleanly:
- **Data Models:** ClaimData, tile_data - Pure resource classes
- **Game Logic:** board_ui - Core mechanics and validation
- **Turn Management:** game - Orchestration and state updates
- **Configuration:** Global, menu - Settings persistence and UI
- **Networking:** menu_mp - ENet peer management and lobby
- **Dedicated Server:** Same scene tree as clients; `Global.mp_dedicated` flag gates all UI/audio/animation operations

### File Structure
```
scripts/
  global.gd          - Autoloaded singleton, settings, CLI parsing
  init_screen.gd     - Scene router based on CLI args
  claims/            - ClaimData, PlayerClaim, NonPlayerClaim resources
  data/              - tile_data resource
  menus/
    menu.gd          - Base menu class (settings UI + RPC sync)
    menus_mp/
      menu_mp.gd     - Multiplayer lobby controller
  main_ui/
    game.gd          - Game manager (turns, state, win detection)
    board_ui.gd      - Board controller (tile grid, claiming, AI)
  object/            - UI object scripts (lobby plates, etc.)
  toutorial/         - Tutorial scripts
levels/
  init_screen.tscn   - Entry scene
  menu.tscn          - Singleplayer/hotseat menu
  menu_mp.tscn       - Multiplayer lobby
  main_ui.tscn       - Game scene
export_presets.cfg   - 3 presets: Dev Windows, macOS, Dedicated Server
```

This modular design allows for easy extension of features like new tile types, additional AI strategies, or alternative networking backends (WebRTC online multiplayer is in progress under `webrtc_toutorial/`).
