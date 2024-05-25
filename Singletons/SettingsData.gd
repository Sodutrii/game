extends Node

var sensitivity: float
var settingsJsonPath: String = "res://Config/Settings.json"
var settingsFile
var settingsData = {"gravity":9.8,"sensitivity":10}

signal onUpdatedSettingsJsonFile() # Emitted when Settings.json updated

func _ready():
	settingsData = LoadJsonFile(settingsJsonPath)

# Loads Json
func LoadJsonFile(filePath: String):
	if not FileAccess.file_exists(filePath):
		WriteSettingsToJsonFile(filePath, settingsData) # Creates new SettingsJson if not there
	
	settingsFile = FileAccess.open(filePath, FileAccess.READ)
	var parsedResult = JSON.parse_string(settingsFile.get_as_text())
	return parsedResult
	
# Called by MenuScript Event, updates Settings.json, emits event that settings changed
func ChangeSettingsConfig(setting, value):
	settingsData[setting] = value
	WriteSettingsToJsonFile(settingsJsonPath, settingsData)
	
	settingsData = LoadJsonFile(settingsJsonPath)
	onUpdatedSettingsJsonFile.emit()

# Updates Json/creates new one if not there
func WriteSettingsToJsonFile(filePath: String, data):
	var settingsFile = FileAccess.open(filePath, FileAccess.WRITE)
	settingsFile.store_line(JSON.stringify(data))
