extends Node

# Store the current game state to return to after battle
var previous_scene_path = ""

var player_position = Vector2.ZERO
var player_skills_name = ["Kick", "Menace", "Yell", "Iron Sword", "Iron Shield"]
var player_skills_descriptions = ["The player kicks at a nearby target.", "The player emits a menacing aura.", 
"The player yells out loud.", "A slightly rusty sword. Its dull handle has a habit of cutting its user.", 
"A slightly rusty shield. Its dull handle has a habit of cutting its user."]

# Current enemy data
var current_enemy = {}

var defeated_enemies = []

var host = "localhost"
var port = 32768

# Called when entering battle
func enter_battle(enemy_data):
	# Store current scene path
	previous_scene_path = get_tree().current_scene.scene_file_path
	
	# Store player position if player exists
	var player = get_tree().get_nodes_in_group("player")
	player[0].speed = 0
	player_position = player[0].global_position
	var transition = get_tree().get_nodes_in_group("transition")[0]
	transition.call_deferred("transition_to_scene", "res://Scenes/battle.tscn")

# Return to the game world after battle
func exit_battle(player_won = false):
	# Load previous scene
	defeated_enemies.append(current_enemy["id"])
	var transition = get_tree().get_nodes_in_group("transition")[0]
	await transition.transition_to_scene(previous_scene_path)
	
	# Wait for scene to load
	await get_tree().process_frame
	
	# Find player and reset position
	var player = get_tree().get_nodes_in_group("player")
	
	player[0].global_position = player_position
	
	# Handle battle results
	if player_won:
		# Implement reward system here
		pass
	else:
		# Handle player defeat
		pass
