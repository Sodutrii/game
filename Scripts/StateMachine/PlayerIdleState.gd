extends State

@onready var head: Node3D = $"../../Head"
@onready var camera: Camera3D = $"../../Head/Camera3D"
@onready var player : CharacterBody3D = $"../.."
@onready var grappleRaycast : RayCast3D = $"../../Head/Camera3D/RayCast3D"

func Enter():
	print("enter Idle State")

func Update(_delta: float):
	DetectStateChange()
	
func PhysicsUpdate(delta: float):
	StopMovement(delta)

func Exit():
	pass


func DetectStateChange():
	var isMoving = Input.get_vector("left", "right", "up", "down")
	var justPressedJump = Input.is_action_just_pressed("jump")
	if isMoving or justPressedJump:
		stateTransition.emit(self, "PlayerMoveState")
		
	var isGrappling = Input.is_action_just_pressed("leftMouse")
	var isGrappleRaycastColliding = grappleRaycast.is_colliding()
	if isGrappling and isGrappleRaycastColliding:
		stateTransition.emit(self, "PlayerGrappleState")
		

func StopMovement(delta):
	# Ignore the input direction and handle only the movement deceleration.
	var direction = Vector3.ZERO
	if player.is_on_floor():
		if player.velocity.length() > 0:
			player.velocity.x = lerp(player.velocity.x, direction.x, delta * 10.0)
			player.velocity.z = lerp(player.velocity.z, direction.z, delta * 10.0)
		else:
			player.velocity.x = 0
			player.velocity.z = 0
	else:
		player.velocity.x = lerp(player.velocity.x, direction.x, delta * 3.0)
		player.velocity.z = lerp(player.velocity.z, direction.z, delta * 3.0)

	# Check if the player velocity is very small to stop it completely
	if player.velocity.length() < 0.01:
		player.velocity = Vector3.ZERO
