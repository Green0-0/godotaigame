extends CharacterBody2D

# Launch parameters
@export var initial_velocity_x_min = 100
@export var initial_velocity_x_max = 500
@export var initial_velocity_y_min = -2000
@export var initial_velocity_y_max = -1000
@export var lifetime = 5.0  # Time in seconds before deletion
@export var possible_sprites: Array[CompressedTexture2D] = []

# Gravity parameters
var gravity = 1500

# Called when the node enters the scene tree for the first time
func _ready():
	# Set random initial velocity
	var random_x = randf_range(initial_velocity_x_min, initial_velocity_x_max)
	var random_y = randf_range(initial_velocity_y_min, initial_velocity_y_max)
	
	# Randomly decide if the object should go left or right
	if randf() > 0.5:
		random_x = -random_x
		
	velocity = Vector2(random_x, random_y)
	
	# Set a random sprite from the array if there are sprites available
	if possible_sprites.size() > 0:
		var sprite_node = $Sprite2D if has_node("Sprite2D") else Sprite2D.new()
		
		# If the sprite wasn't already a child, add it
		if not has_node("Sprite2D"):
			add_child(sprite_node)
			sprite_node.name = "Sprite2D"
		
		# Set a random texture from the array
		var random_sprite_index = randi() % possible_sprites.size()
		sprite_node.texture = possible_sprites[random_sprite_index]
	
	# Create a timer to delete the object after the specified lifetime
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", _on_lifetime_timeout)
	timer.start()

# Called during the physics processing
func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta
	
	# Move the object
	move_and_slide()

# Called when the lifetime timer expires
func _on_lifetime_timeout():
	queue_free()  # Delete the object
