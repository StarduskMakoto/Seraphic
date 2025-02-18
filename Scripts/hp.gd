class_name HPComponent
extends Node

var maxHP : float = 100
var currentHP : float = 100

var HP_Bar : Range = null

func _setup(max_hp : float, health_bar : Range = null):
	maxHP = max_hp
	currentHP = maxHP
	HP_Bar = health_bar
	if HP_Bar == null:
		return
	HP_Bar.max_value = maxHP
	HP_Bar.value = currentHP

func _damage(val):
	print("HERE")
	var newhp = currentHP
	newhp -= val
	if newhp < 0:
		newhp = maxHP
		get_parent().get_parent().reset()
	rpc("update_stat", maxHP, newhp)
	update_stat(maxHP, newhp)

func _update_bar(new_max, new_cur):
	maxHP = new_max
	currentHP = new_cur
	if HP_Bar == null:
		return
	HP_Bar.max_value = maxHP
	HP_Bar.value = currentHP

@rpc('unreliable')
func update_stat(new_max, new_cur):
	_update_bar(new_max, new_cur)
