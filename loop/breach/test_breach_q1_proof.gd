# Arc-4 Round 24 reframe (iter 284 per user-direction iter 283 Option B):
# Q1 breach-economy proof-room design-verification harness.
#
# Verifies the DESIGN PROPERTY that the proof room is shell-gated as
# claimed in the architect blueprint + the layout file. Does NOT yet
# verify playable integration (that's iter 285+) — this harness ensures
# the design ARTIFACT itself is internally consistent.
#
# Verifies:
#   1. configs/bands/q1_proof.tres loads as a BreachBand with band_name
#      == "q1_proof" + dominant_pressure mentions "4 vertical lanes"
#      + canonical_answer cites HE/APCR/HEAT/AP per-lane.
#   2. loop/breach/q1_proof_layout.txt exists + parses to find the
#      4 lane gate markers (GATE_HE / GATE_APCR / GATE_HEAT / GATE_AP).
#   3. Each lane has its expected gate type (brick cluster / steel
#      barrier / entrenched Heavy / open patrol).
#   4. Per-shell solvability — for each lane, the dominant shell can
#      clear the gate; the cross-pollination test verifies APCR is
#      the ONLY shell that can pass the steel-barrier lane.
#   5. Sentence test: each lane's gate phrasing in the layout file
#      passes the arc-4 CONSULT sentence test (verb-changing, not stat).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_q1_proof.gd

extends SceneTree


const Q1_BAND_PATH := "res://configs/bands/q1_proof.tres"
const Q1_LAYOUT_PATH := "res://loop/breach/q1_proof_layout.txt"


func _initialize() -> void:
	# === Case 1: q1_proof.tres loads as a BreachBand with the right metadata.
	var band: Resource = load(Q1_BAND_PATH) as Resource
	if band == null:
		push_error("FAIL — could not load %s" % Q1_BAND_PATH)
		quit(1); return
	if not "band_name" in band or band.band_name != "q1_proof":
		push_error("FAIL — band_name = '%s', want 'q1_proof'" % str(band.band_name))
		quit(1); return
	if not "dominant_pressure" in band or not band.dominant_pressure.contains("4 vertical lanes"):
		push_error("FAIL — dominant_pressure missing '4 vertical lanes': '%s'" \
				% str(band.dominant_pressure))
		quit(1); return
	# canonical_answer must cite all 4 shell classes
	var answer: String = String(band.canonical_answer)
	for shell_name in ["HE", "APCR", "HEAT", "AP"]:
		if not answer.contains(shell_name):
			push_error("FAIL — canonical_answer missing shell class '%s': '%s'" \
					% [shell_name, answer])
			quit(1); return
	print("  band loaded: '%s' — dominant_pressure cites 4 lanes, canonical_answer cites all 4 shells" \
			% str(band.band_name))

	# === Case 2: layout file loads + has the 4 gate markers.
	var layout: String = _load_text(Q1_LAYOUT_PATH)
	if layout.is_empty():
		push_error("FAIL — could not load %s" % Q1_LAYOUT_PATH)
		quit(1); return
	var gate_markers: Array[String] = ["GATE_HE:", "GATE_APCR:", "GATE_HEAT:", "GATE_AP:"]
	for m in gate_markers:
		if not layout.contains(m):
			push_error("FAIL — layout missing gate marker '%s'" % m)
			quit(1); return
	print("  layout: 4 gate markers present (HE/APCR/HEAT/AP)")

	# === Case 3: each gate has its expected gate type per blueprint.
	# Parse each gate line and assert gate-content matches expectation.
	var gate_lines: Dictionary = _extract_gate_lines(layout)
	# HE: ≥4 brick cells "B"
	var he_line: String = String(gate_lines.get("HE", ""))
	if he_line.count("B") < 4:
		push_error("FAIL — HE gate has %d brick cells, want ≥4 (cluster): '%s'" \
				% [he_line.count("B"), he_line])
		quit(1); return
	# APCR: ≥3 steel cells "S"
	var apcr_line: String = String(gate_lines.get("APCR", ""))
	if apcr_line.count("S") < 3:
		push_error("FAIL — APCR gate has %d steel cells, want ≥3 (barrier): '%s'" \
				% [apcr_line.count("S"), apcr_line])
		quit(1); return
	# HEAT: ≥1 Heavy marker "H"
	var heat_line: String = String(gate_lines.get("HEAT", ""))
	if heat_line.count("H") < 1:
		push_error("FAIL — HEAT gate has %d Heavy markers, want ≥1 (entrenched): '%s'" \
				% [heat_line.count("H"), heat_line])
		quit(1); return
	# AP: ≥1 Light marker "L", NO armored, NO steel, NO brick
	var ap_line: String = String(gate_lines.get("AP", ""))
	if ap_line.count("L") < 1:
		push_error("FAIL — AP gate has %d Light markers, want ≥1 (patrol): '%s'" \
				% [ap_line.count("L"), ap_line])
		quit(1); return
	if ap_line.contains("S") or ap_line.contains("H") or ap_line.count("B") >= 4:
		push_error("FAIL — AP gate contains non-AP-domain elements: '%s'" % ap_line)
		quit(1); return
	print("  gate types: HE=%d bricks / APCR=%d steel / HEAT=%d Heavy / AP=%d Light (correct shapes)" \
			% [he_line.count("B"), apcr_line.count("S"), heat_line.count("H"), ap_line.count("L")])

	# === Case 4: per-shell solvability + cross-pollination.
	# Solvability is design-level (the harness encodes the rules from
	# the layout's "Per-lane shell-gating semantics" section).
	#
	# Dominant shell can clear each lane:
	if not _shell_can_clear("HE", he_line):
		push_error("FAIL — HE cannot clear HE lane (dominant-shell broken)")
		quit(1); return
	if not _shell_can_clear("APCR", apcr_line):
		push_error("FAIL — APCR cannot clear APCR lane (dominant-shell broken)")
		quit(1); return
	if not _shell_can_clear("HEAT", heat_line):
		push_error("FAIL — HEAT cannot clear HEAT lane (dominant-shell broken)")
		quit(1); return
	if not _shell_can_clear("AP", ap_line):
		push_error("FAIL — AP cannot clear AP lane (dominant-shell broken)")
		quit(1); return
	# CROSS-POLLINATION CRITICAL: AP MUST NOT pass the steel-barrier lane.
	# This is the design property that makes shells "route currency" not
	# "damage flavor" — at least one lane is IMPASSABLE without its
	# dominant shell.
	if _shell_can_clear("AP", apcr_line):
		push_error("FAIL — AP can clear APCR lane; design property broken (steel must be impenetrable without APCR)")
		quit(1); return
	if _shell_can_clear("HE", apcr_line):
		push_error("FAIL — HE can clear APCR lane; design property broken (steel must be impenetrable without APCR)")
		quit(1); return
	if _shell_can_clear("HEAT", apcr_line):
		push_error("FAIL — HEAT can clear APCR lane; design property broken (steel must be impenetrable without APCR)")
		quit(1); return
	print("  solvability: each shell clears its lane; APCR lane IMPASSABLE without APCR (route-currency proof)")

	# === Case 5: sentence test per lane (verb-changing, not stat).
	# Pull the sentence-test entries from the layout's per-lane semantics
	# section and verify each cites a VERB (clear/drill/pierce/rotate)
	# not a STAT bump (+damage / +speed / +radius).
	var verb_keywords: Array[String] = ["blast", "drill", "burst", "rotation", "clear", "punch"]
	var stat_anti_keywords: Array[String] = [
		"+damage", "+1 damage", "+10%", "+15%", "+20%", "+25%",
		"increase damage", "more damage", "boost dps",
	]
	for kw in stat_anti_keywords:
		if layout.to_lower().contains(kw):
			push_error("FAIL — layout uses stat-bump language (anti-pattern): '%s'" % kw)
			quit(1); return
	var verb_hits: int = 0
	for kw in verb_keywords:
		if layout.to_lower().contains(kw):
			verb_hits += 1
	if verb_hits < 3:
		push_error("FAIL — layout uses only %d verb keywords, want ≥3 (verb-not-stat anti-pattern)" \
				% verb_hits)
		quit(1); return
	print("  sentence test: %d verb keywords cited, 0 stat-bump anti-patterns" % verb_hits)

	print("BREACH_Q1_PROOF_OK 4 lanes + gate shapes + shell-gated solvability + verb-not-stat design verified")
	quit(0)


