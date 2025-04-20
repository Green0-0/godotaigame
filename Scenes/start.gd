extends Node2D

@onready var portIn:TextEdit = $portin
@onready var hostin:TextEdit = $hostin

func on_ready():
	BattleManager.player_position = Vector2.ZERO
	BattleManager.player_skills_name = ["Kick", "Menace", "Yell", "Iron Sword", "Iron Shield"]
	BattleManager.player_skills_descriptions = ["The player kicks at a nearby target.", "The player emits a menacing aura.", 
	"The player yells out loud.", "A slightly rusty sword. Its dull handle has a habit of cutting its user.", 
	"A slightly rusty shield. Its dull handle has a habit of cutting its user."]
	BattleManager.current_enemy = {}
	BattleManager.defeated_enemies = []
	BattleManager.host = "localhost"
	BattleManager.port = 32768
	
func _on_button_pressed() -> void:
	BattleManager.host = hostin.text
	if portIn.text.is_valid_int():
		BattleManager.port = int(portIn.text)
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
