extends Area2D

# Arc-4 breach mode: 4 primary shell classes. AP = cheap precise;
# HE = brick-zone breacher; HEAT = anti-armor burst (2×); APCR = the
# steel-terrain breacher (also pierces armor at 1×). APCR is the
# sanctioned 4th shell — the user overrode CONSULT §9 constraint 2 in
# the iter-33 playtest (see loop/breach/STATE.md §Arc-4 amendments).
# Default = AP for arc-2 baseline bit-identicality (hash anchor
# 23d6a2ec3bf2821f… on seed 42 procedural fires AP bullets only via
# the arc-2 codepath; Spawner-fired enemy bullets stay AP too).
const SHELL_CLASS_AP: int = 0
const SHELL_CLASS_HE: int = 1
const SHELL_CLASS_HEAT: int = 2
const SHELL_CLASS_APCR: int = 3

@export var speed: int = 120
@export var damage: int = 1
@export var lifetime: float = 2.0
# Arc-4 default-on gating (PATTERN 2 / L5). Default = AP preserves arc-2
# baseline; HE / HEAT behaviors land in iter 5+ (terrain-cracking,
# anti-armor). When at default, `start()` runs an arc-2-identical path.
@export var shell_class: int = SHELL_CLASS_AP

# arc-4 iter 277 (Round 24 Phase A widget 5): canonical per-shell color
# used by HUD chips (iter 276), in-flight bullet modulate (iter 35), and
# kill-flash (iter 277). Single source of truth for shell visual identity.
static func shell_modulate_color(sc: int) -> Color:
	if sc == SHELL_CLASS_HE:
		return Color(1.0, 0.85, 0.25, 1.0)
	if sc == SHELL_CLASS_HEAT:
		return Color(1.0, 0.35, 0.25, 1.0)
	if sc == SHELL_CLASS_APCR:
		return Color(0.6, 0.85, 1.0, 1.0)
	return Color(0.92, 0.92, 0.95, 1.0)  # AP — pale steel


var velocity: Vector2 = Vector2.ZERO
var _steel_drilled: int = 0  # arc-4 iter 49: steel blocks this APCR shell has drilled
# arc-4 iter 109 (Round 12 Gap 2): kill-source attribution. Set by
# the spawner (Enemy._fire) to a short taxon string like "light
# bullet" / "heavy bullet" / "fast bullet". When the bullet damages
# a body with `set_last_damage_source`, that source string is
# propagated so RunRecap.killer can name a concrete cause instead
# of the "shell impact" placeholder. Empty string = no attribution
# (arc-2/3 baseline; PlayerTank-fired bullets default to "" since
# the player doesn't shoot itself).
var source_label: String = ""
# arc-4 iter 101 (P1-A fix from code-review-iter-100): once-per-shot
# Steel Salvage refund latch. Without this, _steel_drilled == THRESHOLD
# strict equality would skip the refund if 2 steel blocks were
# drilled in the same physics frame (e.g. Area2D scanning through
# adjacent tiles), incrementing 2→4 past THRESHOLD=3. Now uses
# `>= THRESHOLD and not _salvage_paid`.
var _salvage_paid: bool = false

@onready var _lifetime_timer: Timer = $LifeTimeTimer


