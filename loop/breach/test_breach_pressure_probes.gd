# Arc-4 breach mode: Round-10 Phase-2 pressure-probe harness
# (iter 77). Empirically validates the PRESSURES.md matrix's most
# uncertain claim — the armor-bypass asymmetry per archetype.
#
# Background: armor logic lives ONLY in Bullet.gd's _on_body_entered
# (AP/HE blocked vs armored bodies; HEAT/APCR bypass). PRISM beam,
# MORTAR shell, and RAM swing/collision all call take_damage(N)
# UNCONDITIONALLY — so armor is bypassed by mechanism. This probe
# confirms the matrix's claim empirically and surfaces the
# asymmetry (DEFAULT respects armor through shell-economy; the
# other three archetypes have armor-bypass baked into their verb).
#
# Run with:
#   godot --headless --path . --script res://loop/breach/test_breach_pressure_probes.gd

extends SceneTree

const BulletScene = preload("res://scenes/Bullet.tscn")
const BulletT = preload("res://scripts/Bullet.gd")
const PlayerTankScene = preload("res://scenes/PlayerTank.tscn")
const PlayerTankT = preload("res://scripts/PlayerTank.gd")
const LoadoutT = preload("res://scripts/Loadout.gd")
const MortarShellScene = preload("res://scenes/MortarShell.tscn")


# Minimal stub that mimics an armored Heavy enemy's damage interface.
# Implements take_damage + can be in the "armored" group.
class _ArmoredStub extends Node2D:
	var hp: int = 99
	var damage_received: int = 0
	var damage_call_count: int = 0
	func take_damage(amount: int) -> void:
		hp -= amount
		damage_received += amount
		damage_call_count += 1


func _make_stub(parent: Node, armored: bool, pos: Vector2 = Vector2.ZERO) -> Node:
	var stub: Node = _ArmoredStub.new()
	stub.position = pos
	parent.add_child(stub)
	if armored:
		stub.add_to_group("armored")
	return stub


