class_name SpellModule
extends Control

const Runes : Array[Texture] = [
	preload("res://Assets/UI/RuneUp.tres"),
	preload("res://Assets/UI/RuneDown.tres"),
	preload("res://Assets/UI/RuneLeft.tres"),
	preload("res://Assets/UI/RuneRight.tres"),
	preload("res://Assets/UI/RuneEmpty.tres")
]

enum RUNE_TYPES {NULL = -1, UP, DOWN, LEFT, RIGHT}

var currentInput : Array[int] = []

var inputMax : int = 0

func _ready() -> void:
	inputMax = get_child(0).get_child_count()
	update_runes("")

func _process(_delta) -> void:
	if not get_parent().is_multiplayer_authority():
		return
	if Input.is_action_just_pressed("cast_1"):
		add_rune(RUNE_TYPES.UP)
	if Input.is_action_just_pressed("cast_2"):
		add_rune(RUNE_TYPES.DOWN)
	if Input.is_action_just_pressed("cast_3"):
		add_rune(RUNE_TYPES.LEFT)
	if Input.is_action_just_pressed("cast_4"):
		add_rune(RUNE_TYPES.RIGHT)


func add_rune(input_type : int = RUNE_TYPES.NULL):
	if len(currentInput) >= inputMax:
		currentInput.clear()
	currentInput.append(input_type)
	var string_input = get_spellstring()
	update_runes(string_input)
	rpc('update_runes', string_input)

func get_spellstring() -> String:
	var string_input = ""
	for i in currentInput:
		string_input += str(i)
	return string_input

func reset_spellstring() -> void:
	currentInput.clear()
	var string_input = get_spellstring()
	update_runes(string_input)
	rpc('update_runes', string_input)

@rpc("unreliable")
func update_runes(stringParse : String = ""):
	for i in range(inputMax):
		var child = get_child(0).get_child(i).get_child(0)
		if i >= len(stringParse):
			child.texture = Runes[-1]
			continue
		child.texture = Runes[stringParse[i].to_int()]
