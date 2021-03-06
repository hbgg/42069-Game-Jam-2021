extends Building


var refinery_output = 1

func _ready():
	set_physics_process(false)
	spawn()


func _physics_process(delta):
	GameData.stardust += refinery_output * delta


func start():
	set_physics_process(true)
	for particle in $Particles.get_children():
		particle.set_emitting(true)

func die():
	set_physics_process(false)
	for particle in $Particles.get_children():
		particle.set_emitting(false)


func _on_exception_area_entered(body):
	if body is Projectile:
		body.too_close = true


func _on_exception_area_exited(body):
	if body is Projectile:
		body.too_close = false
