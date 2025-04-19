extends CharacterBody2D

@export var enemy_name: String = "Filler_Enemy"
@export var enemy_description: String = "Filler_Description"
var image: CompressedTexture2D

var can_initiate_battle = true

func _ready():
	# Set up collision detection
	$Area2D.connect("body_entered", _on_body_entered)
	image = $Sprite2D.texture

func _on_body_entered(body):
	if body.is_in_group("player") and can_initiate_battle:
		can_initiate_battle = false
		# Use call_deferred to safely initiate battle outside the physics callback
		call_deferred("initiate_battle")

func initiate_battle():
	# Store enemy data in the BattleManager autoload
	BattleManager.current_enemy = {
		"name": enemy_name,
		"description": enemy_description,
		"image": image,
	}
	# Call the enter_battle method in BattleManager
	BattleManager.enter_battle(BattleManager.current_enemy)
	# Use call_deferred for changing scenes
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/battle.tscn")
