extends RigidBody2D

var battleManager: BattleManager;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D2.visible = false
	$HB/HB.disabled = true
	$HB.body_entered.connect(func (other: Node2D):
		if other.name == "Soul":
			battleManager.damagePlr(randi_range(41,55))
		)
	linear_velocity = Vector2(randi_range(-800, 800),randi_range(-800, 800))
	await get_tree().create_timer(0.5).timeout
	$MusSfxSegapower.play()
	await get_tree().create_timer(0.5).timeout
	$MusSfxSegapower.play()
	await get_tree().create_timer(0.5).timeout
	freeze = true
	$MusSfxSegapower.play()
	await get_tree().create_timer(0.5).timeout
	$MusSfxRainbowbeam1.play()
	$HB/HB.disabled = false
	$Sprite2D2.visible = true
	await get_tree().create_timer(1).timeout
	$Sprite2D2.visible = false
	$HB/HB.disabled = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
