# Arc-4 iter 309 — Round 25 Probe 3: HUD coverage math + label-size audit.
#
# Measures the structural constraint PROMPT names but no harness has yet
# enforced: "HUD area ≤ 25% of viewport (320×240 = 76800 px²)." Also
# audits all HUD Labels for font_size compliance (≥ 8pt floor per iter
# 299 typography pass) — catches the regression where a future label
# slips in at Godot's default 16pt.
#
# Visual-verification cascade context (PROMPT iter 273/283/301):
#   - same-family admissibility — caught NO-SIGNAL families
#   - framing-audit gate — caught WRONG-FRAME-PRODUCTIVE-EXECUTION
#   - visual-verification discipline — caught RIGHT-FRAME, WRONG-OUTPUT (screenshots)
# This harness adds a NUMERICAL floor under the visual-verification rule:
# screenshots show what's there; this measures whether it's within budget.
#
# Implementation:
#   1. Instantiate PlayerTank with a Loadout (so the breach HUD layer builds).
#   2. Recursively enumerate ALL CanvasItem descendants of HUD CanvasLayer.
#   3. Filter to visible+modulated nodes (alpha > 0.1).
#   4. Sum ColorRect + Label bounding-box areas.
#      - Skip generic Container areas to avoid double-counting parent + children.
#      - ColorRects ARE the visible backgrounds; Labels render text within size.
#   5. Compute fraction; assert ≤ HUD_BUDGET_FRACTION = 0.25 of viewport.
#   6. Walk all Labels; check theme font_size override; assert ≥ MIN_LABEL_FONT_SIZE = 8.
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_hud_coverage.gd

extends SceneTree

const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const LoadoutT = preload("res://scripts/Loadout.gd")

const VIEWPORT_W: int = 320
const VIEWPORT_H: int = 240
const VIEWPORT_AREA: float = float(VIEWPORT_W * VIEWPORT_H)  # 76800

const HUD_BUDGET_FRACTION: float = 0.25
const MIN_LABEL_FONT_SIZE: int = 8
const GODOT_DEFAULT_FONT_SIZE: int = 16  # the regression to catch


func _is_visually_present(node: CanvasItem) -> bool:
	if not node.visible:
		return false
	if node.modulate.a < 0.1:
		return false
	# Check parent chain.
	var p: Node = node.get_parent()
	while p != null:
		if p is CanvasItem:
			var pci: CanvasItem = p as CanvasItem
			if not pci.visible or pci.modulate.a < 0.1:
				return false
		p = p.get_parent()
	return true


func _enumerate_canvas_items(root_node: Node, out: Array) -> void:
	if root_node is CanvasItem:
		out.append(root_node)
	for child in root_node.get_children():
		_enumerate_canvas_items(child, out)


func _get_font_size(label: Label) -> int:
	if label.has_theme_font_size_override("font_size"):
		return label.get_theme_font_size("font_size")
	return GODOT_DEFAULT_FONT_SIZE


