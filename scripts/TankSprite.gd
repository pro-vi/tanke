extends Sprite2D

# Sprite API

var dir_set: Array = [0, 1]
var animation_frame: int = 0  # switch between 0 and 1 for track animation
var playing: bool = true
var colliding: bool = false
# arc-4 iter 146: per-archetype atlas offset. Default 0 = bit-identical
# to the arc-1/2/3 single-atlas mode (sprites_0.png row 0). PlayerTank
# sets this to 16/32 when a non-DEFAULT archetype is active and the
# texture is swapped to img/archetype_sprites.png (rows 0/1/2 = PRISM/
# MORTAR/RAM). Default-on gating template: at frame_base=0 the per-frame
# selector reduces to the prior expression dir_set[animation_frame].
var frame_base: int = 0


# Get sprite direction set (columns) from input vector
func set_dir_set(vec: Vector2) -> void:
	if vec.x == 0:
		if vec.y == -1:
			dir_set = [0, 1]
		if vec.y == 1:
			dir_set = [4, 5]
	if vec.y == 0:
		if vec.x == -1:
			dir_set = [2, 3]
		if vec.x == 1:
			dir_set = [6, 7]


# Motion effect
func _process(_delta: float) -> void:
	if playing:
		if not colliding:
			animation_frame = 0 if animation_frame else 1
		set_frame(frame_base + dir_set[animation_frame])
	set_global_rotation(0)


func play() -> void:
	playing = true


func stop() -> void:
	playing = false
