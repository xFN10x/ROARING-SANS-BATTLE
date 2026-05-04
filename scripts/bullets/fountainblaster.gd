extends AnimatedSprite2D
class_name FountainBlaster

var battleManager: BattleManager;
var soul
var moving := false
var target = null

func remove() -> void:
	queue_free()

func _ready() -> void:
	$Beam.visible = false
	$Beam.body_entered.connect(func (other: Node2D):
		if other.name == "Soul":
			battleManager.damagePlr(999999)
		)
	$Lazer.global_scale = Vector2(10000000, 1)
	$Beam/CollisionShape2D.disabled = true
	if battleManager != null:
		soul = battleManager.soulNode
		if target == null:
			target = Vector2(soul.global_position.x + randi_range(-20,20), soul.global_position.y + randi_range(-20,20))
	else:
		position = Vector2(640/2, 480/2)
		target = Vector2(0, position.y)
	rotation = position.angle_to_point(target) + deg_to_rad(90)
	$Animations.play("spawn")
	await $Animations.animation_finished
	$Lazer.visible = false
	for i in range(8):
		$FountainPartcle.emitting = false
		$FountainPartcle.emitting = true
		$SndFountainTarget.play()
		await get_tree().create_timer(0.07).timeout
	play("default")
	$Beam.visible = true
	$Beam/begin.play("default")
	await get_tree().create_timer(1.15).timeout
	self.play("new_animation")
	$Beam/CollisionShape2D.disabled = false
	$SndFountainMake.play()
	$SndArrow.play()
	$Beam/begin.visible = false
	$Beam/loop.visible = true
	$Beam/loop.play("default")
	$Beam/loop/loop2.play("default")
	$Beam/loop/loop2/loop3.play("default")
	$Beam/loop/loop2/loop3/loop4.play("default")
	$Beam/loop/loop2/loop3/loop4/loop5.play("default")
	$Beam/loop/loop2/loop3/loop4/loop5/loop6.play("default")
	await get_tree().create_timer(7).timeout
	$Beam/CollisionShape2D.disabled = true
	$BlackMain.emitting = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 2)
	tween.play()

var vel = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moving:
		position = position.move_toward(target, -vel)
		vel += 2
