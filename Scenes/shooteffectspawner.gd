extends Node2D

# The scene to spawn
@export var object_scene: PackedScene
# Spawn position parameters
@export var spawn_y_position = 800
@export var spawn_x_min = -100
@export var spawn_x_max = 1300
# Spawn timing parameters
@export var spawn_time_min = 0.05
@export var spawn_time_max = 0.2
@export var max_objects = 80  # Maximum number of objects to spawn at once
# Whether spawning is active
@export var is_spawning = true

# Timer for spawning
var spawn_timer: Timer
# Count of currently active objects
var active_objects = 0

func _ready():
	# Set up the spawn timer
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.one_shot = true
	spawn_timer.connect("timeout", _on_spawn_timer_timeout)
	
	# Start the first spawn
	_set_next_spawn_time()

func _on_spawn_timer_timeout():
	if is_spawning and active_objects < max_objects:
		spawn_object()
	
	# Set the timer for the next spawn
	_set_next_spawn_time()

func _set_next_spawn_time():
	# Only start the timer if spawning is active
	if is_spawning:
		spawn_timer.wait_time = randf_range(spawn_time_min, spawn_time_max)
		spawn_timer.start()

func spawn_object():
	# Instance the object scene
	var object = object_scene.instantiate()
	
	# Set its position
	var spawn_x = randf_range(spawn_x_min, spawn_x_max)
	object.position = Vector2(spawn_x, spawn_y_position)
	
	# Connect to its tree_exiting signal to track when it's removed
	object.connect("tree_exiting", _on_object_tree_exiting)
	
	# Add it to the scene
	add_child(object)
	active_objects += 1

func _on_object_tree_exiting():
	active_objects -= 1

# Public methods to control spawning
func start_spawning():
	is_spawning = true
	if not spawn_timer.is_stopped():
		_set_next_spawn_time()

func stop_spawning():
	is_spawning = false
	spawn_timer.stop()