func start(pos: Vector2, dir: int, target_mask: int = -1, shell: int = -1) -> void:
	position = pos
	rotation = Constants.dir_to_rotation(dir)
	velocity = Vector2(1, 0).rotated(rotation) * float(speed)
	if target_mask >= 0:
		collision_mask = target_mask
	if shell >= 0:
		shell_class = shell
	_lifetime_timer.wait_time = lifetime
	_lifetime_timer.start()
	# iter 53: high-damage bullets (Heavy =2) get a warm orange tint so player
	# can identify the threat mid-air. Makes iter-52 damage variation visible.
	if damage >= 2:
		var sprite: Sprite2D = $Sprite2D
		if sprite != null:
			sprite.modulate = Color(1.0, 0.5, 0.3, 1.0)
	# Arc-4 shell-class visual hint. AP = no mutation (preserves arc-2
	# look + the damage>=2 warm-orange code path above). HE = soft yellow,
	# HEAT = warm crimson, APCR = cold steel-blue. Modulate is a temporary
	# scaffold — iter 35 (Round 5) replaces it with distinct per-shell
	# sprites via gen_tile.py (constraint-4 silhouette-grammar gate).
	if shell_class != SHELL_CLASS_AP:
		var s: Sprite2D = $Sprite2D
		if s != null:
			if shell_class == SHELL_CLASS_HE:
				s.modulate = Color(1.0, 0.85, 0.25, 1.0)
			elif shell_class == SHELL_CLASS_HEAT:
				s.modulate = Color(1.0, 0.35, 0.25, 1.0)
			elif shell_class == SHELL_CLASS_APCR:
				s.modulate = Color(0.6, 0.85, 1.0, 1.0)  # cold steel-blue


func _physics_process(delta: float) -> void:
	position += velocity * delta


func _on_area_entered(_area: Area2D) -> void:
	_spawn_impact_spark()
	queue_free()


# arc-4 iter 23: armor mitigation. Bodies in the "armored" group (set
# by Spawner.gd for Heavy enemies) take ARMOR_MITIGATION less damage
# from AP + HE — HEAT bypasses armor entirely. With base damage 1,
# AP/HE deal 0 to armored Heavies (blocked); HEAT one-shots them. The
# player learns: "HE changes the map; HEAT solves armor" (CONSULT 002).
const ARMOR_MITIGATION: int = 1


func _on_body_entered(body: Node) -> void:
	# Arc-4 shell-class routing.
	# AP (default) = single-hit, baseline damage — arc-2 path, bit-identical
	#   when shell_class = SHELL_CLASS_AP (the procedural baseline never
	#   touches the HE/HEAT/APCR branches; hash anchor 23d6a2ec3bf2821f stays).
	# HE   = single-hit + radius brick-blast. Sentence-test compliant.
	# HEAT = 2x damage AND ignores armor — the anti-armor burst.
	# APCR = penetrates steel — drills through, breaking ONE steel block
	#   per block it passes (like AP breaks one brick), never stopping;
	#   also pierces armor at 1x.
	# arc-4 iter 49: APCR-vs-steel is handled FIRST + returns — the bullet
	# does NOT queue_free, so the drill continues to the next block.
	if shell_class == SHELL_CLASS_APCR and body.is_in_group("steel"):
		# arc-4 iter 101 (P1-A fix): only tick the drill counter if
		# the steel block actually breaches. Inert steel (no breach
		# method) doesn't count toward Steel Salvage.
		if body.has_method("breach"):
			body.breach()
			_steel_drilled += 1
			# arc-4 iter 289 (Q1 sprint 6/7): APCR drilling steel IS
			# the canonical "shells as route currency" verb. Record it
			# as a route hit when the body carries is_route_gate meta
			# (set by Q1ProofRoomScene at gate-row spawns). Without this,
			# the iter-286 wiring missed the APCR-steel path because the
			# steel branch returns early before the standard hit-record
			# call site. Method-existence-gated via _try_record_shot_hit.
			_try_record_shot_hit(body)
		# Steel Salvage (iter 41, retuned iter 49): drilling
		# >=STEEL_SALVAGE_THRESHOLD blocks with one shot refunds 1 APCR
		# — once per shot — if the player owns the upgrade.
		# arc-4 iter 101 (P1-A fix): use `>=` + `_salvage_paid` latch
		# so a frame-multi-block hit doesn't skip the refund (was `==`).
		if _steel_drilled >= STEEL_SALVAGE_THRESHOLD and not _salvage_paid:
			_salvage_paid = true
			_try_steel_salvage()
		_spawn_impact_spark()
		return  # penetrate — the drill flies on until its lifetime ends
	var deal: int = damage
	if shell_class == SHELL_CLASS_HEAT:
		deal = damage * 2
	# armor mitigation: AP/HE blunted vs armored bodies; HEAT + APCR pierce.
	if shell_class != SHELL_CLASS_HEAT and shell_class != SHELL_CLASS_APCR \
			and body.is_in_group("armored"):
		deal = max(0, deal - ARMOR_MITIGATION)
	if body.has_method("take_damage"):
		# arc-4 iter 109 (Round 12 Gap 2): propagate the source taxon
		# string so the body's recap can attribute the kill. The method
		# exists only on the arc-4 player; arc-2/3 bodies don't define
		# it, so this is a no-op on the baseline.
		if body.has_method("set_last_damage_source"):
			body.set_last_damage_source(source_label)
		# arc-4 iter 277 (Round 24 Phase A widget 5): propagate shell
		# class so Enemy.gd can tint its death burst by killing shell.
		# Method-existence gated so arc-2/3 bodies are unaffected.
		if body.has_method("set_last_damage_shell"):
			body.set_last_damage_shell(shell_class)
		body.take_damage(deal)
		# arc-4 iter 286 (Q1 sprint 3/4 per blueprint loop/breach/
		# iter-283-round24-Q1-architect.md; consult-001 Q3 verdict 0.92):
		# record the hit as route or combat for RunRecap's route-currency
		# metrics. Reads is_route_gate meta on the body (set by the level
		# scene when spawning gate-row terrain or entrenched-gate enemies).
		# Reaches the player via the iter-24 lvl.player pattern.
		_try_record_shot_hit(body)
	if shell_class == SHELL_CLASS_HE:
		var radius_hits: int = _apply_he_blast(body)
		# arc-4 iter 52 (Round 7e): the HE detonation visual — a blast
		# bloom sized to the _apply_he_blast radius (playtest finding 5).
		_spawn_he_explosion()
		# arc-4 iter 24 "Breach Dividend": an HE shot that breaches a
		# cluster of >=DIVIDEND_THRESHOLD bricks refunds 1 HE — IF the
		# player picked the Breach Dividend depot upgrade. radius_hits +
		# 1 (the primary) = total bodies the blast struck.
		if radius_hits + 1 >= DIVIDEND_THRESHOLD:
			_try_breach_dividend()
	_spawn_impact_spark()
	queue_free()


