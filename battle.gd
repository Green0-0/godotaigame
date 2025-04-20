extends Node2D

# UI References
@onready var enemy_sprite = $Enemy
@onready var label = $RichTextLabel
@onready var player_hp_bar = $PlayerHP
@onready var enemy_hp_bar = $EnemyHP
@onready var http_request = $HTTPRequest
@onready var hit_sound = $AudioStreamPlayer2D
@onready var shaker = $Camera2D
@onready var enemyshaker = $Enemy/AnimationPlayer
@onready var enemyparticles = $CPUParticles2D

# Battle state
var enemy_data = {}
var battle_active = true
var enemy_response = "Loading..."
var ui_state = "start_text"
var player_turn = true
var requesting = false
var cachedID = 0
var cache_enemy_response = ""

var player_hp = 100
var enemy_hp = 100

func _ready():
	# Get enemy data from BattleManager
	enemy_data = BattleManager.current_enemy
	
	if !http_request.is_connected("request_completed", Callable(self, "_on_request_completed")):
		http_request.connect("request_completed", Callable(self, "_on_request_completed"))
		
	# Set up the battle scene with enemy data
	setup_battle()

func setup_battle():
	# Set enemy sprite
	if enemy_data.has("image") and enemy_data.image != null:
		enemy_sprite.texture = enemy_data.image
	
	enemy_hp_bar.max_value = 100
	enemy_hp_bar.value = 100
	
	player_hp_bar.max_value = 100
	player_hp_bar.value = 100
	player_turn = true
		
	send_request([{"role": "user", "content": """You are a writer for a game character known as the %s. Here is the description for the game character:
		%s
		The character has just entered combat with the player. Write an opening statement for the player, something like: 
		*The character_name laughs*
		You dare challenge me?
		*It raises its shield and sword*
		Do not output anything besides the game character's respones.
		""" % [enemy_data.name, enemy_data.description]}])
		
func _process(delta):
	if not requesting:
		if ui_state == "player_dead":
			if Input.is_action_just_pressed("ui_accept"):
				lose_battle()
		if ui_state == "enemy_dead":
			if Input.is_action_just_pressed("ui_accept"):
				win_battle()
		if Input.is_action_just_pressed("ui_accept"):
			if ui_state == "start_text":
				ui_state = "tease_actions"
				var text_parts = []
				for x in range(0, len(BattleManager.player_skills_name)):
					text_parts += ["[%s] %s: %s" % [str(x), BattleManager.player_skills_name[x], BattleManager.player_skills_descriptions[x]]]
				label.text = """What will you do?\n""" + "\n".join(text_parts) + "\nPress the number [1-9] correlated with the skill you want to use."
			elif ui_state == "tease_actions":
				label.text = enemy_response + "\n[Press Enter to Act]"
				ui_state = "start_text"
		if ui_state == "tease_actions":
			for i in range(0, 9):  # Numbers 1 through 9
				if i >= BattleManager.player_skills_name.size():
					break
				if Input.is_action_just_pressed("p" + str(i)):
					if player_turn:
						cachedID = i
						player_turn_act()
						break
					else:
						cachedID = i
						enemy_turn_act()
						break
		if ui_state == "player_turn_attack":
			if Input.is_action_just_pressed("ui_accept"):
				if player_hp <= 0:
					ui_state = "player_dead"
					label.text = "You died...\n[Press enter to continue]"
				elif enemy_hp <= 0:
					ui_state = "enemy_dead"
					label.text = "You won!\n[Press enter to continue]"
				else:
					enemy_prepare_attack()
		elif ui_state == "enemy_turn_attack":
			if Input.is_action_just_pressed("ui_accept"):
				if player_hp <= 0:
					ui_state = "player_dead"
					label.text = "You died...\n[Press enter to continue]"
				elif enemy_hp <= 0:
					ui_state = "enemy_dead"
					label.text = "You won!\n[Press enter to continue]"
				else:
					enemy_prepare_defense()

# Call this when player wins the battle
func win_battle():
	battle_active = false
	
	# Return to game scene with victory status
	BattleManager.exit_battle(true)

# Call this when player loses the battle
func lose_battle():
	battle_active = false
	
	# Return to game scene with defeat status
	get_tree().change_scene_to_file("res://Scenes/start.tscn")

