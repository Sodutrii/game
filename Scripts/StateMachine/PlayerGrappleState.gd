extends State

@onready var hook_raycast = $"../../Head/Camera3D/RayCast3D"
@onready var player_body = $"../.."
@onready var camera = $"../../Head/Camera3D"
@onready var grapple = $"../../Head/Camera3D/grapple"

@onready var player = $"../.."
@onready var head = $"../../Head"

#grappling variables
var _hook_target_normal: Vector3
var is_hook_launched: bool = false
var hook_target_position: Vector3
@export var pull_speed: float = 1

#movement variables
var speed : float = 7 # normal speed x sprint speed -> always sprinting while grappling
const JUMP_VELOCITY = 4.8

#fov variables
const BASE_FOV: float = 75.0
const FOV_CHANGE: float = 1.5


func Enter():
	print("enter Grapple State")
	if not is_hook_launched:
		_attach_hook()

func Update(_delta: float):
	pass


func PhysicsUpdate(delta: float):
	if Input.is_action_just_pressed("jump") and is_hook_launched:
		_retract_hook()
		player_body.velocity.y +=  JUMP_VELOCITY
		
	if Input.is_action_just_pressed("leftMouse") and is_hook_launched:
		_retract_hook()
		
	if is_hook_launched:
		_handle_hook(delta)
		
	Movement(delta)
	FieldOfView(delta)

func Exit():
	pass
	
func DetectStateChange():
	pass


func _attach_hook() -> void:
	is_hook_launched = true
	
	hook_target_position = hook_raycast.get_collision_point()
	_hook_target_normal = hook_raycast.get_collision_normal()
	SetGrapplePoint()

	
func _retract_hook() -> void:
	is_hook_launched = false
	RemoveGrapplePoint()
	stateTransition.emit(self, "PlayerMoveState")


func _handle_hook(delta: float) -> void:
	var pull_vector = (hook_target_position - player_body.global_position).normalized()
	player_body.velocity += pull_vector * pull_speed * delta * 30


func SetGrapplePoint():
	var grapplePoint: MeshInstance3D = $"../../Head/Camera3D/grapple/GrapplePointfortestingplzdelete"
	grapplePoint.visible = true
	grapplePoint.transform.origin = hook_target_position


	#temp testing functoin plz delete
func RemoveGrapplePoint():
	var grapplePoint: MeshInstance3D = $"../../Head/Camera3D/grapple/GrapplePointfortestingplzdelete"
	grapplePoint.visible = false

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


func FieldOfView(delta):
	var velocity_clamped = clamp(0, 0.5, speed)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
