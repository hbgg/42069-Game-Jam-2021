extends RayCast2D

export var cast_speed := 7000.0
export var max_length := 1400
export var growth_time := 0.1
export var beam_color : = Color(0.30,0.65,1.00,1.00) setget set_beam_color
export var particle_color :Color = Color(0.30,0.65,1.00,1.00) setget set_particle_color

onready var casting_particles := $CastingParticles2D
onready var collision_particles := $CollisionParticles2D
onready var beam_particles := $BeamParticles2D
onready var fill := $FillLine2D
onready var tween := $Tween
export  var line_width: float = 10

var is_casting := false setget set_is_casting


func _ready() -> void:
	set_physics_process(false)
	fill.points[1] = Vector2.ZERO


func set_beam_color(_value: Color):
	beam_color = _value


func set_particle_color(_value: Color):
	particle_color = _value


func _physics_process(delta: float) -> void:
	cast_to = (cast_to + Vector2.RIGHT * cast_speed * delta).clamped(max_length)
	cast_beam()


func set_is_casting(cast: bool) -> void:
	is_casting = cast

	casting_particles.set_modulate(particle_color)
	beam_particles.set_modulate(particle_color)
	collision_particles.set_modulate(particle_color)
	fill.set_default_color(beam_color)

	if is_casting:
		cast_to = Vector2.ZERO
		fill.points[1] = cast_to
		appear()
	else:
		collision_particles.emitting = false
		disappear()

	set_physics_process(is_casting)
	beam_particles.emitting = is_casting
	casting_particles.emitting = is_casting


func cast_beam() -> void:
	var cast_point := cast_to

	# Required, the raycast's collisions update one frame after moving otherwise, making the laser
	# overshoot the collision point.
	force_raycast_update()
	if is_colliding():
		cast_point = to_local(get_collision_point())
		collision_particles.process_material.direction = Vector3(
			get_collision_normal().x, get_collision_normal().y, 0
		)

	collision_particles.emitting = is_colliding()

	fill.points[1] = cast_point
	collision_particles.position = cast_point
	beam_particles.position = cast_point * 0.5
	beam_particles.process_material.emission_box_extents.x = cast_point.length() * 0.5


func appear() -> void:
	if tween.is_active():
		tween.stop_all()
	tween.interpolate_property(fill, "width", 0, line_width, growth_time * 2)
	tween.start()


func disappear() -> void:
	if tween.is_active():
		tween.stop_all()
	tween.interpolate_property(fill, "width", fill.width, 0, growth_time)
	tween.start()