# Example function for player attack action
# You'll implement the actual battle mechanics
func player_turn_act():
	ui_state = "player_turn_attack"
	send_request([{"role": "user", "content": """You are a writer for an RPG game. 
The player is using the skill %s with a description "%s" to attack an enemy named %s. 
%s's description is:
%s
Write a narrative response, and output a python script using the following functions:
damage_player(amount: int) # Damage the player by the amount, representing an int as a percent of the player's health from 0-100
damage_enemy(amount: int) # Damage the enemy by the amount, representing an int as a percent of the enemies health from 0-100
For example:
You dive in and parry enemy_name's axe with a sharp twist of your blade, before driving your sword up in a brutal arc, splitting the attacker's jaw with a sickening crack. The axeman screams.
```python
damage_enemy(50)
```
Only output a second person response for the player, and the tool calls (make sure the tool calls accurately represent what happens in the interaction, and the correct player/enemy gets damaged if described as such, do not damage characters who were not described as hurt).The narration should accurately characterize the result of the interaction, if the player responds in a dumb way they might die (take 100 damage), or if they respond in a smart way the enemy could take 100 damage and get killed. It should also be violent and action packed, detailing exactly what happens 1-2 sentences max. Do not output anything after the python tool calls."""% [BattleManager.player_skills_name[cachedID], BattleManager.player_skills_descriptions[cachedID], enemy_data.name, enemy_data.name, enemy_data.description,  ]}])
func enemy_turn_act():
	ui_state = "enemy_turn_attack"
	cache_enemy_response = enemy_response
	send_request([{"role": "user", "content": """You are a writer for an RPG game. 
The player is being attacked by an enemy called %s with description:
%s
The enemies attack was preparing the attack, their last response was:
%s
In response, the player is using the skill %s with description "%s"
Write a narrative response, and output a python script using the following functions:
damage_player(amount: int) # Damage the player by the amount, representing an int as a percent of the player's health from 0-100
damage_enemy(amount: int) # Damage the enemy by the amount, representing an int as a percent of the enemies health from 0-100
For example:
*Your blade clashes against the axe's rusted edge in a shower of sparks, but enemy_name twists the haft, wrenching the sword aside before burying the axehead deep into your shoulder with a wet crunch.*
Still alive? Let's fix that!
```python
damage_player(50)
```
Only output a second person response for the player, and the tool calls (make sure the tool calls accurately represent what happens in the interaction, and the correct player/enemy gets damaged if described as such, do not damage characters who were not described as hurt). The narration should accurately characterize the result of the interaction, if the player responds in a dumb way they might die (take 100 damage), or if they respond in a smart way the enemy could take 100 damage and get killed. It should also be violent and action packed, detailing exactly what happens 1-2 sentences max. Do not output anything after the python tool calls."""% [enemy_data.name, enemy_data.description, enemy_response, BattleManager.player_skills_name[cachedID], BattleManager.player_skills_descriptions[cachedID]]}])
	
