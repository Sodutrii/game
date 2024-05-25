extends CharacterBody3D

#settings
var sensitivity: float

#movement
const JUMP_VELOCITY: float = 4.8
var speed: float

var baseWalkSpeed: float = 5.0
var sprintSpeedMult: float = 1.4
var crouchSpeedMult:float = 0.5

var sprintSpeed: float
var crouchSpeed:float

#bob variables
const BOB_FREQ: float = 2.0
const BOB_AMP: float = 0.06
var t_bob: float = 0.0

#fov variables
const BASE_FOV: float = 75.0
const FOV_CHANGE: float = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float# = 9.8

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
	Movement(delta)
	CalculateSpeed()
	Jump()
	Sprint()
	Headbob(delta)
	FieldOfView(delta)
	CrouchAndSlide(delta)
	
	move_and_slide()


func Gravity(delta):
	#if not is_on_floor():
	velocity.y -= gravity * delta
		
func CalculateSpeed():
	speed = baseWalkSpeed * sprintSpeed * crouchSpeed


func Movement(delta):
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 10.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 10.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)


func Jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


func Sprint():
	if Input.is_action_pressed("sprint"):
		sprintSpeed = sprintSpeedMult
	else:
		sprintSpeed = 1


func Headbob(delta):
	t_bob += delta * velocity.length() * float(is_on_floor())
	var pos = Vector3.ZERO
	pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP
	pos.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
	camera.transform.origin = pos


func CrouchAndSlide(delta):
	if Input.is_action_pressed("crouch"):
		crouchSpeed = crouchSpeedMult
		camera.transform.origin.y -= 0.3
	else:
		crouchSpeed = 1
		camera.transform.origin.y += 0.3


func FieldOfView(delta):
	var velocity_clamped = clamp(0, 0.5, speed)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
func UpdateSettings():
	sensitivity = SettingsData.settingsData["sensitivity"]
	gravity = SettingsData.settingsData["gravity"]
