extends Node
class_name FiniteStateMachine

var states : Dictionary = {}
var currentState : State
@export var initialState : State


func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.stateTransition.connect(changeState)
		
	if initialState:
		initialState.Enter()
		currentState = initialState


func _process(delta):
	if currentState:
		currentState.Update(delta)

func _physics_process(delta):
	if currentState:
		currentState.PhysicsUpdate(delta)

func changeState(sourceState : State, newStateName : String):
	if sourceState != currentState:
		print("Invalid changeState trying from: " + sourceState.name + " but currently in: " + currentState.name)
		return
		
	var newState = states.get(newStateName.to_lower())
	if not newState:
		print("New state is empty")
		return
		
	if currentState:
		currentState.Exit()
		
	newState.Enter()
	currentState = newState
