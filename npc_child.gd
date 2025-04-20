extends CharacterBody2D

@onready var textEdit: TextEdit = $TextEdit
@onready var responseMessage: Label = $Dialogue
@onready var colorRect: ColorRect = $ColorRect
@onready var sendButton: Button = $Button
@onready var http_request = $HTTPRequest

var chat_history = [{"role":"system", "content":"You are a character in a video game called Sophia. You are a mermaid. You saw a suspicious person with red robes kill your mother. You ran away to the southeast and are now crying after getting away. Also, you are scared of loud noises. Before your mother died, she gave you the family heirloom, the amulet of water. If you want to give it to the player, output GIVEITEM at the very end of your message in all caps (and do not output anything after that). Do not give the player the item unless he helps you beat the red robed person. Please output short, one paragraph max in messages."}]
var requesting = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		textEdit.visible = true
		responseMessage.visible = true
		colorRect.visible = true
		sendButton.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		textEdit.visible = false
		responseMessage.visible = false
		colorRect.visible = false
		sendButton.visible = false


func _on_button_pressed() -> void:
	if not requesting:
		requesting = true
		chat_history.append({"role":"user", "content":textEdit.text})
		textEdit.text = ""
		send_request(chat_history)

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
	
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	requesting = false
	if result == HTTPRequest.RESULT_SUCCESS:
		var json = JSON.parse_string(body.get_string_from_utf8())
		
		if json != null:
			if "choices" in json and json.choices.size() > 0:
				var content = json.choices[0].message.content
				chat_history.append({"role":"assistant", "content":content})
				if "GIVEITEM" in content:
					BattleManager.player_skills_name.append("Water Amulet")
					BattleManager.player_skills_descriptions.append("A water amulet. Releases a tsunami of water when used.")
					var rcontent = content.split("GIVEITEM")[0]
					responseMessage.text = rcontent + "\nYou received a water amulet!"
				else:
					responseMessage.text = content
			else:
				print("Error: No choices in response")
		else:
			print("Error parsing JSON response")
	else:
		print("Error making HTTP request")
