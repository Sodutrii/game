extends State

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


@onready var head: Node3D = $"../../Head"
@onready var camera: Camera3D = $"../../Head/Camera3D"
@onready var player : CharacterBody3D = $"../.."


func Enter():
	Jump()
	print("enter Pause State")


func Update(_delta: float):
	pass


func PhysicsUpdate(delta: float):
	DetectStateChange()
	CalculateSpeed()
	Sprint()
	Movement(delta)
	Jump()
	CrouchAndSlide(delta)
	FieldOfView(delta)
	Headbob(delta)

func Exit():
	pass


func DetectStateChange():
	pass


func CalculateSpeed():
	speed = baseWalkSpeed * sprintSpeed * crouchSpeed


func Movement(delta):
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if player.is_on_floor():
		if direction:
			player.velocity.x = direction.x * speed
			player.velocity.z = direction.z * speed
		else:
			player.velocity.x = lerp(player.velocity.x, direction.x * speed, delta * 10.0)
			player.velocity.z = lerp(player.velocity.z, direction.z * speed, delta * 10.0)
	else:
		player.velocity.x = lerp(player.velocity.x, direction.x * speed, delta * 3.0)
		player.velocity.z = lerp(player.velocity.z, direction.z * speed, delta * 3.0)


func Sprint():
	if Input.is_action_pressed("sprint"):
		sprintSpeed = sprintSpeedMult
	else:
		sprintSpeed = 1


func Jump():
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.velocity.y = JUMP_VELOCITY


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


func Headbob(delta):
	t_bob += delta * player.velocity.length() * float(player.is_on_floor())
	var pos = Vector3.ZERO
	pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP
	pos.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
	camera.transform.origin = pos
