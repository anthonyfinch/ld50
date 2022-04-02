extends ColorRect


onready var version_label = $VBoxContainer/VersionLabel

var _version = 3

func _ready():
	version_label.text = "VERSION: %s" % _version
