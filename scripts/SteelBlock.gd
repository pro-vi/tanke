extends StaticBody2D

# Arc-4 breach mode: a destroyable steel wall. Level._replace_blocks
# converts brick + water TileMapLayer cells into nodes but leaves steel
# as an inert TileMapLayer; ProceduralLevel's breach-mode override
# converts steel cells into these nodes. Steel is indestructible to
# AP / HE / HEAT — only APCR's Bullet._apply_apcr_breach calls breach().
# The "steel" group lets Bullet identify it without a hard type
# dependency. Deliberately has NO take_damage method: AP/HE/HEAT route
# through Bullet's take_damage branch, which steel does not answer, so
# they cannot break it. That asymmetry IS the steel-vs-APCR economy.


func _ready() -> void:
	add_to_group("steel")


# Open this steel block. Called only by Bullet._apply_apcr_breach when
# an APCR shell connects (directly or within its breach radius).
func breach() -> void:
	queue_free()
