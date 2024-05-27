extends MeshInstance3D

@onready var hook_raycast = $"../RayCast3D"
@onready var player_body = $"../../.."
@onready var camera = $".."
@onready var grapple = $"."
@onready var pauseMenu = $"../../../../Menu"

@export var pull_speed: float = 1

var _hook_target_normal: Vector3
var is_hook_launched: bool
var hook_target_position: Vector3


const JUMP_VELOCITY = 4.8
var pauseMenuOpen: bool = false



signal hook_launched()
signal hook_attached()
signal hook_detached()

func _ready():
	pauseMenu.connect("openPauseMenu", DisableGrappleWhenPaused)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_hook_launched:
		_retract_hook()
		player_body.velocity.y +=  JUMP_VELOCITY
		
	if Input.is_action_just_pressed("leftMouse") and not pauseMenuOpen:
		hook_launched.emit()
		if not is_hook_launched and hook_raycast.is_colliding():
			_attach_hook()
		elif is_hook_launched:
			_retract_hook()
	if is_hook_launched:
		_handle_hook(delta)
		
		
func _attach_hook() -> void:
	is_hook_launched = true
	
	hook_target_position = hook_raycast.get_collision_point()
	_hook_target_normal = hook_raycast.get_collision_normal()
	SetGrapplePoint()
	hook_attached.emit()
	
func _retract_hook() -> void:
	is_hook_launched = false
	RemoveGrapplePoint()
	hook_detached.emit()
	
func _handle_hook(delta: float) -> void:
	var pull_vector = (hook_target_position - player_body.global_position).normalized()
	player_body.velocity += pull_vector * pull_speed * delta * 30
	
	var distance = player_body.position.distance_to(hook_target_position)
	print(distance)
	
func DisableGrappleWhenPaused(isOpen: bool):
	pauseMenuOpen = isOpen
	
	
	#temp testing functoin plz delete
func SetGrapplePoint():
	var grapplePoint: MeshInstance3D = $GrapplePointfortestingplzdelete
	grapplePoint.visible = true
	grapplePoint.transform.origin = hook_target_position
	
	#temp testing functoin plz delete
func RemoveGrapplePoint():
	var grapplePoint: MeshInstance3D = $GrapplePointfortestingplzdelete
	grapplePoint.visible = false
	
