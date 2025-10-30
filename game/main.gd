extends Node

const INITIAL_SCALE: float = 1
const FINAL_SCALE: float = 12
@export var number_of_steps: int = 5
@onready var scale_factor: float = pow(FINAL_SCALE / INITIAL_SCALE, 1. / number_of_steps)

const SFX_IMPACT_FOLDER = "res://audio/impact/"
const IMPACT_SOUNDS: Array[AudioStream] = [
	preload(SFX_IMPACT_FOLDER + "impactWood_heavy_001.ogg"),
	preload(SFX_IMPACT_FOLDER + "impactWood_heavy_002.ogg"),
	preload(SFX_IMPACT_FOLDER + "impactWood_heavy_003.ogg"),
	preload(SFX_IMPACT_FOLDER + "impactWood_heavy_004.ogg")
]

const SFX_STEP_FOLDER = "res://audio/footstep/"
const STEP_SOUNDS: Array[AudioStream] = [
	preload(SFX_STEP_FOLDER + "footstep_wood_001.ogg"),
	preload(SFX_STEP_FOLDER + "footstep_wood_002.ogg"),
	preload(SFX_STEP_FOLDER + "footstep_wood_003.ogg"),
	preload(SFX_STEP_FOLDER + "footstep_wood_004.ogg")
]

const SFX_ROAR_FOLDER = "res://audio/roar/"
const ROAR_SOUNDS: Array[AudioStream] = [
	preload(SFX_ROAR_FOLDER + "roar_002.wav"),
	preload(SFX_ROAR_FOLDER + "roar_003.wav"),
	preload(SFX_ROAR_FOLDER + "roar_007.wav"),
	preload(SFX_ROAR_FOLDER + "roar_007.wav"),
	preload(SFX_ROAR_FOLDER + "roar_008.wav")
]

var tween_on_start: Tween
func _on_start_pressed() -> void:
	%Door.play("open")
	%AudioStreamPlayers/OpeningDoor.play()
	%Game.visible = true
	%Key.modulate = Color(1, 1, 1, 0)
	%Key.scale = Vector2(1, 1)
	%Key.position = Vector2(1, 1)
	set_game_state("INTRO")
	
	if tween_on_start:
		tween_on_start.kill()
	tween_on_start = create_tween()
	# Door moving forward
	tween_on_start.set_trans(Tween.TRANS_SINE)
	tween_on_start.set_ease(Tween.EASE_IN)
	tween_on_start.tween_property(%Door, "scale", Vector2(48, 48), 2)
	
	# Menu fade
	tween_on_start.set_trans(Tween.TRANS_QUAD)
	tween_on_start.set_ease(Tween.EASE_OUT)
	tween_on_start.parallel().tween_property(%Menu, "modulate", Color(1, 1, 1, 0), 2)
	
	# Clean up
	tween_on_start.tween_callback(Callable(%Door, "set_visible").bind(false))
	tween_on_start.tween_callback(Callable(%Menu, "set_visible").bind(false))
	
	# 3. Closing door
	tween_on_start.tween_callback(Callable(%AudioStreamPlayers/ClosingDoor, "play"))
	
	# Key reveal
	tween_on_start.set_ease(Tween.EASE_IN)
	tween_on_start.tween_property(%Key, "modulate", Color(1, 1, 1, 1), 1).set_delay(1)
	
	# Monster reveal
	tween_on_start.tween_property(%Instruction1, "modulate", Color(1, 1, 1, 1), 1)
	tween_on_start.tween_callback(Callable(self, "step_monster"))
	tween_on_start.tween_property(%Instruction2, "modulate", Color(1, 1, 1, 1), 1).set_delay(2)
	tween_on_start.tween_callback(Callable(self, "set_game_state").bind("FIRST PHASE"))
	
	tween_on_start.set_ease(Tween.EASE_OUT)
	tween_on_start.tween_interval(2)
	tween_on_start.tween_property(%Instruction1, "modulate", Color(1, 1, 1, 0), 1)
	tween_on_start.parallel().tween_property(%Instruction2, "modulate", Color(1, 1, 1, 0), 1)
	
