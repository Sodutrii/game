extends Control

@onready var pauseMenu = $PauseMenu
@onready var settingsMenu = $SettingsMenu
@onready var sensitivitySlider = $"SettingsMenu/MarginContainer/VBoxContainer/Sensitivity HSlider"
@onready var gravitySlider = $"SettingsMenu/MarginContainer/VBoxContainer/Gravity HSlider"


signal openPauseMenu(isOpen: bool)
signal onChangedSetting(setting: String, value)

func _ready():
	connect("onChangedSetting", SettingsData.ChangeSettingsConfig)
	sensitivitySlider.value = SettingsData.settingsData["sensitivity"]
	gravitySlider.value = SettingsData.settingsData["gravity"]

func _process(delta):
	if Input.is_action_just_pressed("Menu"):
		if not visible:
			OpenMenu()
		else:
			ExitMenu()

func OpenMenu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_filter = MOUSE_FILTER_STOP
	visible = true
	openPauseMenu.emit(true)

func ExitMenu():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_filter = MOUSE_FILTER_PASS
	visible = false
	openPauseMenu.emit(false)

func QuitGame():
	get_tree().quit()


func SwitchMenu():
	if pauseMenu.visible:
		pauseMenu.visible = false
		settingsMenu.visible = true
	else:
		pauseMenu.visible = true
		settingsMenu.visible = false
		


func SensitivitySlider(value: float):
	var SensitivityLabel = $"SettingsMenu/MarginContainer/VBoxContainer/Sensitivity RichTextLabel"
	SensitivityLabel.text = "[center]Sensitivity: " + str(value)
	onChangedSetting.emit("sensitivity", value)


func GravitySlider(value):
	var GravityLabel = $"SettingsMenu/MarginContainer/VBoxContainer/Gravity RichTextLabel"
	GravityLabel.text = "[center]Gravity: " + str(value)
	onChangedSetting.emit("gravity", value)
