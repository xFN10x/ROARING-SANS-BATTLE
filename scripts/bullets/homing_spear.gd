extends AnimatedSprite2D
class_name HomingSpear

var battleManager: BattleManager;
var soul
var moving := false
var target: Vector2 = Vector2(300, 480/2)

func remove() -> void:
	queue_free()

func _ready() -> void:
	$Area.body_entered.connect(func (other: Node2D):
		if other.name == "Soul":
			battleManager.damagePlr(randi_range(15,25))
		)
		
	$Beam.body_entered.connect(func (other: Node2D):
		if other.name == "Soul":
			battleManager.damagePlr(randi_range(15,25))
		)
	$Lazer.global_scale = Vector2(10000000, 1)
	$Beam/CollisionShape2D.disabled = true
	if battleManager != null:
		soul = battleManager.soulNode
		target = Vector2(soul.global_position.x + randi_range(-20,20), soul.global_position.y + randi_range(-20,20))
		rotation = position.angle_to_point(target) + deg_to_rad(90)
	else:
		position = Vector2(640/2, 480/2)
	$Animations.play("spawn")
	await $Animations.animation_finished
	await get_tree().create_timer(1).timeout
	self.animation = "new_animation"
	self.play()
	$Lazer.visible = false
	$Beam.visible = true
	$SndArrow.play()
	$Beam/CollisionShape2D.disabled = false
	
	var tween = get_tree().create_tween()
	tween.tween_property($Beam/BeamSpr1, "self_modulate", Color.TRANSPARENT, .3)
	tween.tween_property($Beam/BeamSpr2, "self_modulate", Color.TRANSPARENT, .3)
	tween.tween_property($Beam/BeamSpr3, "self_modulate", Color.TRANSPARENT, .3)
	tween.play()
	moving = true
	await get_tree().create_timer(.15).timeout
	$Beam/CollisionShape2D.disabled = true
	
var vel = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moving:
		position = position.move_toward(target, -vel)
		vel += 2
