extends StaticBody2D

@export var max_hp: int = 1
# arc-4 iter 139 (PLAYTEST-FIX-2 from user): bricks have a separate
# beam_hp pool so the PRISM beam takes 3 cooldown ticks to break a
# brick (visible drain, not 1-tick instant melt). Bullets unchanged
# (still 1-shot via take_damage on the bullet `hp` field).
@export var beam_hp_max: int = 3

# arc-4 iter 313 (Round 26 Phase A — visual identity sprint per
# post_halt_direction Option A): per-instance brick texture override
# for band-themed variants. Default null → sprite stays on
# sprites_1.png frame 5 (the arc-2/3 baseline; hash anchor
# 23d6a2ec3bf2821f preserved bit-identical). When set, the Sprite2D
# texture swaps to the override + frame indexing collapses to the
# standalone 8×8 single-tile shape.
#
# Activation: future iter (Round 26 Phase B) wires Level.gd or
# ProceduralLevel.gd to read active band's variant_texture and pass it
# to each instantiated BrickBlock. iter 313 ships only the override
# CAPABILITY on BrickBlock.gd — the field exists, defaults preserve
# bit-identicality, and the harness verifies both codepaths.
@export var variant_texture: Texture2D = null

@onready var sprite: Sprite2D = $Sprite2D

var hp: int = max_hp
var beam_hp: int = 3


func _ready() -> void:
	hp = max_hp
	beam_hp = beam_hp_max
	# arc-4 iter 313: if a variant texture is wired in, swap the
	# Sprite2D's texture + collapse the atlas indexing to single-frame.
	# Default null → no-op → bit-identical to arc-2/3 baseline.
	if variant_texture != null:
		sprite.texture = variant_texture
		sprite.hframes = 1
		sprite.vframes = 1
		sprite.frame = 0


func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()


# arc-4 iter 139 (PLAYTEST-FIX-2): beam-pool damage path. Bricks
# break when beam_hp drains to 0 (3 cooldown ticks at default).
func take_beam_damage(amount: int) -> void:
	if amount <= 0:
		return
	beam_hp = max(0, beam_hp - amount)
	if beam_hp <= 0:
		queue_free()