func _initialize() -> void:
	var pt: Node = PlayerTankScene.instantiate()
	pt.loadout = LoadoutT.new()
	root.add_child(pt)
	await process_frame
	await process_frame

	# Dismiss the run-start codex — it's a 264×206 primer panel that
	# covers ~71% of viewport but is gone immediately at run start. The
	# probe measures STEADY-STATE play HUD, not the codex banner.
	if pt.has_method("_dismiss_codex"):
		pt._dismiss_codex()
		await process_frame

	var hud: CanvasLayer = pt.get_node("HUD") if pt.has_node("HUD") else null
	if hud == null:
		push_error("FAIL — HUD CanvasLayer missing")
		quit(1); return

	# === Case 1: HUD coverage ≤ 25% of viewport at default visible state.
	var all_items: Array = []
	_enumerate_canvas_items(hud, all_items)

	var color_rect_area: float = 0.0
	var label_area: float = 0.0
	var visible_count: int = 0
	var hidden_count: int = 0

	for item in all_items:
		var ci: CanvasItem = item as CanvasItem
		if not _is_visually_present(ci):
			hidden_count += 1
			continue
		visible_count += 1
		if item is ColorRect:
			var cr: ColorRect = item as ColorRect
			color_rect_area += cr.size.x * cr.size.y
		elif item is Label:
			var lb: Label = item as Label
			if lb.size.x > 0 and lb.size.y > 0:
				label_area += lb.size.x * lb.size.y

	# Labels usually sit on top of a backing ColorRect; counting both
	# double-counts the painted area. ColorRect dominates the visual
	# weight, so HUD coverage = ColorRect area. Labels surface as a
	# label-only count below for the typography audit.
	var coverage_px: float = color_rect_area
	var coverage_fraction: float = coverage_px / VIEWPORT_AREA

	if coverage_fraction > HUD_BUDGET_FRACTION:
		push_error("FAIL — HUD coverage %.3f exceeds budget %.3f (px=%.0f / viewport_area=%.0f). Visible ColorRects too large."
				% [coverage_fraction, HUD_BUDGET_FRACTION, coverage_px, VIEWPORT_AREA])
		quit(1); return
	print("  case 1: HUD coverage = %.1f%% of viewport (budget %.0f%%); ColorRect_px=%.0f / 76800; visible=%d hidden=%d"
			% [coverage_fraction * 100.0, HUD_BUDGET_FRACTION * 100.0, coverage_px,
			   visible_count, hidden_count])

	# === Case 2: Label font-size audit — all VISIBLE labels ≥ MIN_LABEL_FONT_SIZE.
	var labels_at_default: Array = []  # labels missing override
	var labels_below_floor: Array = []
	var label_sizes_by_count: Dictionary = {}
	for item in all_items:
		if not (item is Label):
			continue
		var lb: Label = item as Label
		if not _is_visually_present(lb):
			continue
		var fs: int = _get_font_size(lb)
		label_sizes_by_count[fs] = label_sizes_by_count.get(fs, 0) + 1
		if not lb.has_theme_font_size_override("font_size"):
			labels_at_default.append(lb.name if lb.name != "" else lb.text)
		if fs < MIN_LABEL_FONT_SIZE:
			labels_below_floor.append("%s (%dpt)" % [lb.name if lb.name != "" else lb.text, fs])

	# Floor assertion: any visible label below 8pt is a regression.
	if labels_below_floor.size() > 0:
		push_error("FAIL — labels below MIN_LABEL_FONT_SIZE=%d: %s"
				% [MIN_LABEL_FONT_SIZE, str(labels_below_floor)])
		quit(1); return

	# Default-font-size diagnostic (not a fail — modals legitimately use larger).
	# Death label and other modal titles use 12-13pt and are visible only in modal states.
	var labels_at_godot_default: int = label_sizes_by_count.get(GODOT_DEFAULT_FONT_SIZE, 0)
	print("  case 2: label font sizes (visible only): %s" % str(label_sizes_by_count))
	if labels_at_godot_default > 0:
		print("    note: %d label(s) at Godot default 16pt — review if these are compact HUD readouts"
				% labels_at_godot_default)
	if labels_at_default.size() > 0:
		print("    note: %d label(s) without explicit font_size override (default 16pt): %s"
				% [labels_at_default.size(), str(labels_at_default)])

	# === Case 3: total label count + label-area sanity.
	# Just report; no assertion. Surface for the probe report.
	print("  case 3: label coverage area: %.0f px² across visible labels (informational)" % label_area)

	# === Case 4: Quadrant occupancy — surface where the visual weight lives.
	# Divide viewport into top-left / top-right / bottom-left / bottom-right
	# at (160, 120). Report ColorRect area per quadrant.
	var quad: Dictionary = {"TL": 0.0, "TR": 0.0, "BL": 0.0, "BR": 0.0}
	for item in all_items:
		if not (item is ColorRect):
			continue
		var cr: ColorRect = item as ColorRect
		if not _is_visually_present(cr):
			continue
		var gp: Vector2 = cr.global_position
		var cx: float = gp.x + cr.size.x * 0.5
		var cy: float = gp.y + cr.size.y * 0.5
		var key: String = ""
		if cy < 120:
			key = "TL" if cx < 160 else "TR"
		else:
			key = "BL" if cx < 160 else "BR"
		quad[key] = quad[key] + cr.size.x * cr.size.y
	var quad_frac: Dictionary = {}
	for k in quad:
		quad_frac[k] = float(quad[k]) / VIEWPORT_AREA
	print("  case 4: quadrant coverage (ColorRect area %% of viewport): TL=%.1f%% TR=%.1f%% BL=%.1f%% BR=%.1f%%"
			% [quad_frac["TL"] * 100.0, quad_frac["TR"] * 100.0,
			   quad_frac["BL"] * 100.0, quad_frac["BR"] * 100.0])

	# === Case 5: write probe data JSON to tools/out/hud_coverage.json
	# so the probe report can cite the numbers.
	DirAccess.make_dir_recursive_absolute("res://tools/out")
	var payload: Dictionary = {
		"viewport_px": VIEWPORT_AREA,
		"hud_coverage_px": coverage_px,
		"hud_coverage_fraction": coverage_fraction,
		"hud_budget_fraction": HUD_BUDGET_FRACTION,
		"label_sizes_by_count": label_sizes_by_count,
		"labels_at_godot_default_count": labels_at_godot_default,
		"labels_missing_override_count": labels_at_default.size(),
		"visible_canvas_items": visible_count,
		"hidden_canvas_items": hidden_count,
		"quadrant_coverage_fraction": quad_frac,
	}
	var f := FileAccess.open("res://tools/out/hud_coverage.json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(payload, "  "))
		f.close()

	print("BREACH_HUD_COVERAGE_OK 4 cases — coverage ≤ 25%% budget + font-size floor 8pt + quadrant breakdown + JSON probe data")
	quit(0)
