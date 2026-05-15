class_name Constants

# direction constants
enum Dir {
	L, D, U, R
}

static func dir_to_rotation(dir: int) -> float:
	if dir == Dir.U:
		return 1.5 * PI
	if dir == Dir.D:
		return 0.5 * PI
	if dir == Dir.L:
		return PI
	return 0.0
