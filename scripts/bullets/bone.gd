extends Area2D
class_name RoaringBone

var battleManager: BattleManager;
var soul: Node2D
var dir := Vector2.RIGHT
var speed = Vector2(0,0)
var vel = Vector2(0,0)

func remove() -> void:
	queue_free()

func _ready() -> void:
	if battleManager != null: 
		soul = battleManager.soulNode
	body_shape_entered.connect(func (body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int):
		if body.name == "Soul":
			battleManager.damagePlr(randi_range(10,20))
		)
		
func _process(delta: float) -> void:
	vel += speed
	position += dir * vel
	
