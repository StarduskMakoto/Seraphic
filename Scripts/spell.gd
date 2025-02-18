class_name Spell
extends Node2D

@export var casterParent : Node2D

@export var spellstring : String = ""

func _get_spell(_params : Dictionary = {}) -> Spell:
	return self

@rpc("unreliable")
func _sync(_traits : Dictionary = {}) -> void:
	pass
