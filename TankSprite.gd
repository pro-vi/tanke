extends Sprite

# Sprite API

var dir_set = [0, 1]
var moving = 0  # switch between 0 and 1 for track animation
var playing = true

# Get sprite direction set (columns) from input vector
func set_dir_set(vec):
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
func _process(delta):
	if playing:
		moving = 0 if moving else 1
		set_frame(dir_set[moving])
	
func play():
	playing = true

func stop():
	playing = false