# arc-4 iter 24: reach the firing player's Loadout via the Level parent
# and, if Breach Dividend is owned, refund 1 HE (capped at max by
# refill_he). All reads are defensive duck-typed — any missing link
# silently no-ops.
const DIVIDEND_THRESHOLD: int = 4


func _try_breach_dividend() -> void:
	var lvl: Node = get_parent()
	if lvl == null or not ("player" in lvl):
		return
	var p = lvl.player
	if p == null or not ("loadout" in p) or p.loadout == null:
		return
	if p.loadout.breach_dividend:
		p.loadout.refill_he(1)


# arc-4 iter 286: classify the hit as route-gate or combat and forward
# to the firing player's record_shot_hit pass-through. Bodies set
# `is_route_gate` meta from the level scene at gate-row positions;
# defaults to combat when meta absent or falsy. All reads duck-typed —
# any missing link (no parent.player, no loadout, no run_recap, no
# record_shot_hit method) silently no-ops. Procedural / arc-2/3 mode
# never sees is_route_gate meta on any body → silent path.
func _try_record_shot_hit(body: Node) -> void:
	var lvl: Node = get_parent()
	if lvl == null or not ("player" in lvl):
		return
	var p = lvl.player
	if p == null or not p.has_method("record_shot_hit"):
		return
	var is_route: bool = false
	if body != null and body.has_meta("is_route_gate"):
		is_route = bool(body.get_meta("is_route_gate"))
	var kind: String = "route" if is_route else "combat"
	p.record_shot_hit(shell_class, kind)


