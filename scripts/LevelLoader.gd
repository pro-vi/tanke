class_name LevelLoader
extends RefCounted

# Parses krystiankaluzny/Tanks ASCII grid files into TileMapLayer set_cell
# calls on a Level node (anything that exposes brickTileMap / steelTileMap /
# grassTileMap / waterTileMap — i.e. Level.gd or a subclass).
#
# Legend (verified against .research/synthesis-bc-level-sources-2026-05-13.md):
#   .  empty       — no cell placed
#   #  brick       — destructible; brickTileMap
#   @  steel       — indestructible; steelTileMap
#   %  forest      — decorative + hide rule; grassTileMap
#   ~  water       — blocks tanks; waterTileMap
#   -  ice         — DEFERRED to phase-1 decision iter (criterion 3)
#
# Tanks's ASCII grid is 26 rows × 26 columns (one char per 8-px sub-brick).
# tanke viewport is 40×30 cells at 8 px → center horizontally at col_offset=7
# leaves 7 cells of border each side; vertical offset 2 leaves 2-cell HUD strip
# at the top and 2-cell bottom border (26 + 2 + 2 = 30 — exact fit).
#
# H2 tripwire (arc 3): reads from .research/repos/Tanks/resources/stages/N
# WITHOUT modifying the source; goes through OS-level FileAccess (via
# ProjectSettings.globalize_path) because Godot's res:// filter may skip
# dotfile-prefixed directories.

const TANKS_STAGES_REL := ".research/repos/Tanks/resources/stages/"
const ROWS := 26
const COLS := 26

# Atlas source/coords match the TileSet definitions in OriginalLevel.tscn
# and ProceduralLevel.tscn — source 0, coord (0,0).
const ATLAS_SOURCE := 0
const ATLAS_COORDS := Vector2i(0, 0)


static func parse_stage(level: Node, stage_number: int, col_offset: int = 7, row_offset: int = 2) -> Dictionary:
	var result := {
		"ok": false,
		"stage": stage_number,
		"path": "",
		"brick": 0,
		"steel": 0,
		"grass": 0,
		"water": 0,
		"ice_skipped": 0,
		"unknown": 0,
		"error": "",
	}
	var path: String = ProjectSettings.globalize_path("res://") + TANKS_STAGES_REL + str(stage_number)
	result.path = path
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		result.error = "open failed: %s (FileAccess err %d)" % [path, FileAccess.get_open_error()]
		return result
	var text: String = f.get_as_text()
	f.close()
	# Normalize: split on \n, strip \r, drop a trailing empty line if present.
	var raw_lines := text.split("\n")
	var lines: PackedStringArray = PackedStringArray()
	for ln in raw_lines:
		var s: String = ln.strip_edges(false, true)  # strip trailing only (preserve leading dots)
		if s.is_empty() and lines.size() >= ROWS:
			continue
		lines.append(s)
	if lines.size() < ROWS:
		result.error = "expected %d rows, got %d" % [ROWS, lines.size()]
		return result
	for r in ROWS:
		var line: String = lines[r]
		if line.length() < COLS:
			result.error = "row %d has %d chars (need %d): %s" % [r, line.length(), COLS, line]
			return result
		for c in COLS:
			var ch: String = line.substr(c, 1)
			var coord := Vector2i(c + col_offset, r + row_offset)
			match ch:
				".":
					pass
				"#":
					level.brickTileMap.set_cell(coord, ATLAS_SOURCE, ATLAS_COORDS)
					result.brick += 1
				"@":
					level.steelTileMap.set_cell(coord, ATLAS_SOURCE, ATLAS_COORDS)
					result.steel += 1
				"%":
					level.grassTileMap.set_cell(coord, ATLAS_SOURCE, ATLAS_COORDS)
					result.grass += 1
				"~":
					level.waterTileMap.set_cell(coord, ATLAS_SOURCE, ATLAS_COORDS)
					result.water += 1
				"-":
					# Phase-1 decision iter pending (criterion 3); for now skip.
					result.ice_skipped += 1
				_:
					result.unknown += 1
	result.ok = (result.error == "" and result.unknown == 0)
	return result
