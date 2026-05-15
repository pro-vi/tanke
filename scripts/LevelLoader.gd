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
#   -  ice         — iter 003 PHASE-1 DECISION: pass-through (no physics).
#                    Renders to iceTileMap if the level exposes it; else
#                    counted in ice_skipped (legacy iter-1 behavior).
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


static func parse_stage(level: Node, stage_number: int, col_offset: int = 7, row_offset: int = 2, stages_dir_override: String = "") -> Dictionary:
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
	# iter 013: optional stages_dir_override lets edge-case tests point at
	# /tmp fixtures without writing into .research/repos/Tanks/ (H2 tripwire).
	# Default behavior (override empty) reads the canonical source — preserves
	# the iter-1-through-12 behavior bit-identical.
	var path: String
	if stages_dir_override == "":
		path = ProjectSettings.globalize_path("res://") + TANKS_STAGES_REL + str(stage_number)
	else:
		var sep: String = "" if stages_dir_override.ends_with("/") else "/"
		path = stages_dir_override + sep + str(stage_number)
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
					# iter 003: pass-through decision — place a decorative ice
					# cell on iceTileMap when present. Tank physics unaffected
					# (no collision layer on iceTileMap). Falls back to skip-
					# count when level lacks an iceTileMap (caps C3 at 2/5).
					if "iceTileMap" in level and level.iceTileMap != null:
						level.iceTileMap.set_cell(coord, ATLAS_SOURCE, ATLAS_COORDS)
						result["ice"] = result.get("ice", 0) + 1
					else:
						result.ice_skipped += 1
				_:
					result.unknown += 1
	result.ok = (result.error == "" and result.unknown == 0)
	return result
