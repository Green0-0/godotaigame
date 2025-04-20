extends CharacterBody2D

@export var enemy_name: String = "Filler_Enemy"
@export var enemy_description: String = "Filler_Description"
var image: CompressedTexture2D

@export var enemy_id: String = ""

var can_initiate_battle = true

func _ready():
	# Set up collision detection
	$Area2D.connect("body_entered", _on_body_entered)
	image = $Sprite2D.texture
	if enemy_id in BattleManager.defeated_enemies:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") and can_initiate_battle and enemy_id not in BattleManager.defeated_enemies:
		can_initiate_battle = false
		# Use call_deferred to safely initiate battle outside the physics callback
		call_deferred("initiate_battle")

func initiate_battle():
	# Store enemy data in the BattleManager autoload
	BattleManager.current_enemy = {
		"name": enemy_name,
		"description": enemy_description,
		"image": image,
		"id": enemy_id
	}
	# Call the enter_battle method in BattleManager
	BattleManager.enter_battle(BattleManager.current_enemy)
