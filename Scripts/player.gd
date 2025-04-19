extends CharacterBody2D

# Movement parameters - adjust in Inspector
@export var speed: float = 200.0

# Animation and visual references
@export var sprite: Sprite2D
@export var sprite2: Sprite2D
@export var animation_player: AnimationPlayer

var skills_name = ["Kick", "Menace", "Yell", "Iron Sword", "Iron Shield", "Fire Amulet"]
var skills_descriptions = ["The player kicks at a nearby target.", "The player emits a menacing aura.", 
"The player yells out loud.", "A slightly rusty sword. Its dull handle has a habit of cutting its user.", 
"A slightly rusty shield. Its dull handle has a habit of cutting its user.", 
"A fire amulet. When used, it explodes, igniting everything in its vicinity. Use with care!"]

func _physics_process(delta):
	# Get input direction
	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	# Normalize for consistent diagonal movement
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	# Set velocity directly based on input
	velocity = direction * speed
	
	# Handle sprite flipping when moving left
	if direction.x < 0:
		sprite.flip_h = true
		sprite2.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false
		sprite2.flip_h = false
	
	# Handle animations - just walk or stand
	if animation_player:
		if direction != Vector2.ZERO:
			animation_player.play("run")
		else:
			animation_player.play("stand")
	
	# Move the character
	move_and_slide()
