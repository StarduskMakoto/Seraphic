extends CharacterBody2D

@onready var HealthBar = $HPBar

@onready var statNode = $Stats

const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseButton:
		if not event.is_pressed():
			return
		var dir = self.global_position.direction_to(get_global_mouse_position())
		var dest = self.global_position + (dir * 500.)
		#rpc('_attack', dest)
		_attack({"dest": dest})

@rpc("reliable")
func set_nickname(new_name : String):
	if new_name == "":
		$Name.text = name
		return
	$Name.text = new_name

func _ready() -> void:
	name = str(get_multiplayer_authority())
	print(name)
	$Name.text = name
	if is_multiplayer_authority():
		$Camera2D.make_current()
	$Stats/HP._setup(100, HealthBar)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionx := Input.get_axis("ui_left", "ui_right")
	if directionx:
		velocity.x = directionx * SPEED
		if directionx < 0:
			$Sprite2D.scale.x = -1
		elif directionx > 0:
			$Sprite2D.scale.x = 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var directiony := Input.get_axis("ui_up", "ui_down")
	if directiony:
		velocity.y = directiony * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	rpc("update_position", self.global_position, $Sprite2D.scale)
	rpc("set_nickname", $Name.text)
	
	move_and_slide()

@rpc('unreliable')
func update_position(new_pos : Vector2, sprite_scale : Vector2):
	global_position = new_pos
	$Sprite2D.scale = sprite_scale

func _damage(val):
	if not is_multiplayer_authority():
		return
	print("AAAA")
	for i in statNode.get_children():
		if not i is HPComponent:
			return
		i._damage(val)
		rpc('turn_red')
		turn_red()
		break
	pass

#@rpc
#func _attack(dest : Vector2 = Vector2.ZERO):
func _attack(params : Dictionary = {}):
	#var attack = preload("res://Scenes/Attacks/MagicBlast.tscn").instantiate()
	#attack.global_position = self.global_position
	#attack._setup(self.global_position, dest, self)
	#get_parent().add_child(attack)
	print($SpellModule.get_spellstring())
	$Spells.execute_string($SpellModule.get_spellstring(), params)
	$SpellModule.reset_spellstring()

@rpc
func turn_red():
	var red_tween = create_tween()
	red_tween.tween_property(self, "modulate", Color("#ff0000"), 0)
	red_tween.tween_property(self, "modulate", Color("#ffffff"), 0.2)
	red_tween.tween_callback(func(): red_tween.kill())

func reset():
	global_position = Vector2.ZERO
