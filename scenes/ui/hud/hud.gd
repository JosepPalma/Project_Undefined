extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func decrease_health_bar(health_points):
	match health_points:
		2:
			$HealthBar/HP2.hide()
		1:
			$HealthBar/HP1.hide()
		0:
			$HealthBar/HP0.hide()


func set_score(score):
	$Score/ScoreLabel.text = str(score)
