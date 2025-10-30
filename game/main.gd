extends Node

const SFX_IMPACT_FOLDER = "res://audio/impact/"
const IMPACT_SOUNDS: Array[AudioStream] = [
	preload(SFX_IMPACT_FOLDER + "impactWood_heavy_001.ogg"),
	preload(SFX_IMPACT_FOLDER + "impactWood_heavy_002.ogg"),
	preload(SFX_IMPACT_FOLDER + "impactWood_heavy_003.ogg"),
	preload(SFX_IMPACT_FOLDER + "impactWood_heavy_004.ogg")
]

var tween_on_start: Tween
func _on_start_pressed() -> void:
	%Door.play("open")
	%AudioStreamPlayers/OpeningDoor.play()
	%Game.visible = true
	
	if tween_on_start:
		tween_on_start.kill()
	tween_on_start = create_tween()
	# Door moving forward
	tween_on_start.tween_property(%Door, "scale", Vector2(48, 48), 2)
	tween_on_start.set_trans(Tween.TRANS_SINE)
	tween_on_start.set_ease(Tween.EASE_IN)
	
	# Menu fade
	tween_on_start.parallel().tween_property(%Menu, "modulate", Color(1, 1, 1, 0), 2)
	tween_on_start.set_trans(Tween.TRANS_QUAD)
	tween_on_start.set_ease(Tween.EASE_OUT)
	
	# Clean up
	tween_on_start.tween_callback(Callable(%Door, "visible").bind(false))
	tween_on_start.tween_callback(Callable(%Menu, "visible").bind(false))
	
	# 3. Closing door
	tween_on_start.tween_callback(Callable(%AudioStreamPlayers/ClosingDoor, "play"))
	
	# Key reveal
	tween_on_start.tween_property(%Key, "modulate", Color(1, 1, 1, 1), 1).set_delay(1)
	tween_on_start.set_ease(Tween.EASE_IN)
	
	# Monster reveal
	tween_on_start.tween_property(%Instruction1, "modulate", Color(1, 1, 1, 1), 1)
	tween_on_start.tween_callback(Callable(self, "step_monster"))
	tween_on_start.tween_property(%Instruction2, "modulate", Color(1, 1, 1, 1), 1).set_delay(2)
	
	# Finish
	tween_on_start .connect("finished", Callable(self, "_on_start_pressed_finished"))

var tween_monser: Tween
func step_monster():
	print("Hello")
	%Timer.start(5)
	%AudioStreamPlayers/Impact.stream = IMPACT_SOUNDS[randi() % IMPACT_SOUNDS.size()]
	if tween_monser:
		tween_monser.kill()
	tween_monser = create_tween()
	tween_monser.tween_callback(Callable(%AudioStreamPlayers/Inhale, "play"))
	
	%AudioStreamPlayers/Impact.stream = IMPACT_SOUNDS[randi() % IMPACT_SOUNDS.size()]
	tween_monser.parallel().tween_callback(Callable(%AudioStreamPlayers/Impact, "play")).set_delay(2)

func _on_start_pressed_finished():
	%Door.visible = false
	%Door.scale = Vector2(8, 8)
	%Menu.visible = false
	%Menu.modulate = Color(1, 1, 1, 1)


func _on_timer_timeout() -> void:
	step_monster()

var tween_step_forward: Tween
func _step_forward():
	steps_taken += 1
	print("Steps: %d" % steps_taken)
	
	if tween_step_forward:
		tween_step_forward.kill()
	tween_step_forward = create_tween()
	
	var new_scale: Vector2 = %Key.scale * 1.3
	
	tween_step_forward.tween_property(%Key, "scale", new_scale, 0.3)
	tween_step_forward.set_trans(Tween.TRANS_SINE)
	tween_step_forward.set_ease(Tween.EASE_OUT)
	
var tween_clean_instructions: Tween
func _clean_instructions():
	if tween_clean_instructions:
		tween_clean_instructions.kill()
	tween_clean_instructions = create_tween()
	
	tween_clean_instructions.tween_property(%Instruction1, "modulate", Color(1, 1, 1, 0), 1)
	tween_clean_instructions.parallel().tween_property(%Instruction2, "modulate", Color(1, 1, 1, 0), 1)
	
	tween_clean_instructions.tween_callback(Callable(%Instruction1, "visible").bind(false))
	tween_clean_instructions.tween_callback(Callable(%Instruction2, "visible").bind(false))

var steps_taken: int = 0
func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if steps_taken ==0:
			_clean_instructions()
			_step_forward()
		elif steps_taken < 10:
			_step_forward()
		else:
			print("Good")
			pass
