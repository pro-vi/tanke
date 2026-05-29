extends SceneTree

# U3 verifier (AC-001) — BotInputDriver.apply_action() synthesizes the right
# held-key state via Input.parse_input_event. Tested in isolation (no scene /
# PlayerTank needed): we drive apply_action() and poll the Input singleton the
# same way PlayerTank does (is_action_pressed for ui_*, is_physical_key_pressed
# for TAB). Teeth: a driver that fails to RELEASE keys on direction change or
# stop leaves stuck inputs — cases 2 and 3 below catch exactly that.
#
# Emits `BOT_DRIVER_OK` on full pass; quit(1) on any failure.

const Dir := Constants.Dir

func _initialize() -> void:
	var failures: int = 0
	var d := BotInputDriver.new()

	# clear any ambient state
	d.apply_action(BotAction.new(BotAction.NONE, false, BotAction.NO_SWAP))
	await _settle()

	# --- case 1: move UP + fire ---
	d.apply_action(BotAction.new(Dir.U, true, BotAction.NO_SWAP))
	await _settle()
	if not Input.is_action_pressed("ui_up"):
		print("  FAIL — case1: ui_up not pressed after move_dir=U"); failures += 1
	if not Input.is_action_pressed("ui_accept"):
		print("  FAIL — case1: ui_accept not pressed after fire=true"); failures += 1
	if failures == 0:
		print("  case move-up+fire OK")

	# --- case 2: change dir U -> L (TEETH: ui_up MUST release) ---
	d.apply_action(BotAction.new(Dir.L, true, BotAction.NO_SWAP))
	await _settle()
	if Input.is_action_pressed("ui_up"):
		print("  FAIL — case2 TEETH: ui_up still held after dir change to L (stuck key)"); failures += 1
	if not Input.is_action_pressed("ui_left"):
		print("  FAIL — case2: ui_left not pressed"); failures += 1
	if not Input.is_action_pressed("ui_accept"):
		print("  FAIL — case2: ui_accept dropped unexpectedly"); failures += 1
	if Input.is_action_pressed("ui_up") == false and Input.is_action_pressed("ui_left"):
		print("  case dir-change-releases-old OK")

	# --- case 3: idle (TEETH: everything MUST release) ---
	d.apply_action(BotAction.new(BotAction.NONE, false, BotAction.NO_SWAP))
	await _settle()
	var stuck := []
	for a in ["ui_up", "ui_down", "ui_left", "ui_right", "ui_accept"]:
		if Input.is_action_pressed(a):
			stuck.append(a)
	if stuck.size() > 0:
		print("  FAIL — case3 TEETH: keys still held after idle: %s" % str(stuck)); failures += 1
	else:
		print("  case idle-releases-all OK")

	# --- case 4: shell-swap pulses physical TAB (rising edge) ---
	d.apply_action(BotAction.new(BotAction.NONE, false, 2))  # request HEAT
	await _settle()
	if not Input.is_physical_key_pressed(KEY_TAB):
		print("  FAIL — case4: physical TAB not pressed on shell_swap request"); failures += 1
	else:
		print("  case shell-swap-taps-TAB OK")
	# release pulse + cleanup
	d.apply_action(BotAction.new(BotAction.NONE, false, BotAction.NO_SWAP))
	await _settle()
	d.release_all()
	await _settle()

	if failures == 0:
		print("BOT_DRIVER_OK")
		quit(0)
	else:
		print("BOT_DRIVER_FAIL %d failures" % failures)
		quit(1)


# parse_input_event state flushes a frame or two later (arc-3 L5 cadence).
func _settle() -> void:
	await process_frame
	await process_frame
