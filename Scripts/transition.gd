extends CanvasLayer

# Fade parameters
@export var fade_duration: float = 0.5
@onready var animation_player = $AnimationPlayer
@onready var overlay = $ColorRect

func _on_viewport_size_changed():
	overlay.size = Vector2(get_viewport().size)

# Fade to black and change the scene
func transition_to_scene(target_scene: String):
	# Fade to black
	fade_in()
	await animation_player.animation_finished
	
	# Change scene
	get_tree().change_scene_to_file(target_scene)

# Fade in from black
func fade_in():
	animation_player.play("fade_in")