func enemy_prepare_defense():
	ui_state = "start_text"
	player_turn = true
	send_request([{"role": "user", "content": """You are a writer for an RPG game. 
The player is being attacked by an enemy called %s with description:
%s
The enemies attack was preparing the attack, their last response was:
%s
In response, the player is using the skill %s with description "%s"
Write a narrative response.
For example:
*Your blade clashes against the axe's rusted edge in a shower of sparks, but enemy_name twists the haft, wrenching the sword aside before burying the axehead deep into your shoulder with a wet crunch.*
Still alive? Let's fix that!
Only output a second person response for the player. The narration should accurately characterize the result of the interaction, if the player responds in a dumb way they might die (take 100 damage), or if they respond in a smart way the enemy could take 100 damage and get killed. It should also be violent and action packed, detailing exactly what happens 1-2 sentences max.
	"""% [enemy_data.name, enemy_data.description, cache_enemy_response, BattleManager.player_skills_name[cachedID], BattleManager.player_skills_descriptions[cachedID]]},
	{"role": "assistant", "content":enemy_response}, {"role":"user", "content":"Now, it's the player's turn to attack the character. Write the character preparing to receive a player attack, but do not write the player attacking, as the user inputs for the player. The enemy should do something like taunt the player, challenge them, etc. Output one or two sentences of narration or dialogue.
	"}])
	
func enemy_prepare_attack():
	ui_state = "start_text"
	player_turn = false
	send_request([{"role": "user", "content": """You are a writer for an RPG game. 
The player is using the skill %s with a description "%s" to attack an enemy named %s. 
%s's description is:
%s
Write a narrative response
Only output a second person response for the player. The narration should accurately characterize the result of the interaction, if the player responds in a dumb way they might die (take 100 damage), or if they respond in a smart way the enemy could take 100 damage and get killed. It should also be violent and action packed, detailing exactly what happens 1-2 sentences max.
	"""% [BattleManager.player_skills_name[cachedID], BattleManager.player_skills_descriptions[cachedID],  enemy_data.name, enemy_data.name, enemy_data.description]}, 
	{"role": "assistant", "content":enemy_response}, {"role":"user", "content":"Now, it's the character's turn to attack the player. Write the character preparing their attack, but do not write the character attacking, that is, the player needs to also describe their response before the enemy attacks. Output only one or two sentences of narration or dialogue.
	"}])

func damage_player(amount):
	player_hp -= amount
	player_hp_bar.value = player_hp
	
func damage_enemy(amount):
	enemy_hp -= amount
	enemy_hp_bar.value = enemy_hp

func parse_tool_calls(python_string: String) -> void:
	# Split the string into lines
	var lines = python_string.split("\n")
	# Regular expressions to match our tool calls
	var damage_player_regex = RegEx.new()
	damage_player_regex.compile("damage_player\\((\\d+)\\)")
	var damage_enemy_regex = RegEx.new()
	damage_enemy_regex.compile("damage_enemy\\((\\d+)\\)")
	# Process each line
	var damaged_enemy = false
	var damaged_player = false
	for line in lines:
		# Skip empty lines and comments
		if line.strip_edges() == "" or line.strip_edges().begins_with("#"):
			continue
		# Check for damage_player calls
		var player_match = damage_player_regex.search(line)
		if player_match:
			var amount = int(player_match.get_string(1))
			damage_player(amount)
			damaged_player = true
			continue
		# Check for damage_enemy calls
		var enemy_match = damage_enemy_regex.search(line)
		if enemy_match:
			var amount = int(enemy_match.get_string(1))
			damage_enemy(amount)
			damaged_enemy=true
			continue
	if damaged_player or damaged_enemy:
		hit_sound.play()
	if damaged_player:
		shaker.apply_shake()
	if damaged_enemy:
		enemyparticles.emitting = true
		enemyshaker.play("shake")

func send_request(input):
	requesting = true
	# Set up the request
	var url = "http://%s:%s/v1/openai/v1/chat/completions" % [BattleManager.host, BattleManager.port]
	var payload = {
		"model": "meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8",
		"messages": input,
		"temperature": 1.5,
		"min_p": 0.15,
		"stream": false
	}
	# Convert payload to JSON string
	var json_payload = JSON.stringify(payload)
	# Set headers
	var headers = PackedStringArray(["Content-Type: application/json"])
	# Make the request
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_payload)

# Handle the response
func _on_request_completed(result, response_code, headers, body):
	requesting = false
	if result == HTTPRequest.RESULT_SUCCESS:
		var json = JSON.parse_string(body.get_string_from_utf8())
		
		if json != null:
			if "choices" in json and json.choices.size() > 0:
				var content = json.choices[0].message.content
				if ui_state == "start_text":
					label.text = content + "\n[Press Enter to Act]"
					enemy_response = content
				elif ui_state == "player_turn_attack":
					content = content.split("```python")
					enemy_response = content[0]
					var python_call = content[1].split("```")[0]
					label.text = enemy_response + "\n[Press Enter to Continue]"
					parse_tool_calls(python_call)
				elif ui_state == "enemy_turn_attack":
					content = content.split("```python")
					enemy_response = content[0]
					var python_call = content[1].split("```")[0]
					label.text = enemy_response + "\n[Press Enter to Continue]"
					parse_tool_calls(python_call)
			else:
				print("Error: No choices in response")
		else:
			print("Error parsing JSON response")
	else:
		print("Error making HTTP request")