# HE radius blast: iterate siblings of the hit body that respond to
# take_damage + are within HE_BLAST_RADIUS pixels. Bricks live as
# StaticBody2D siblings under a "Bricks" or similar parent (per
# Level.gd._replace_blocks). Cheap O(siblings) scan; arc-2 brick count
# caps around 350. We do NOT chain blasts (HE→HE→HE) — single radius
# only — to keep the affordance readable and bounded.
const HE_BLAST_RADIUS_PX: float = 18.0  # ~1.1 tile radius at grid_size=16


# Returns the count of sibling bodies the blast struck (used by the
# Breach Dividend threshold check).
#
# arc-4 PR-#4 P1 review fix — three converging bugs corrected:
#   (a) friendly fire: the firing player is a sibling of bricks/enemies
#       under the Level parent, so a point-blank HE breach used to
#       splash the player. Skip both the firing player ref AND any
#       node in the "player" group.
#   (b) armor bypass: the primary hit path applies ARMOR_MITIGATION to
#       AP/HE on armored bodies, but the splash path skipped it — so a
#       direct HE hit on a Heavy did 0 dmg while the splash from the
#       same shot did the full raw damage. That inverts the design rule
#       (HE = brick-zone, HEAT/APCR = armor). Apply the same mitigation
#       to splash.
#   (c) attribution miscredit: splash hits skipped set_last_damage_shell
#       /source propagation + _try_record_shot_hit, so death bursts from
#       radius kills used the wrong tint and the route-currency ledger
#       undercounted HE cluster breaches.
func _apply_he_blast(primary_body: Node) -> int:
	var parent: Node = primary_body.get_parent()
	if parent == null or not (primary_body is Node2D):
		return 0
	var origin: Vector2 = (primary_body as Node2D).global_position
	# (a) firing-player ref via the iter-24 lvl.player pattern; defensive
	# duck-type so harness parents without it still work.
	var firing_player: Node = null
	if "player" in parent:
		firing_player = parent.player
	var hits: int = 0
	for sibling in parent.get_children():
		if sibling == primary_body:
			continue
		# (a) skip firing player + any player-group member.
		if firing_player != null and sibling == firing_player:
			continue
		if sibling.is_in_group("player"):
			continue
		if not sibling.has_method("take_damage"):
			continue
		if not (sibling is Node2D):
			continue
		var d: float = (sibling as Node2D).global_position.distance_to(origin)
		if d <= HE_BLAST_RADIUS_PX:
			# (b) splash armor mitigation — HE is AP-class on armored.
			var splash_deal: int = damage
			if sibling.is_in_group("armored"):
				splash_deal = max(0, splash_deal - ARMOR_MITIGATION)
			# (c) propagate attribution before take_damage so the death
			# burst tint + recap source are correct on splash kills.
			# Method-existence-gated so arc-2/3 bodies stay unaffected.
			if sibling.has_method("set_last_damage_source"):
				sibling.set_last_damage_source(source_label)
			if sibling.has_method("set_last_damage_shell"):
				sibling.set_last_damage_shell(shell_class)
			sibling.take_damage(splash_deal)
			# NOTE: splash does NOT call _try_record_shot_hit — the
			# shells_spent_on_routes ledger tracks shells SPENT, and only
			# one shell was fired. The primary hit already recorded it
			# (via the caller). Counting each splash victim would
			# overcount the shell economy and break Probe 1 F1's
			# "1 shot = 1 route" routes-1/1/1/1 invariant.
			hits += 1
	return hits


# arc-4 iter 41 "Steel Salvage" (retuned iter 49 for the penetrate
# model): an APCR shot that DRILLS >=STEEL_SALVAGE_THRESHOLD steel
# blocks — one penetrating shot bored through a thick wall — refunds
# 1 APCR, only if the player owns the Steel Salvage depot upgrade.
const STEEL_SALVAGE_THRESHOLD: int = 3