var game_state: String = "MENU"
var tween_game_state: Tween
func set_game_state(value: String):
	if tween_game_state:
		tween_game_state.kill()
	tween_game_state = create_tween()
	
	game_state = value
	if game_state == "MENU":
		%InstructionText.text = "Enter the silence"
		tween_game_state.tween_property(%Instruction, "modulate", Color(1, 1, 1, 1), 0.5)
	elif game_state == "INTRO":
		tween_game_state.tween_property(%Instruction, "modulate", Color(1, 1, 1, 0), 0.5)
	elif game_state == "FIRST PHASE":
		%InstructionText.text = "Step forward"
		tween_game_state.tween_property(%Instruction, "modulate", Color(1, 1, 1, 1), 0.5)
	elif game_state == "PHASE TRANSITION":
		tween_game_state.tween_property(%Instruction, "modulate", Color(1, 1, 1, 0), 0.5)
	elif game_state == "SECOND PHASE":
		%InstructionText.text = "Step forward"
		tween_game_state.tween_property(%Instruction, "modulate", Color(1, 1, 1, 1), 0.5)
	elif game_state == "SECOND PHASE":
		%InstructionText.text = "Step forward"
		tween_game_state.tween_property(%Instruction, "modulate", Color(1, 1, 1, 1), 0.5)
	elif game_state == "WIN":
		%InstructionText.text = "Continue"
		tween_game_state.tween_property(%Instruction, "modulate", Color(0, 0, 0, 1), 0.5)
	elif game_state == "DEAD":
		%InstructionText.text = "Continue"
		tween_game_state .tween_property(%Instruction, "modulate", Color(1, 1, 1, 1), 0.5)
	
var number_step_monster: int = 0
func increment_number_step_monster():
	number_step_monster += 1

var tween_monster: Tween
func step_monster():
	if game_state == "FIRST PHASE" or game_state == "INTRO":
		%Timer.start(5)
	elif game_state == "PHASE TRANSITION" or game_state == "SECOND PHASE":
		%Timer.start(3 + randi() % 4)
	else:
		return
	%AudioStreamPlayers/Impact.stream = IMPACT_SOUNDS[randi() % IMPACT_SOUNDS.size()]

	if tween_monster:
		tween_monster.kill()
	tween_monster = create_tween()
	tween_monster.tween_callback(Callable(%AudioStreamPlayers/Inhale, "play"))
	
	tween_monster.tween_interval(1.5)
	tween_monster.tween_callback(Callable(self, "set_is_safe_to_step").bind(true))
	
	tween_monster.tween_callback(Callable(%AudioStreamPlayers/Impact, "play")).set_delay(0.4)
	tween_monster.parallel().tween_callback(Callable(self, "set_is_safe_to_step").bind(false)).set_delay(0.5) # 0.5s to step forward
	
	tween_monster.tween_callback(Callable(self, "increment_number_step_monster"))

var is_safe_to_step: bool = false
func set_is_safe_to_step(value: bool):
	is_safe_to_step = value

func _on_timer_timeout() -> void:
	step_monster()

var tween_step_forward: Tween
func _step_forward(node: Node):
	steps_taken += 1
	print("Steps: %d" % steps_taken)
	
	if tween_step_forward:
		tween_step_forward.kill()
	tween_step_forward = create_tween()
	
	if not is_safe_to_step:
		# Only play the step sound when off sync with the monster
		%AudioStreamPlayers/Step.stream = STEP_SOUNDS[randi() % STEP_SOUNDS.size()]
		%AudioStreamPlayers/Step.play()
		game_over()
	
	var new_scale: Vector2 = node.scale * scale_factor
	
	tween_step_forward.set_trans(Tween.TRANS_SINE)
	tween_step_forward.set_ease(Tween.EASE_OUT)
	tween_step_forward.tween_property(node, "scale", new_scale, 0.3)

var tween_change_phase: Tween
func change_phase():
	set_game_state("PHASE TRANSITION")
	%DoorFrame.play("idle")
	%DoorFrame.scale = Vector2(1, 1)
	%DoorFrame.position = Vector2(-1000, 0)
	%DoorFrame.modulate = Color(1, 1, 1, 1)
	steps_taken = 0
	
	if tween_change_phase:
		tween_change_phase.kill()
	tween_change_phase = create_tween()
	
	tween_change_phase.set_trans(Tween.TRANS_QUAD)  
	tween_change_phase.set_ease(Tween.EASE_IN)
	tween_change_phase.tween_property(%Key, "position", Vector2(0, 1000), 0.5)
	tween_change_phase.parallel().tween_property(%DoorFrame, "position", Vector2(0, 0), 0.5).set_delay(0.3)
	
	tween_change_phase.tween_callback(Callable(self, "set_game_state").bind("SECOND PHASE"))

