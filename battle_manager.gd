extends Node

# Store the current game state to return to after battle
var previous_scene_path = ""

var player_position = Vector2.ZERO
var player_skills_name = []
var player_skills_descriptions = []

# Current enemy data
var current_enemy = {}

# Called when entering battle
func enter_battle(enemy_data):
	# Store current scene path
	previous_scene_path = get_tree().current_scene.scene_file_path
	
	# Store player position if player exists
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		player_position = player[0].global_position
		player_skills_name = player[0].skills_name
		player_skills_descriptions = player[0].skills_descriptions

# Return to the game world after battle
func exit_battle(player_won = false):
	# Load previous scene
	get_tree().change_scene_to_file(previous_scene_path)
	
	# Wait for scene to load
	await get_tree().process_frame
	
	# Find player and reset position
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		player[0].global_position = player_position
	
	# Handle battle results
	if player_won:
		# Implement reward system here
		pass
	else:
		# Handle player defeat
		pass