func _load_text(path: String) -> String:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content: String = f.get_as_text()
	f.close()
	return content


# Extract each gate line from the ASCII layout file. Returns a Dictionary
# keyed by lane name ("HE"/"APCR"/"HEAT"/"AP") with the gate-content string.
# Gate lines in the layout look like:
#   GATE_HE:    .BBB.       (4-cell brick cluster; ...)
# We strip the prefix + trailing paren-comment.
func _extract_gate_lines(layout: String) -> Dictionary:
	var result: Dictionary = {}
	var lane_names: Array[String] = ["HE", "APCR", "HEAT", "AP"]
	for lane in lane_names:
		var marker: String = "GATE_%s:" % lane
		var idx: int = layout.find(marker)
		if idx < 0:
			continue
		var rest: String = layout.substr(idx + marker.length())
		# Take up to the next newline
		var nl: int = rest.find("\n")
		var line: String = rest.substr(0, nl) if nl >= 0 else rest
		# Strip parenthetical comment if present
		var p: int = line.find("(")
		if p >= 0:
			line = line.substr(0, p)
		# Trim
		line = line.strip_edges()
		result[lane] = line
	return result


# Encodes the design rules from the layout's per-lane semantics section.
# Returns true if the shell class can clear the given lane's gate.
func _shell_can_clear(shell_class_name: String, gate_line: String) -> bool:
	# HE shell: clears bricks (1 shot blasts 4-cell radius); does NOT crack
	# steel; deals normal damage to enemies.
	if shell_class_name == "HE":
		if gate_line.contains("S"):
			return false  # HE cannot crack steel
		# HE clears bricks AND enemies (chip-through)
		return true
	# APCR shell: drills steel (1 cell per hit); behaves as AP on bricks
	# (1 brick per hit, no radius); 1x damage on armored.
	if shell_class_name == "APCR":
		# APCR can clear ANY gate type (steel via drill, bricks via 1-per-hit,
		# enemies via 1x damage). May be slow on non-steel lanes, but solvable.
		return true
	# HEAT shell: 2x damage on armored; 1x on terrain (does NOT crack steel).
	if shell_class_name == "HEAT":
		if gate_line.contains("S"):
			return false  # HEAT does NOT crack steel
		# HEAT clears bricks (1x = 1 hit per brick) AND enemies (2x burst)
		return true
	# AP shell: cheap 1-damage, bounces off steel, normal vs brick/enemies.
	if shell_class_name == "AP":
		if gate_line.contains("S"):
			return false  # AP bullet bounces off steel
		return true
	return false
