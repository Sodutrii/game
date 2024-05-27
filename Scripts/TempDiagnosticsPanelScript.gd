extends Label

@onready var player = $"../Player"

func _process(delta):
	text = "FPS: " + str(Engine.get_frames_per_second()) + "\n" + "X: " + str(round(player.translation.x)) + "\n" + "Y: " + str(round(player.translation.y)) + "\n" + "Z: " + str(round(player.translation.z))
