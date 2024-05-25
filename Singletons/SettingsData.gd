extends Node

var sensitivity: float
var settingsJsonPath: String = "res://Config/Settings.json"
var settingsFile
var settingsData = {}

signal onUpdatedSettingsJsonFile()

func _ready():
	settingsData = LoadJsonFile(settingsJsonPath)


func LoadJsonFile(filePath: String):
	if not FileAccess.file_exists(filePath):
		print("file doesnt exits")
	
	settingsFile = FileAccess.open(filePath, FileAccess.READ)
	var parsedResult = JSON.parse_string(settingsFile.get_as_text())
	return parsedResult
	
func ChangeSettingsConfig(setting, value):
	settingsData[setting] = value
	WriteSettingsToJsonFile(settingsJsonPath, settingsData)
	
	settingsData = LoadJsonFile(settingsJsonPath)
	onUpdatedSettingsJsonFile.emit()

func WriteSettingsToJsonFile(filePath: String, data):
	var settingsFile = FileAccess.open(filePath, FileAccess.WRITE)
	settingsFile.store_line(JSON.stringify(data))
	
