extends Building


var scrap_force = Vector2(-40,-40)
var scrap_force_offset = Vector2(0,-10)

var ready = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Player/Camera")._set_current(true)
	get_node("Player").enter_building(self)
	player = get_node("Player")
	player.call_deferred("enter_building",self)
	yield(get_tree().create_timer(1),"timeout")
	throw_scrap()


func _input(_event):
	if Input.is_action_just_pressed("interact") && player != null && ready:
		exit_building()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func enter_building(entered):
	return true

func exit_building():
	player.leave_building(self)
	player.set_mode(0)
	change_parent(player, get_parent())
	despawn()
	player.apply_central_impulse(Vector2(0,10).rotated(get_position().angle()+PI/2))
	player = null


func throw_scrap():
	var left_door = $Left_Door
	var right_door = $Right_Door
	var rotPosition = get_position().angle()+PI/2
	change_parent(left_door, get_parent())
	change_parent(right_door, get_parent())
	if left_door != null:
		left_door.apply_impulse(scrap_force_offset.rotated(rotPosition),scrap_force.rotated(rotPosition))
	if right_door != null:
		right_door.apply_impulse(scrap_force_offset.rotated(rotPosition),Vector2(-scrap_force.x,scrap_force.y).rotated(rotPosition))
	ready = true


func change_layer(body, scrap):
	scrap.set_z_index(0)


func despawn():
	var base = $Pod_Base
	var rotPosition = get_position().angle()+PI/2
	change_parent(base, get_parent())
	base.set_collision_layer(8)
	base.set_collision_mask(24)
	base.set_mode(0)
	
	base.apply_impulse(Vector2(6,0).rotated(rotPosition), Vector2(0,-50).rotated(rotPosition))
	yield(get_tree().create_timer(1),"timeout")
	queue_free()