var tween_win_game: Tween
func win_game():
	set_game_state("WIN")
	if tween_monster:
		tween_monster.kill()
	if tween_win_game:
		tween_win_game.kill()
	tween_win_game = create_tween()
	
	# Door moving forward
	%Score.text = "The Sleeper's count: %d steps" % number_step_monster
	%Win.modulate = Color(1, 1, 1, 0)
	%Win.visible = true
	%AudioStreamPlayers/OpeningDoor.play()
	%DoorFrame.play("open")
	tween_win_game.set_trans(Tween.TRANS_SINE)
	tween_win_game.set_ease(Tween.EASE_IN)
	tween_win_game.tween_property(%DoorFrame, "scale", Vector2(48, 48), 2)
	tween_win_game.tween_property(%Win, "modulate", Color(1, 1, 1, 1), 2)
	
var steps_taken: int = 0
func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if game_state == "MENU":
			_on_start_pressed()
		elif game_state == "FIRST PHASE":
			if steps_taken < number_of_steps:
				_step_forward(%Key)
			else:
				change_phase()
		elif game_state == "SECOND PHASE":
			if steps_taken < number_of_steps:
				_step_forward(%DoorFrame)
			else:
				win_game()
		elif game_state == "DEAD":
			reset_menu(%GameOver)
		elif game_state == "WIN":
			reset_menu(%Win)
		
var tween_reset_menu: Tween
func reset_menu(node: Node):
	steps_taken = 0
	number_step_monster = 0

	%Door.modulate = Color(1, 1, 1, 0)
	%Door.scale = Vector2(8, 8)
	%Door.play("idle")
	%Menu.visible = true
	%Door.visible = true
	
	if tween_reset_menu:
		tween_reset_menu.kill()
	tween_reset_menu = create_tween()
	
	tween_reset_menu.set_trans(Tween.TRANS_QUAD)
	tween_reset_menu.set_ease(Tween.EASE_OUT)
	tween_reset_menu.tween_property(node, "modulate", Color(1, 1, 1, 0), 0.5)
	tween_reset_menu.parallel().tween_property(%DoorFrame, "modulate", Color(1, 1, 1, 0), 0.5)
	
	tween_reset_menu.tween_callback(Callable(node, "set_visible").bind(false))
	
	tween_reset_menu.set_trans(Tween.TRANS_QUAD)  
	tween_reset_menu.set_ease(Tween.EASE_IN)
	tween_reset_menu.tween_property(%Menu, "modulate", Color(1, 1, 1, 1), 0.5)
	tween_reset_menu.parallel().tween_property(%Door, "modulate", Color(1, 1, 1, 1), 0.5)
	
	tween_reset_menu.tween_callback(Callable(self, "set_game_state").bind("MENU"))

var tween_game_over: Tween
func game_over():
	set_game_state("DEAD TRANSITION")
	if tween_monster:
		tween_monster.kill()
	if tween_game_over:
		tween_game_over.kill()
	tween_game_over = create_tween()
	
	%AudioStreamPlayers/Roar.stream = ROAR_SOUNDS[randi() % ROAR_SOUNDS.size()]
	%AudioStreamPlayers/Roar.play()
	
	%GameOver.modulate = Color(1, 1, 1, 0)
	%GameOver.visible = true
	
	tween_game_over.set_trans(Tween.TRANS_QUAD)  
	tween_game_over.set_ease(Tween.EASE_IN)
	tween_game_over.tween_property(%GameOver, "modulate", Color(1, 1, 1, 1), 0.5)
	
	tween_game_over.set_trans(Tween.TRANS_QUAD)  
	tween_game_over.set_ease(Tween.EASE_OUT)
	tween_game_over.parallel().tween_property(%Key, "modulate", Color(1, 1, 1, 0), 0.5)
	tween_game_over.parallel().tween_property(%DoorFrame, "modulate", Color(1, 1, 1, 0), 0.5)
	
	tween_game_over.tween_callback(Callable(self, "set_game_state").bind("DEAD"))
	