# Reach the firing player's Loadout via the Level parent; if Steel
# Salvage is owned, refund 1 APCR (capped by refill_apcr). All reads
# are defensive duck-typed — any missing link silently no-ops.
func _try_steel_salvage() -> void:
	var lvl: Node = get_parent()
	if lvl == null or not ("player" in lvl):
		return
	var p = lvl.player
	if p == null or not ("loadout" in p) or p.loadout == null:
		return
	if p.loadout.steel_salvage:
		p.loadout.refill_apcr(1)


# arc-4 iter 52 (Round 7e, playtest finding 5 — "HE should have an
# explosion effect"): the HE detonation visual. HE already applies a
# radius blast mechanically (_apply_he_blast); this is its look — two
# ColorRect layers (a warm outer bloom sized to the full blast diameter
# + a bright core) that expand from small to full and fade over ~0.28s.
# The _spawn_impact_spark pattern, scaled up. Algorithmic, no MLX-SD.
func _spawn_he_explosion() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null or not is_instance_valid(parent_node):
		return
	var origin: Vector2 = global_position
	# outer bloom — warm orange, reaches the full blast diameter.
	_spawn_blast_layer(parent_node, origin, HE_BLAST_RADIUS_PX * 2.0,
		Color(1.0, 0.55, 0.15, 0.85), 0.28, 58, "HEBlastBloom")
	# bright core — pale yellow, smaller + briefer.
	_spawn_blast_layer(parent_node, origin, HE_BLAST_RADIUS_PX,
		Color(1.0, 0.95, 0.7, 0.95), 0.18, 59, "HEBlastCore")


# arc-4 iter 52: one expand-and-fade ColorRect layer of the HE blast.
# `full_size` is the px the square reaches at peak; it starts at ~1/3
# that, scales to full from its centre, and fades alpha to 0 over `dur`.
# `layer_name` is distinct per layer so the harness can count them (a
# shared name would be uniquified to a non-readable @-prefixed form).
func _spawn_blast_layer(parent_node: Node, origin: Vector2, full_size: float,
		col: Color, dur: float, z: int, layer_name: String) -> void:
	var rect: ColorRect = ColorRect.new()
	rect.name = layer_name
	rect.size = Vector2(full_size, full_size)
	rect.color = col
	rect.position = origin - Vector2(full_size, full_size) * 0.5
	rect.pivot_offset = Vector2(full_size, full_size) * 0.5
	rect.scale = Vector2(0.35, 0.35)
	rect.z_index = z
	parent_node.add_child(rect)
	var tween: Tween = rect.create_tween()
	tween.set_parallel(true)
	tween.tween_property(rect, "scale", Vector2.ONE, dur)
	tween.tween_property(rect, "modulate:a", 0.0, dur)
	tween.chain().tween_callback(rect.queue_free)


# iter 41: visual juice — small white ColorRect at impact position, scaled +
# faded out over 0.12s. Parented to bullet's parent so it outlives queue_free.
# z_index 60 keeps it above tiles/bullets but below HUD.
func _spawn_impact_spark() -> void:
	# iter 69 (F010 user iter-60 Q2 "noise artifact"): smaller, warmer,
	# briefer spark. 3×3 yellow instead of 4×4 white; 0.08s instead of 0.12s.
	# Aims for "muzzle flash" reading rather than "bright spam."
	var parent_node: Node = get_parent()
	if parent_node == null or not is_instance_valid(parent_node):
		return
	var spark: ColorRect = ColorRect.new()
	spark.size = Vector2(3, 3)
	spark.color = Color(1.0, 0.95, 0.3, 1.0)  # warm yellow
	spark.position = global_position - Vector2(1.5, 1.5)
	spark.pivot_offset = Vector2(1.5, 1.5)
	spark.z_index = 60
	parent_node.add_child(spark)
	var tween: Tween = spark.create_tween()
	tween.set_parallel(true)
	tween.tween_property(spark, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property(spark, "modulate:a", 0.0, 0.08)
	tween.chain().tween_callback(spark.queue_free)


func _on_lifetime_timeout() -> void:
	queue_free()
