# Arc-4 Q1 sprint mid-correction (iter 287):
# Verifies the Q1ProofRoom parser module — TILE_GRID well-formed +
# lane-aware helpers return expected values for the 4-lane gate layout.
# This is the SCAFFOLD for the playable scene (iter 288+).
#
# Verifies:
#   1. TILE_GRID validates (30 rows × 21 cols, no malformed rows).
#   2. Each lane has a player-start column at PLAYER_START_ROW (29).
#   3. Each lane has gate-row cells of the expected type:
#      - HE lane (cols 0-4):   ≥5 brick "B" cells
#      - APCR lane (cols 5-9): ≥3 steel "S" cells
#      - HEAT lane (cols 10-14): ≥1 Heavy "H" cell
#      - AP lane (cols 15-20):   ≥1 Light "L" cell, no steel/brick/Heavy
#   4. The goal row (0) has at least 1 goal "X" marker in each lane.
#   5. terrain_at out-of-bounds → empty string (defensive).
#   6. grid_to_pixel converts cells to scene-space using 16-px grid.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_q1_proof_parser.gd

extends SceneTree

const Q1ProofRoomT = preload("res://scripts/Q1ProofRoom.gd")


func _initialize() -> void:
	# === Case 1: TILE_GRID well-formed.
	var errs: Array[String] = Q1ProofRoomT.validate_grid()
	if not errs.is_empty():
		push_error("FAIL — grid validation errors: %s" % str(errs))
		quit(1); return
	if Q1ProofRoomT.TILE_GRID.size() != Q1ProofRoomT.GRID_ROWS:
		push_error("FAIL — TILE_GRID has %d rows, want %d" \
				% [Q1ProofRoomT.TILE_GRID.size(), Q1ProofRoomT.GRID_ROWS])
		quit(1); return
	print("  grid: %d rows × %d cols, all uniform width" \
			% [Q1ProofRoomT.GRID_ROWS, Q1ProofRoomT.GRID_COLS])

	# === Case 2: each lane has a player-start column.
	var lane_names: Array[String] = ["HE", "APCR", "HEAT", "AP"]
	for lane in lane_names:
		var col: int = Q1ProofRoomT.player_start_col(lane)
		if col < 0:
			push_error("FAIL — lane %s has no player-start marker at row %d" \
					% [lane, Q1ProofRoomT.PLAYER_START_ROW])
			quit(1); return
		# Validate the col is inside the lane's range.
		var lane_range: Array = Q1ProofRoomT.LANES[lane]
		if col < lane_range[0] or col > lane_range[1]:
			push_error("FAIL — lane %s player_start_col %d outside range [%d, %d]" \
					% [lane, col, lane_range[0], lane_range[1]])
			quit(1); return
	print("  player starts: HE=%d APCR=%d HEAT=%d AP=%d" % [
		Q1ProofRoomT.player_start_col("HE"),
		Q1ProofRoomT.player_start_col("APCR"),
		Q1ProofRoomT.player_start_col("HEAT"),
		Q1ProofRoomT.player_start_col("AP"),
	])

	# === Case 3: gate-row cells match expected gate type per lane.
	# HE: ≥5 bricks
	var he_gates: Array = Q1ProofRoomT.gate_cells_for_lane("HE")
	var he_bricks: int = 0
	for g in he_gates:
		if g[2] == "B":
			he_bricks += 1
	if he_bricks < 5:
		push_error("FAIL — HE lane has %d brick cells at gate, want ≥5" % he_bricks)
		quit(1); return
	# APCR: ≥3 steel
	var apcr_gates: Array = Q1ProofRoomT.gate_cells_for_lane("APCR")
	var apcr_steel: int = 0
	for g in apcr_gates:
		if g[2] == "S":
			apcr_steel += 1
	if apcr_steel < 3:
		push_error("FAIL — APCR lane has %d steel cells at gate, want ≥3" % apcr_steel)
		quit(1); return
	# HEAT: ≥1 Heavy
	var heat_gates: Array = Q1ProofRoomT.gate_cells_for_lane("HEAT")
	var heat_heavies: int = 0
	for g in heat_gates:
		if g[2] == "H":
			heat_heavies += 1
	if heat_heavies < 1:
		push_error("FAIL — HEAT lane has %d Heavy markers at gate, want ≥1" % heat_heavies)
		quit(1); return
	# AP: ≥1 Light, no steel/brick/Heavy
	var ap_gates: Array = Q1ProofRoomT.gate_cells_for_lane("AP")
	var ap_lights: int = 0
	for g in ap_gates:
		if g[2] == "L":
			ap_lights += 1
		if g[2] == "S" or g[2] == "B" or g[2] == "H":
			push_error("FAIL — AP lane gate contains non-AP-domain tile '%s'" % g[2])
			quit(1); return
	if ap_lights < 1:
		push_error("FAIL — AP lane has %d Light markers at gate, want ≥1" % ap_lights)
		quit(1); return
	print("  gate cells per lane: HE=%dB APCR=%dS HEAT=%dH AP=%dL (route-currency design intact)" \
			% [he_bricks, apcr_steel, heat_heavies, ap_lights])

	# === Case 4: goal row has X markers spanning all lanes.
	for lane in lane_names:
		var lane_range: Array = Q1ProofRoomT.LANES[lane]
		var has_goal: bool = false
		for col in range(lane_range[0], lane_range[1] + 1):
			if Q1ProofRoomT.terrain_at(col, Q1ProofRoomT.GOAL_ROW) == "X":
				has_goal = true
				break
		if not has_goal:
			push_error("FAIL — lane %s missing goal X marker at row %d" \
					% [lane, Q1ProofRoomT.GOAL_ROW])
			quit(1); return
	print("  goal row: all 4 lanes have ≥1 X marker (reachability target exists)")

	# === Case 5: out-of-bounds terrain_at returns empty string.
	if Q1ProofRoomT.terrain_at(-1, 0) != "":
		push_error("FAIL — terrain_at(-1, 0) should return '', got '%s'" \
				% Q1ProofRoomT.terrain_at(-1, 0))
		quit(1); return
	if Q1ProofRoomT.terrain_at(Q1ProofRoomT.GRID_COLS, 0) != "":
		push_error("FAIL — terrain_at(GRID_COLS, 0) should return '', got '%s'" \
				% Q1ProofRoomT.terrain_at(Q1ProofRoomT.GRID_COLS, 0))
		quit(1); return
	if Q1ProofRoomT.terrain_at(0, Q1ProofRoomT.GRID_ROWS) != "":
		push_error("FAIL — terrain_at(0, GRID_ROWS) should return '', got '%s'" \
				% Q1ProofRoomT.terrain_at(0, Q1ProofRoomT.GRID_ROWS))
		quit(1); return
	print("  out-of-bounds: terrain_at returns '' (defensive)")

	# === Case 6: grid_to_pixel converts at 16-px grid.
	var p: Vector2 = Q1ProofRoomT.grid_to_pixel(3, 5, 16)
	if not (absf(p.x - 48.0) < 0.01 and absf(p.y - 80.0) < 0.01):
		push_error("FAIL — grid_to_pixel(3, 5, 16) = %s, want (48, 80)" % str(p))
		quit(1); return
	# Default grid_size = 16
	var p2: Vector2 = Q1ProofRoomT.grid_to_pixel(0, 0)
	if not (absf(p2.x) < 0.01 and absf(p2.y) < 0.01):
		push_error("FAIL — grid_to_pixel(0, 0) should be Vector2.ZERO, got %s" % str(p2))
		quit(1); return
	print("  grid_to_pixel: 16-px grid math correct (default + explicit)")

	print("BREACH_Q1_PROOF_PARSER_OK 6 cases — grid valid / starts / gates / goal / OOB / pixel math")
	quit(0)
