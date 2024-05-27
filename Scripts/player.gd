extends CharacterBody3D

#settings
var sensitivity: float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SettingsData.connect("onUpdatedSettingsJsonFile", UpdateSettings)
	
	sensitivity = SettingsData.settingsData["sensitivity"]
	gravity = SettingsData.settingsData["gravity"]
	


func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity /10000)
		camera.rotate_x(-event.relative.y * sensitivity /10000)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta) -> void:
	Gravity(delta)
	
	move_and_slide()


func Gravity(delta):
	velocity.y -= gravity * delta


func UpdateSettings():
	sensitivity = SettingsData.settingsData["sensitivity"]
	gravity = SettingsData.settingsData["gravity"]
