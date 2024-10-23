extends StaticBody3D


signal gem_scanned

var scanned = false


func _ready():
	pass


func _process(delta):
	pass


func gemScanned():
	if not scanned:
		scanned = true
		$OmniLight3D.visible = false
		gem_scanned.emit()
