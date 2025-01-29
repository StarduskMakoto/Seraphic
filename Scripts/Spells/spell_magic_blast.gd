extends Spell

var dest : Vector2 = Vector2.ZERO

func _cast() -> void:
	var attack = preload("res://Scenes/Attacks/MagicBlast.tscn").instantiate()
	#attack.global_position = self.global_position
	attack._setup(self.global_position, dest, casterParent)
	casterParent.get_parent().add_child(attack)

func _get_spell(_params : Dictionary = {}) -> Spell:
	if not _params.has("dest"):
		return null
	dest = _params["dest"]
	rpc('_sync', _params)
	return self

@rpc("unreliable")
func _sync(traits : Dictionary = {}) -> void:
	dest = traits["dest"]
	pass
