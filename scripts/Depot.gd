extends Area2D

# Arc-4 breach mode: field depot. Combat-pause safe-gate between depth
# bands per CONSULT §9 constraint 1 ("no upgrade choices during active
# combat — all RPG choice happens at field depots / safe gates").
#
# Iter 5: schema-only. On body_entered → pause the scene tree (combat
# pauses); on body_exited → resume. The depot itself runs with
# process_mode = PROCESS_MODE_ALWAYS so it can fire body_exited while
# paused. Iter 6+: depot UI surface (≥3 upgrade choices, next-band
# preview) + dwell-time budget (RUBRIC C2 anti-pattern guard: depot dwell
# must stay <30s).

signal depot_entered(depot: Node)
signal depot_exited(depot: Node)

@export var depot_name: String = ""
@export var band_name_next: String = ""  # the band the player previews on entry


func _ready() -> void:
	# Depot must run while the scene tree is paused so body_exited can fire.
	process_mode = Node.PROCESS_MODE_ALWAYS
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	# Only the player should pause combat (enemy bullets / enemies passing
	# through the depot zone would otherwise lock the game mid-combat).
	# Convention: the player carries a `player` group tag — falls back to
	# class-name check via has_method("_on_PlayerTank_shoot") if no group.
	if not _is_player(body):
		return
	get_tree().paused = true
	depot_entered.emit(self)


func _on_body_exited(body: Node) -> void:
	if not _is_player(body):
		return
	get_tree().paused = false
	depot_exited.emit(self)


# Identify the player without hard-coding PlayerTank.gd reference (keeps
# Depot.gd substrate-touch-free; arc-2 PlayerTank stays Layer 2).
func _is_player(body: Node) -> bool:
	if body == null:
		return false
	if body.is_in_group("player"):
		return true
	# Fallback for arc-2/3 player which may not have the group set.
	if body.has_method("_on_PlayerTank_shoot"):
		return true
	return false
