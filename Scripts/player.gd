extends CharacterBody2D

# Movement parameters - adjust in Inspector
@export var speed: float = 200.0

# Animation and visual references
@export var sprite: Sprite2D
@export var sprite2: Sprite2D
@export var animation_player: AnimationPlayer
@export var walk_sfx: AudioStreamPlayer2D



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
			if not walk_sfx.playing:
				walk_sfx.play()
		else:
			animation_player.play("stand")
			walk_sfx.stop()
	
	# Move the character
	move_and_slide()
