extends Area2D

# arc-4 iter 58 (Round 8c): enemy ammo drop. Spawned by Spawner.gd at a
# killed enemy's position (playtest-3 — "does enemy drop ammo?"). On the
# player driving over it, +AMOUNT of one shell class is added to the
# loadout reserve. Despawns after LIFETIME. A new arc-4 entity — no
# substrate. Mirrors the arc-2 inline-pickup pattern (cf. Enemy.gd
# _spawn_hp_pickup): collision_mask 2 = player layer, body_entered
# collects, an 8s despawn timer.

const BulletT = preload("res://scripts/Bullet.gd")
const AMOUNT: int = 1
const LIFETIME: float = 8.0
# The droppable shells — AP is unlimited, so it is never dropped.
const DROP_SHELLS: Array[int] = [
	BulletT.SHELL_CLASS_HE, BulletT.SHELL_CLASS_HEAT, BulletT.SHELL_CLASS_APCR,
]

var shell_class: int = BulletT.SHELL_CLASS_HE
var _collected: bool = false


func _ready() -> void:
	# Pick a random droppable shell; tint the chip to match the in-flight
	# Bullet modulate so the pickup reads as "that shell".
	shell_class = DROP_SHELLS[randi() % DROP_SHELLS.size()]
	var chip: ColorRect = get_node_or_null("Chip") as ColorRect
	if chip != null:
		chip.color = _shell_color(shell_class)
	body_entered.connect(_on_body_entered)
	var timer: Timer = Timer.new()
	timer.wait_time = LIFETIME
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(queue_free)
	add_child(timer)


# The player drives over the pickup: refill the dropped shell's reserve.
# Defensive — a body with no Loadout (arc-2/3 player) is a no-op.
# arc-4 iter 103 (P2-A fix from code-review-iter-100): if the chosen
# shell_class is already at cap and another droppable shell isn't,
# re-roll to that shell — preserves pickup value. A silent no-op pickup
# violates CONSULT constraint 3 (every shell event must have a readable
# meaning to the player's state). If ALL three are at cap, accept the
# no-op honestly: the player is genuinely topped.
func _on_body_entered(body: Node) -> void:
	if _collected:
		return
	if not ("loadout" in body) or body.loadout == null:
		return
	_collected = true
	var lo = body.loadout
	if _is_at_cap(lo, shell_class):
		var alt: int = _pick_under_cap(lo)
		if alt != -1:
			shell_class = alt
	var nm: String = "HE"
	if shell_class == BulletT.SHELL_CLASS_HE:
		lo.refill_he(AMOUNT)
		nm = "HE"
	elif shell_class == BulletT.SHELL_CLASS_HEAT:
		lo.refill_heat(AMOUNT)
		nm = "HEAT"
	elif shell_class == BulletT.SHELL_CLASS_APCR:
		lo.refill_apcr(AMOUNT)
		nm = "APCR"
	if body.has_method("_show_pickup_toast"):
		body._show_pickup_toast("%s +%d" % [nm, AMOUNT], _shell_color(shell_class))
	queue_free()


# Whether the loadout's reserve for `sc` is at its cap.
func _is_at_cap(lo, sc: int) -> bool:
	if sc == BulletT.SHELL_CLASS_HE:
		return lo.he_reserve >= lo.max_he_reserve
	if sc == BulletT.SHELL_CLASS_HEAT:
		return lo.heat_reserve >= lo.max_heat_reserve
	if sc == BulletT.SHELL_CLASS_APCR:
		return lo.apcr_reserve >= lo.max_apcr_reserve
	return false


# Random under-cap droppable shell, or -1 if all 3 are at cap.
func _pick_under_cap(lo) -> int:
	var candidates: Array[int] = []
	for sc in DROP_SHELLS:
		if not _is_at_cap(lo, sc):
			candidates.append(sc)
	if candidates.is_empty():
		return -1
	return candidates[randi() % candidates.size()]


# Per-shell colour — matches PlayerTank._shell_color / the Bullet modulate.
func _shell_color(sc: int) -> Color:
	if sc == BulletT.SHELL_CLASS_HE:
		return Color(1.0, 0.85, 0.25, 1.0)
	if sc == BulletT.SHELL_CLASS_HEAT:
		return Color(1.0, 0.35, 0.25, 1.0)
	if sc == BulletT.SHELL_CLASS_APCR:
		return Color(0.6, 0.85, 1.0, 1.0)
	return Color(0.92, 0.92, 0.95, 1.0)
