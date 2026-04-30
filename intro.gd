extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size = Vector2i(1920, 1080)
	$VideoStreamPlayer.finished.connect(func ():
		get_tree().change_scene_to_file("res://scenes/battle.tscn"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select") :
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
