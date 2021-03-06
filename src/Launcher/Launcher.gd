extends Building
class_name Launcher


onready var projectile_spawn = $Barrel/Projectile_Spawn
onready var launch_pos_sprite = $Launch_Direction
onready var cannon = $Barrel
onready var predictor = $Predictor
onready var chair = $Manning_Position
onready var launcher_ui = $CanvasLayer/LauncherUI
onready var load_noise = $Sounds/Loading_Sound
onready var shoot_noise = $Sounds/Shooting_Noise

var current_projectile = null
var manned = false

#For aiming
var launch_pos = Vector2(0,-25)


func _init():
	can_zoom = true


func _ready():
	camera_pos = get_node("Camera_Position").get_position()
	spawn()



func _handle_aim():
	launch_pos_sprite.set_position(launcher_ui.get_aim()+Vector2(0,-10))
	aim_barrel()


func fire(direction):
	if current_projectile != null:
		change_parent(current_projectile, self)
		shoot_noise.play()
		current_projectile.launch(direction, true)
		current_projectile = null


func aim_barrel():
	cannon.set_rotation((launch_pos_sprite.get_position()-cannon.get_position()).angle()+PI/2)


func predict_path(direction):
	if current_projectile != null:
		predictor.predict({
#			"gravity_force" : 1
			"texture" : current_projectile.get_node(@"Sprite").get_texture(),
			"texture_region" : current_projectile.get_node(@"Sprite").get_region_rect(),
			"texture_scale" : current_projectile.get_node(@"Sprite").get_scale(),
			"collision" : current_projectile.shape_owner_get_owner(current_projectile.get_shape_owners()[0]).get_shape(),
			"sim_speed" : 8,
			"from_planet" : true,
			"launch_position" : to_local(current_projectile.get_global_position()),
			"velocity" : direction
		})


func end_predict():
	predictor.end_predict()


func store_item(body):
	if current_projectile == null && !tween.is_active():
		change_parent(body, projectile_spawn)
		current_projectile = body
		current_projectile.arm()
		position_projectile()
		load_noise.play()
		return true
	else:
		return false


func position_projectile():
	if current_projectile != null:
		current_projectile.set_position(Vector2(0,0)) 
		current_projectile.rotation = 0


func enter_building(entered):
	if player == null && !tween.is_active():
		change_parent(entered, self)
		manned = true
		launcher_ui.open()
		player = entered
		player.set_position(chair.get_position())
		player.set_rotation(0)
		player.set_mode(1)
		return true
	else: 
		return false


func exit_building():
	player.leave_building(self)
	player.call_deferred("set_mode", 0)
	change_parent(player, get_parent())
	manned = false
	launcher_ui.close()
	player = null


func _on_Exception_Area_body_entered(body):
	if body is Projectile:
		body.too_close = true


func _on_Exception_Area_body_exited(body):
	if body is Projectile:
		body.too_close = false


func upgrade(_body):
	return false
