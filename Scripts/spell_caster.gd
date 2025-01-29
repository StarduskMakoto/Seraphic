extends Node2D

var id_to_execute : int = -1
var spell_to_execute : Spell = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(get_child_count()):
		get_child(i).set_meta("SpellID", i)
	pass # Replace with function body.

func execute_string(spellstring : String = "", params : Dictionary = {}):
	if not get_parent().is_multiplayer_authority():
		return
	for i in get_children():
		if not i is Spell:
			continue
		if spellstring != i.spellstring:
			continue
		spell_to_execute = i._get_spell(params)
		if spell_to_execute != null:
			id_to_execute = spell_to_execute.get_meta("SpellID", -1)
		break
	
	cast_spell(id_to_execute)
	rpc('cast_spell', id_to_execute)
	spell_to_execute = null
	id_to_execute = -1

@rpc("unreliable")
func cast_spell(id : int = -1):
	if id < 0:
		return
	spell_to_execute = get_child(id)
	spell_to_execute._cast()
