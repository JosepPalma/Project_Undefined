extends RayCast3D


signal escape

@onready var camera = get_parent()
@onready var neck = camera.get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding() and Input.is_action_pressed("interact"):
		if get_collider().has_method("gemScanned"):
			get_collider().gemScanned()
		else:
			escape.emit()