func _initialize() -> void:
	var holder := Node2D.new()
	root.add_child(holder)

	# === Probe 1: DEFAULT + AP shell vs armored Heavy → BLOCKED.
	var stub_ap: Node = _make_stub(holder, true)
	var bullet_ap: Node = BulletScene.instantiate()
	bullet_ap.shell_class = BulletT.SHELL_CLASS_AP
	bullet_ap.damage = 1
	holder.add_child(bullet_ap)
	await process_frame
	bullet_ap._on_body_entered(stub_ap)
	if stub_ap.damage_received != 0:
		push_error("FAIL — DEFAULT+AP vs armored: damage_received %d, want 0 (AP blocked by armor)" % stub_ap.damage_received)
		quit(1); return
	print("  DEFAULT+AP vs armored Heavy: %d damage — BLOCKED (matrix confirmed)" % stub_ap.damage_received)

	# === Probe 2: DEFAULT + HEAT shell vs armored Heavy → 2 damage.
	var stub_heat: Node = _make_stub(holder, true)
	var bullet_heat: Node = BulletScene.instantiate()
	bullet_heat.shell_class = BulletT.SHELL_CLASS_HEAT
	bullet_heat.damage = 1
	holder.add_child(bullet_heat)
	await process_frame
	bullet_heat._on_body_entered(stub_heat)
	if stub_heat.damage_received != 2:
		push_error("FAIL — DEFAULT+HEAT vs armored: damage_received %d, want 2 (HEAT bypass + 2x mult)" % stub_heat.damage_received)
		quit(1); return
	print("  DEFAULT+HEAT vs armored Heavy: %d damage — BYPASS (matrix confirmed)" % stub_heat.damage_received)

	# === Probe 3: PRISM beam vs armored Heavy → bypass armor (BYPASS).
	# arc-4 iter 138 (PLAYTEST-FIX): beam now uses BEAM_DAMAGE_PER_TICK
	# accumulator (0.25 per tick × 4 = 1 damage). 4 cooldown-spaced
	# ticks land 1 damage on the armored stub — same BYPASS verdict
	# (no armor check in the beam-damage path).
	var pt_prism: Node = PlayerTankScene.instantiate()
	pt_prism.loadout = LoadoutT.new()
	pt_prism.archetype = PlayerTankT.TankArchetype.PRISM
	holder.add_child(pt_prism)
	await process_frame
	await process_frame
	var stub_prism: Node = _make_stub(holder, true)
	pt_prism._beam_dmg_timer = 0.0
	for i in 4:
		pt_prism._apply_beam_to_body(pt_prism.BEAM_DAMAGE_COOLDOWN + 0.01, stub_prism)
	if stub_prism.damage_received == 0:
		push_error("FAIL — PRISM beam vs armored: damage_received 0, want >=1 (beam should bypass armor by mechanism)")
		quit(1); return
	print("  PRISM beam vs armored Heavy: %d damage after 4 ticks — BYPASS (no armor check in beam path; accumulator iter-138)" % stub_prism.damage_received)

	# === Probe 4: MORTAR shell vs armored Heavy → AOE_DAMAGE (BYPASS).
	# MortarShell._explode iterates siblings, calls take_damage(AOE_DAMAGE).
	var stub_mortar: Node = _make_stub(holder, true, Vector2.ZERO)
	var shell: Node = MortarShellScene.instantiate()
	shell.position = Vector2.ZERO  # sibling to stub_mortar via holder
	holder.add_child(shell)
	await process_frame
	shell._explode()
	if stub_mortar.damage_received == 0:
		push_error("FAIL — MORTAR explode vs armored: damage_received 0, want >=1 (AoE should bypass armor by mechanism)")
		quit(1); return
	print("  MORTAR AoE vs armored Heavy: %d damage — BYPASS (matrix confirmed: no armor check in _explode)" % stub_mortar.damage_received)

	# === Probe 5: RAM swing vs armored Heavy → RAM_SWING_DAMAGE (BYPASS).
	# _ram_swing iterates bodies within RAM_SWING_RANGE and calls take_damage.
	var pt_ram: Node = PlayerTankScene.instantiate()
	pt_ram.loadout = LoadoutT.new()
	pt_ram.archetype = PlayerTankT.TankArchetype.RAM
	holder.add_child(pt_ram)
	await process_frame
	await process_frame
	# Stub for RAM: armored, inside swing range, sibling of PlayerTank.
	# RAM swing uses _ram_swing which iterates Node2D siblings — needs the
	# stub to share parent with pt_ram (so a sibling of pt_ram = child of
	# holder). Place stub well within RAM_SWING_RANGE (18) of pt_ram.
	pt_ram.position = Vector2.ZERO
	pt_ram.direction = 0  # UP
	var stub_ram: Node = _make_stub(holder, true, Vector2(0, -10))
	pt_ram._ram_swing()
	if stub_ram.damage_received == 0:
		push_error("FAIL — RAM swing vs armored: damage_received 0, want >=2 (swing should bypass armor by mechanism)")
		quit(1); return
	print("  RAM swing vs armored Heavy: %d damage — BYPASS (matrix confirmed: no armor check in _ram_swing)" % stub_ram.damage_received)

	# === Asymmetry assertion: DEFAULT respects armor through SHELL CLASS;
	# PRISM/MORTAR/RAM bypass armor entirely. This is the empirical
	# confirmation of the PRESSURES.md "Armor bypass gaps" section —
	# each archetype "buys passage" through Heavy armor differently.
	# DEFAULT pays in shell economy (must pick HEAT/APCR); the other
	# three pay in time (PRISM beam DPS), exposure (MORTAR positioning),
	# or HP (RAM close-fire trade).
	print("BREACH_PRESSURE_PROBES_OK 5 probes — armor-bypass asymmetry confirmed: DEFAULT respects armor via shell class; PRISM/MORTAR/RAM bypass by mechanism (each archetype 'buys passage' differently — the iter-73 spine restated)")
	quit(0)
