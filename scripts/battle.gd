extends Node2D
class_name BattleManager
class Item :
	var Health: int
	var Name: String
	var dio: String
	var SName: String
	var onEat: Callable
	
	func eaten():
		onEat.call()
		
	func none():
		pass
	
	func _to_string() -> String:
		return SName
	
	func _init(Health, Name, ShortName, Dio = "You ate the "+ Name, onEat := Callable.create(self, "none")) -> void:
		self.Health = Health
		self.Name = Name
		self.SName = ShortName
		self.onEat = onEat;
		self.dio = Dio;
enum MenuMode {
	OPTION_MODE,
	NO_MODE,
	ITEM,
	ENEMY_TURN,
	ATTACK,
}

class DialougeEntry:
	pass

static var paused: bool = false

var sine := sin(Time.get_ticks_msec() * 1000.0)
var ArrowBullet = preload("res://scripts/bullets/Arrow.gd")

var totalDamageTaken := 0
var totalDamageHealed := 0

var tp: int = 0;

var selectedVOffset := 47
var fightVOffset := 111
var actVOffset := 9
var itemVOffset := 212
var mercyVOffset := 313

var soulY := 453
var fightXSoul := 48
var actXSoul := 201
var itemXSoul := 361
var mercyXSoul := 516

var enemyName := "ROARING SANS"

var optionPoses: Array[Variant] = [
	Vector2(72.0, 286.0), Vector2(312, 286.0),
	Vector2(72.0, 318.0), Vector2(312, 318.0)
]
var lastOption := 0

var fightNode: Sprite2D
var actNode: Sprite2D
var itemNode: Sprite2D
var mercyNode: Sprite2D

var selectedButton := 0;

var soulNode: CharacterBody2D
var soulTexNode: Sprite2D

var musicNode: AudioStreamPlayer
var menuMoveNode: AudioStreamPlayer
var menuSelectNode: AudioStreamPlayer
var textSndNode: AudioStreamPlayer

var hp := 99
var maxHp := 99
var hpBarNode: ProgressBar
var hpTextNode: Label

var boxNode: MarginContainer
# Box Positions Vec4(x,y, width, height)
var defaultPos := Vector4(32, 250, 575, 140)
var spearAtkPos := Vector4(277.5, 201.5, 85, 81)
var turn1box := Vector4(32, 130.0, 575, 259.0)
var turn4box := Vector4(215.0, 215.0, 210.0, 174.0)

var page := 0

var defending = false


var menuOptions := []
	
var food: Array[Item] = [
	Item.new(90, "Snail Pie",  "Sn. Pie"),
	Item.new(999, "Deluxe Buffet",  "D. Buffet"),
	Item.new(40, "Dess Cookie",  "Ds. Cookie", "* You ate one of Dess' Cookie... your defense was increased for 2 turns!", func():
		defns += 0.5
		$SndBoost.play()),
	Item.new(40, "Dess Cookie",  "Ds. Cookie", "* You ate one of Dess' Cookie... your defense was increased for 2 turns!", func():
		defns += 0.5
		$SndBoost.play()),
	
	Item.new(60, "Susie's Heart",  "S. Heart", "* You ate Susie's heart... Kris' attack increased!", func():
		attk += 0.3
		$SndBoost.play()),
	Item.new(60, "Susie's Liver",  "S. Liver", "* You ate Susie's liver... Kris' attack increased!", func():
		attk += 0.3
		$SndBoost.play()),
	Item.new(10, "Susie's Teeth",  "S. Teeth", "* You ate Susie's Teeth...  how are you supposed to eat these things?"),
	Item.new(50, "Susie Piece",  "S. Piece", "* You ate part of Susie... Kris' attack increased!", func():
		attk += 0.3
		$SndBoost.play()),
]
var menuMode := MenuMode.OPTION_MODE
var textNode: Label
var option0Node: Label
var option1Node: Label
var option2Node: Label
var option3Node: Label

var defns := 1
var attk := 1

var defaultText := "* It's Sans."
var texts: Array[String] = [
	"* You feel... Sans crawling on your back...",
	"* Lince is in pain.",
	"* You looked for your body but you couldn't find it.",
	"* The entire omniverse is at stake",
	"* Why is there TP?",
	"* Susie is fucking dead.",
	"* Huh",
	"* The titan's fled.",
	"* Its over.",
	"* Ø",
	"* Skibidi Lince is Calling",
	"* Bibidi Bince is Screaming",
	"* OMG THE KNIGHT TOOK THEIR HELMET OFF AND ITS PAPURAUS!!",
]
var currentText := defaultText
var currentTextI := 0

var sansText: Array[String] = [
	"You’re Attacks are pit full.",
	"You will not win this batel. Is it unwinable",
	"YOUR FEIND IS DEAD. YOU CANNOT DO THIS ALONE.",
	"The roaring has already, begun There is nothing you can do to stop it",
	"I will kill everyone and kill them again","Kris i hate you",
	"Are you evnen listening to me?", # loop
	"...",
	".......",
	"............?",
	"I’AM GETTING ANGRYER",
	"Why wont’nt you not die",
	"DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE DIE ",
	"DIE DIE DIE NOW",
	"PLEASE",
	"I AM BEGGING JUST DIE",
	"YOU WILL BE KILLED BY ME AND IT WILL IT WILL YOU WILL DIE",
	"MY ROARING BLASTERS WILL INCINERTAE YOU NOW!",
	"MY ROARING BONES WILL STAB YOU TO DEATH",
	"PLEASE",
	"DIE",
	"Plllllaase die now istnalntly",
	"DIE DIE DEID EID EIDE DEID EIED EID EID EID EID DIE DIE DIE DIE DIED EI",
	"DIE DIE DIE DIE DIE DIE DIE",
]
var textLoc := 0
var currentdia := 0

var currentAttack := 0

var actualNoMode := false 

enum SoulMode {
	GREEN,
	RED,
}
var soulMode := SoulMode.RED
var redSoulTexture := CompressedTexture2D.new()
var redSoulTextureHurt := CompressedTexture2D.new()
var redSoulSplit := CompressedTexture2D.new()
var greenSoulTexture := CompressedTexture2D.new()
var greenSoulTextureHurt := CompressedTexture2D.new()
var greenSoulPartsNode: Node2D
var greenSoulShield: Line2D
var greenSoulPos := Vector2(320, 242)
var greenSoulProtectUp: Tween
var greenSoulProtectDown: Tween
var greenSoulProtectLeft: Tween
var greenSoulProtectRight: Tween
var greenSoulRotate = deg_to_rad(90)

var checkText: String = """* ROARING SANS - ATK -∞ DEF -∞
* He was a shopkeeper, now he's
	this.
"""

var enemyMaxHealth := 99999999
var enemyHealth := enemyMaxHealth
var enemyHealthBar: ProgressBar

var attackIndicBar: AnimatedSprite2D
var attackTargetAnimation: AnimationPlayer
@onready var attackIndicAnimations = $Box/Box/AttackIndic/FadeOutAni
var moveIndic := true

var knifeAnimationNode: AnimatedSprite2D
var knifeSound: AudioStreamPlayer
var enemyHitSound: AudioStreamPlayer

var Bullets: Node

var arrowUpPos:  Vector2
var arrowLeftPos: Vector2
var arrowRightPos: Vector2
var arrowDownPos: Vector2

var canAttack := true

var maxIFrames := 20
var iframes := 0
var godmode := false

@onready var grazeSprite: Sprite2D = $Soul/GrazeArea/Tex
@onready var grazeHitbox: Area2D = $Soul/GrazeArea
@onready var grazeSnd:  = $SndGraze

var groundSpearPoses: Array[Vector2] = [
	Vector2(299, 345),
	Vector2(321, 345),
	Vector2(344, 345),
]

var totalTurns := 0
var turn := 0
var mainSoulMode

func setBoxHitBox(size: Vector2) -> void:
	var array := PackedVector2Array()
	var first := Vector2(5, 5)
	var second  := Vector2(size.x - 5, 5)
	var third := Vector2(size.x - 5, size.y - 5)
	var fourth := Vector2(5, size.y - 5)
	array.append(first)
	array.append(second)
	array.append(third)
	array.append(fourth)
	$Box/Box/Body/Shape.polygon = array

func setBoxPosInsta(trans: Vector4) -> void:
	setBoxHitBox(Vector2(trans.z, trans.w))
	boxNode.position = Vector2(trans.x, trans.y)
	boxNode.size = Vector2(trans.z, trans.w)

func setBoxPos(trans: Vector4) -> Signal:
	setBoxHitBox(Vector2(trans.z, trans.w))
	var tweenMoveX := get_tree().create_tween()
	tweenMoveX.tween_property(boxNode, "position", Vector2(trans.x, boxNode.position.y), 0.5).set_trans(Tween.TRANS_LINEAR)
	var tweenSizeX := get_tree().create_tween()
	tweenSizeX.tween_property(boxNode, "size", Vector2(trans.z, boxNode.size.y), 0.5).set_trans(Tween.TRANS_LINEAR)
	
	if trans.z != boxNode.size.x:
		tweenSizeX.play()
	if trans.x != boxNode.position.x:
		tweenMoveX.play()
		
	if tweenMoveX.is_running():
		await tweenMoveX.finished
	if tweenSizeX.is_running():
		await tweenSizeX.finished
		
	var tweenMoveY := get_tree().create_tween()
	tweenMoveY.tween_property(boxNode, "position", Vector2(boxNode.position.x, trans.y), 0.1).set_trans(Tween.TRANS_LINEAR)
	var tweenSizeY := get_tree().create_tween()
	tweenSizeY.tween_property(boxNode, "size", Vector2(boxNode.size.x, trans.w), 0.1).set_trans(Tween.TRANS_LINEAR)
	if trans.w != boxNode.size.y:
		tweenSizeY.play()
	if trans.y != boxNode.position.y:
		tweenMoveY.play()
	if tweenSizeY.is_running():
		await tweenSizeY.finished
	return tweenMoveY.finished
	
func death() -> void:
	paused = true
	AudioServer.set_bus_mute(1, true)
	$BlackOut.visible = true
	$Soul/GreenSoul.visible = false
	soulTexNode.texture = redSoulTexture
	await get_tree().create_timer(0.6).timeout
	soulTexNode.texture = redSoulSplit
	$SndBreak1.play()
	await get_tree().create_timer(1).timeout
	soulTexNode.texture = null
	$SndBreak2.play()
	$Soul/CPUParticles2D.emitting = true
	await get_tree().create_timer(2).timeout
	$GlobalAnimations.play("death")
	
func canNavTo(optionArray: Array, selected: int) -> bool:
	return selected >= 0 && selected + (page * 4) < optionArray.size()

func showText(text: String, target := 0) -> void:
	currentText = text
	textLoc = target
	currentTextI = 0

func selectOption() -> void:
	menuMode = MenuMode.OPTION_MODE

func restart() -> void:
	get_tree().reload_current_scene()
	_ready()
	Arrow.CurrentArrows = {}
	paused = false
	AudioServer.set_bus_mute(1, false)

func spawnHomingArrow(sca: Vector2 = Vector2(1,1), pos := Vector2(randi_range(0,640), randi_range(0,480)), target := Vector2(soulNode.global_position.x + randi_range(-20,20), soulNode.global_position.y + randi_range(-20,20))):
	var bullet: HomingSpear = preload("res://scripts/bullets/homing_spear.tscn").instantiate()
	bullet.battleManager = self
	bullet.position = pos
	bullet.scale = sca
	bullet.target = target
	Bullets.add_child(bullet)
	
func spawnFountainBlaset(sca: Vector2 = Vector2(1,1), pos := Vector2(randi_range(0,640), randi_range(0,480)), target := Vector2(soulNode.global_position.x + randi_range(-20,20), soulNode.global_position.y + randi_range(-20,20))):
	var bullet: FountainBlaster = preload("res://scripts/bullets/fountainblaster.tscn").instantiate()
	bullet.battleManager = self
	bullet.position = pos
	bullet.scale = sca
	bullet.target = target
	Bullets.add_child(bullet)
	
func spawnBone(scale: Vector2, pos : Vector2, speed := Vector2.LEFT):
	var bullet: RoaringBone = preload("res://scripts/bullets/bone.tscn").instantiate()
	bullet.battleManager = self
	bullet.position = pos
	bullet.speed = speed
	bullet.scale = scale
	Bullets.add_child(bullet)
	
func spawnShooterSpears():
	var bullet: ShootingSpearSpawner = preload("res://scripts/bullets/shooting_spear_spawner.tscn").instantiate()
	bullet.battleManager = self
	bullet.position = soulNode.position
	Bullets.add_child(bullet)
	
func spawn6Spears():
	var bullet: SixSpear = preload("res://scripts/bullets/6spear.tscn").instantiate()
	bullet.battleManager = self
	bullet.position = soulNode.position
	Bullets.add_child(bullet)
	
func spawn8Spears():
	var bullet: SixSpear = preload("res://scripts/bullets/6spear.tscn").instantiate()
	bullet.battleManager = self
	bullet.spears = 8
	bullet.position = soulNode.position
	Bullets.add_child(bullet)

func spawnYellowArrow(speed: int, direction):
	var bullet: YellowArrow = preload("res://scripts/bullets/yellow_bullet.tscn").instantiate()
	bullet.speed = speed
	bullet.battleManager = self
	bullet.currentDirection = direction
	match direction:
		ArrowBullet.Direction.UP:
			bullet.position = arrowDownPos
		ArrowBullet.Direction.DOWN:
			bullet.position = arrowUpPos
		ArrowBullet.Direction.RIGHT:
			bullet.position = arrowRightPos
		ArrowBullet.Direction.LEFT:
			bullet.position = arrowLeftPos
	Bullets.add_child(bullet)

func spawnArrow(speed: int, direction):
	var bullet: Arrow = preload("res://scripts/bullets/bullet.tscn").instantiate()
	bullet.speed = speed
	bullet.battleManager = self
	bullet.currentDirection = direction
	match direction:
		ArrowBullet.Direction.UP:
			bullet.position = arrowDownPos
		ArrowBullet.Direction.DOWN:
			bullet.position = arrowUpPos
		ArrowBullet.Direction.RIGHT:
			bullet.position = arrowRightPos
		ArrowBullet.Direction.LEFT:
			bullet.position = arrowLeftPos
	Bullets.add_child(bullet)

func heal(number: int) -> void:
	var fakeHealth := hp + number
	var setHealth: int = min(fakeHealth, maxHp)
	totalDamageHealed += setHealth - hp
	hp = setHealth

func damagePlr(number: int) -> void:
	if  iframes > 0: return
	iframes = maxIFrames
	if (hp - number) <= 0:
		iframes = 200000
		death();
		return
	totalDamageTaken += number
	number /= defns
	if defending:
		number /= 2 
	if not godmode:
		hp -= number
	$SndHurt1.play()
	$Soul/GreenSoul.visible = false

func _ready() -> void:
	redSoulTexture.load_path = "res://.godot/imported/red_soul_normal.png-4f89669b8b9113871863587930ef3923.ctex"
	greenSoulTexture.load_path = "res://.godot/imported/green_soul_normal.png-41e0ebc41d7a126f221b5f497a015d17.ctex"
	redSoulSplit.load_path = "res://.godot/imported/broken_sou;.png-25d08bafe0cf88cd027113c867e9e7c8.ctex"

	redSoulTextureHurt.load_path = "res://.godot/imported/red_soul_hurt.png-5d5a25d9159157f8d767869f2fec4428.ctex"
	greenSoulTextureHurt.load_path= "res://.godot/imported/green_soul_hurt.png-2055f311f0ed0817c57d6449da57be9e.ctex"
	
	musicNode = get_node("Music")
	menuMoveNode = get_node("MenuMove")
	menuSelectNode = get_node("MenuSelect")
	textSndNode = get_node("TextSnd")
	
	soulNode = get_node("Soul")
	soulTexNode = $Soul/SoulTex
	
	fightNode = get_node("Fight")
	actNode = get_node("Act")
	itemNode = get_node("Item")
	mercyNode = get_node("Mercy")
	
	textNode = get_node("Box/Box/MainText")
	
	option0Node = get_node("Box/Box/Options/0")
	option1Node = get_node("Box/Box/Options/1")
	option2Node = get_node("Box/Box/Options/2")
	option3Node = get_node("Box/Box/Options/3")
	
	hpBarNode = get_node("InfoBar/HPBar")
	hpTextNode = get_node("InfoBar/HPText")

	boxNode = get_node("Box")
	
	greenSoulPartsNode = get_node("Soul/GreenSoul")
	greenSoulShield = get_node("Soul/GreenSoul/Shield")
	
	enemyHealthBar = get_node("Box/Box/Options/0/HPBar")
	enemyHealthBar.max_value = enemyMaxHealth
	enemyHealthBar.value = enemyHealth
	enemyHealthBar.visible = false

	attackIndicBar = get_node("Box/Box/AttackIndic")
	attackIndicBar.play()
	attackTargetAnimation = get_node("Box/Target/TargetAnimation")

	knifeAnimationNode = get_node("Undyne/KnifeAnimation")
	knifeSound = get_node("Attack")
	enemyHitSound = get_node("Damage")

	Bullets = get_node("Bullets")

	arrowUpPos = Vector2(soulNode.position.x, -80)
	arrowLeftPos = Vector2(-16, soulNode.position.y)
	arrowRightPos = Vector2(640 + 16, soulNode.position.y)
	arrowDownPos = Vector2(soulNode.position.x, 640 - 80)

	$HealthBar/Bar.max_value = enemyMaxHealth
	$HealthBar/Bar.value = enemyMaxHealth

	setBoxPosInsta(defaultPos)
	musicNode.play()
	
	YellowArrow.DUPath = $"Box/D>U"
	YellowArrow.UDPath = $"Box/U>D"
	YellowArrow.RLPath = $"Box/R>L"
	YellowArrow.LRPath = $"Box/L>R"
	
	$Undyne/Animation.play("idle")
	$"Box/Box/Options/0/HPBar".max_value = enemyMaxHealth
	
	
	
	grazeHitbox.area_shape_entered.connect(func(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
		if area.get_collision_layer_value(2) && iframes <= 0:
			tp += randi_range(1,4)
			$Soul/GrazeArea/AnimationPlayer.stop()
			$Soul/GrazeArea/AnimationPlayer.play("flash")
			grazeSnd.play()
)

func endAttack() -> void:
	if defns > 1:
		defns -= 0.1
	if attk > 1:
		attk -= 0.1
	actualNoMode = true
	menuMode = MenuMode.NO_MODE;
	for node in Bullets.get_children():
		node.remove()
	currentText = ""
	textNode.text = ""
	await setBoxPos(defaultPos)
	menuMode = MenuMode.OPTION_MODE;
	showText(texts.get(randi_range(0,texts.size()-1)))
	actualNoMode = false

func redsoul(boxPos: Vector4i) -> void:
	soulMode = SoulMode.RED
	soulNode.position = Vector2(boxPos.x + (boxPos.z / 2), boxPos.y + (boxPos.w / 2))
	soulNode.visible = true
	mainSoulMode = SoulMode.RED

func greensoul() -> void:
	if paused: return
	$GlobalAnimations.play("fade")
	await setBoxPos(spearAtkPos)
	soulMode = SoulMode.GREEN
	soulNode.position = greenSoulPos
	soulNode.visible = true
	mainSoulMode = SoulMode.GREEN

func doDamage(damage: int):
	print("attack is: " + str(attk))
	damage *= attk
	$HealthBar/DamageNumbers.text = str(roundi(damage))
	enemyHealth -= damage
	print("enemy now at: "+str(enemyHealth)+" hp")
	if enemyHealth <= 0:
		AudioServer.set_bus_mute(1, true)
		$GlobalAnimations.play("end")
		return
	var barTween = get_tree().create_tween()
	barTween.tween_property($HealthBar/Bar, "value", enemyHealth, 1).set_trans(Tween.TRANS_LINEAR)
	knifeAnimationNode.visible = false
	enemyHitSound.play()
	$Undyne/Animation.play("RESET" if damage < 6000000 else "hardhit")
	$HealthBar.visible = true
	barTween.play()
	await get_tree().create_timer(.7).timeout
	await get_tree().create_timer(1).timeout
	$Undyne/Animation.play("idle")
	$HealthBar.visible = false
	attackTargetAnimation.play_backwards()
	attackIndicBar.position.x = -99999
	if currentdia >= sansText.size():
		currentdia = 5
	menuMode = MenuMode.NO_MODE
	showText(sansText.get(currentdia), 1)
	currentdia += 1

func changeSoul() -> void:
	if soulMode == SoulMode.GREEN:
		soulMode = SoulMode.RED
	else:
		soulMode = SoulMode.GREEN

func attack() -> void:
	totalTurns += 1
	menuMode = MenuMode.ENEMY_TURN
	turn += 1
	match turn:
		1:
			await setBoxPos(turn1box) 
			redsoul(turn1box)
			
			for i in range(5):
				spawnHomingArrow(Vector2(-1.5, -1.5))
				await get_tree().create_timer(0.1).timeout
			
			await get_tree().create_timer(3).timeout
		2:
			await setBoxPos(turn1box) 
			redsoul(turn1box)
			
			for i in range(15):
				spawnHomingArrow(Vector2(-.8, -1.5))
				await get_tree().create_timer(0.06).timeout
			
			await get_tree().create_timer(3).timeout
		3:
			await setBoxPos(turn1box) 
			redsoul(turn1box)
			
			for i in range(60):
				spawnHomingArrow(Vector2(-.5, -1))
				await get_tree().create_timer(0.1).timeout
			
			await get_tree().create_timer(3).timeout
		4:
			await setBoxPos(turn4box) 
			redsoul(turn4box)
			var time = 0.4
			for i in range(10):
				spawnBone(Vector2(1.37, 1.37), Vector2(730, 252))
				await get_tree().create_timer(time).timeout
				spawnBone(Vector2(1.37, 1.37), Vector2(730, 348.0))
				await get_tree().create_timer(time).timeout
			
			spawnHomingArrow(Vector2(1.5,2), Vector2(500, 252), Vector2(700, 252))
			spawnHomingArrow(Vector2(1.5,2), Vector2(500, 348), Vector2(700, 348))
			
			spawnBone(Vector2(1.37, 1.37), Vector2(730, 252))
			await get_tree().create_timer(time).timeout
			spawnBone(Vector2(1.37, 1.37), Vector2(730, 348.0))
			await get_tree().create_timer(time).timeout
			
			await get_tree().create_timer(2).timeout
			
		5:
			await setBoxPos(turn4box) 
			redsoul(turn4box)
			var time = 0.1
			var counter = 0
			for i in range(50):
				spawnBone(Vector2(1, 1), Vector2(730, 230 + (sin(counter /2) * 20)))
				spawnBone(Vector2(1, 1), Vector2(730, 368 + (sin(counter /2) * 20)))
				counter += 1
				await get_tree().create_timer(time).timeout
			
			var yy = $Box.global_position.y + 100
			spawnFountainBlaset(Vector2(4,4), Vector2(500, yy), Vector2(700, yy))
			await get_tree().create_timer(13).timeout
		6:
			await setBoxPos(turn1box) 
			redsoul(turn1box)
			
			for i in range(5):
				spawnFountainBlaset(Vector2(-1.5, -1.5))
				await get_tree().create_timer(0.1).timeout
			
			await get_tree().create_timer(3).timeout
		7:
			await setBoxPos(turn1box) 
			redsoul(turn1box)
			
			for i in range(15):
				spawnFountainBlaset(Vector2(-.8, -1.5))
				await get_tree().create_timer(0.06).timeout
			
			await get_tree().create_timer(8).timeout
		8:
			await setBoxPos(turn1box) 
			redsoul(turn1box)
			
			for i in range(15):
				spawnFountainBlaset(Vector2(-.8, -1.5))
				await get_tree().create_timer(0.06).timeout
			
			await get_tree().create_timer(8).timeout
	await get_tree().create_timer(1).timeout
	if paused: return
	if mainSoulMode == SoulMode.GREEN: $GlobalAnimations.play_backwards("fade")
	endAttack()
	return

func _process(delta: float) -> void:
	var mult := delta / 0.0333333
	
	$"Box/Box/Options/0/HPBar".value = enemyHealth
	
	$ProgressBar.value = tp
	if tp < 100:
		$ProgressBar/TPTex.text = "%" + str(tp)
	else:
		$ProgressBar/TPTex.text = "MAX"
	var clr: Color = $BG.modulate
	
	var a = (min(currentdia, 10) if currentdia != 0 else 0) * .2
	var a2 = a - 5 * .2
		
	$BG.modulate = Color.from_hsv(clr.h + 0.005 * mult,clr.s,clr.v, a)
	$BG/GPUParticles2D.self_modulate = Color(1,1,1,a2)
	if paused:
		return
	if Input.is_action_just_pressed("godmod"):
		if not godmode:
			godmode = true
			$MusOhyes.play()
		else:
			godmode = false
			$SndSaber3.play()
	if Input.is_action_just_pressed("kill") :
		damagePlr(9999)
	if Input.is_action_just_pressed("skipturn") :
		if not turn >= 17:
			turn += 1
	if Input.is_action_just_pressed("lastturn") :
		if not turn <= -1:
			turn -= 1
	if Input.is_action_just_pressed("song1"):
		musicNode.stop()
		$Music2.play()
	$Box/Box/TurnCounter.text = "Turn %s" % turn 
	$EndingText/By/Stats.text = """Stats:
		Damage Taken: %s
		Health Healed: %s
		Turns: %s
		
		Reload page to restart.
	""" % [totalDamageTaken, totalDamageHealed, totalTurns]
	iframes -= 1;
	greenSoulShield.rotation = lerp_angle(greenSoulShield.rotation, greenSoulRotate, 0.8 * mult) 
	if iframes > 0:
		match soulMode:
			SoulMode.RED:
				soulTexNode.texture = redSoulTextureHurt
			SoulMode.GREEN:
				soulTexNode.texture = greenSoulTextureHurt
	else:
		match soulMode:
			SoulMode.RED:
				soulTexNode.texture = redSoulTexture
			SoulMode.GREEN:
				soulTexNode.texture = greenSoulTexture
	hpBarNode.value = hp
	hpTextNode.text = "%s / %s" % [hp, maxHp]
	#print(selectedButton)
	if textLoc == 0:
		textNode.text = currentText
		$Diabox/Label.text = ""
	else:
		$Diabox/Label.text = currentText.substr(0,currentTextI)
		textNode.text = ""
	if currentTextI < currentText.length() && (menuMode == MenuMode.OPTION_MODE || menuMode == MenuMode.NO_MODE):
		if currentTextI != currentText.length() && menuMode == MenuMode.NO_MODE && Input.is_action_just_pressed("ui_cancel") :
			currentTextI = currentText.length()
				
		currentTextI += 1
		if textLoc == 0:
			textNode.visible_characters = currentTextI
		else:
			$Diabox.visible = true
			$Diabox/Label.visible_characters = currentTextI
		if not textNode.text.substr(textNode.text.length()-1, 1) == " ":
			#print(textNode.text.substr(textNode.text.length()-1, 1))
			if textLoc == 0:
				textSndNode.play()
			else:
				$TextSnd2.play()
	attackIndicBar.visible = menuMode == MenuMode.ATTACK
	$Box/Box/TurnCounter.visible = menuMode != MenuMode.ENEMY_TURN
	match menuMode:
		MenuMode.ATTACK:
			attackIndicBar.visible = true
			greenSoulPartsNode.visible = false;
			option0Node.visible = false
			option1Node.visible = false
			option2Node.visible = false
			option3Node.visible = false
			textNode.visible = false;
			#soulNode.visible = false;
			if moveIndic:
				attackIndicBar.position.x += 14 * mult
			if attackIndicBar.position.x >= 400 && canAttack:
				canAttack = false
				attackIndicAnimations.play("out")
				$Undyne/MissText.visible = true
				await get_tree().create_timer(0.8).timeout
				attackTargetAnimation.play_backwards()
				attackIndicAnimations.play("RESET")
				$Undyne/MissText.visible = false
				attack()
				return;
			
			if Input.is_action_just_pressed("ui_select") && canAttack :
				moveIndic = false
				canAttack = false
				knifeAnimationNode.visible = true
				knifeAnimationNode.play()
				knifeSound.play()
				var random := randi_range(-83431, 2143234)
				var attackBar : float = 1 - abs((attackIndicBar.position.x - 320) / 320)
				tp += attackBar * 7 + randi_range(-1,4)
				var damage: int = 2523567 + abs(251143 * (attackBar * 3)) + random
				await get_tree().create_timer(0.8).timeout
				doDamage(damage)
		MenuMode.ENEMY_TURN:
			option0Node.visible = false
			option1Node.visible = false
			option2Node.visible = false
			option3Node.visible = false
			textNode.visible = false;
			$Diabox.visible = false
			if (soulMode == SoulMode.GREEN):
				greenSoulPartsNode.visible = true;
				var dur = 0.1
				var timer = 0.05
				if Input.is_action_just_pressed("ui_down") :
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = true
					greenSoulRotate = deg_to_rad(270)
					await get_tree().create_timer(timer).timeout
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = false
				if Input.is_action_just_pressed("ui_up") :
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = true
					greenSoulRotate = deg_to_rad(90)
					await get_tree().create_timer(timer).timeout
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = false
				if Input.is_action_just_pressed("ui_left") :
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = true
					greenSoulRotate = deg_to_rad(0)
					await get_tree().create_timer(timer).timeout
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = false
				if Input.is_action_just_pressed("ui_right") :
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = true
					greenSoulRotate = deg_to_rad(180)
					await get_tree().create_timer(timer).timeout
					$Soul/GreenSoul/Shield/ShieldHB/Shield.disabled = false
			else:
				#greenSoulPartsNode.visible = false;
				var normal = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") 
				var incorrect = Vector2(sign(normal.x), sign(normal.y)) * 4
				soulNode.move_and_collide(incorrect)
		MenuMode.NO_MODE:
			greenSoulPartsNode.visible = false;
			option0Node.visible = false
			option1Node.visible = false
			option2Node.visible = false
			option3Node.visible = false
			textNode.visible = true;
			soulNode.visible = false;
			
			if not actualNoMode && currentTextI >= currentText.length() && Input.is_action_just_pressed("ui_select") :
				attack()
		MenuMode.OPTION_MODE:
			greenSoulPartsNode.visible = false;
			option0Node.visible = false
			option1Node.visible = false
			option2Node.visible = false
			option3Node.visible = false
			textNode.visible = true;
			soulNode.visible = true;
			if Input.is_action_just_pressed("ui_right") && selectedButton != 3 :
				selectedButton += 1
				menuMoveNode.play()
				
			if Input.is_action_just_pressed("ui_left") && selectedButton != 0 :
				selectedButton -= 1
				menuMoveNode.play()
				
			if Input.is_action_just_pressed("ui_select") :
				menuSelectNode.play()
				lastOption = selectedButton
				page = 0
				match selectedButton:
					0:
						enemyHealthBar.visible = true
						menuOptions = [
							enemyName
						]
						menuMode = MenuMode.ITEM
					1:
						enemyHealthBar.visible = false
						menuOptions = [
							"Check",
							"Dead Buster (100% TP)"
						]
						menuMode = MenuMode.ITEM
					2:
						if food.is_empty(): return
						enemyHealthBar.visible = false
						menuOptions = food
						menuMode = MenuMode.ITEM
					3:
						tp = min(100, tp + 16)
						defending = true
						if currentdia >= sansText.size():
							currentdia = 5
						menuMode = MenuMode.NO_MODE
						showText(sansText.get(currentdia), 1)
						currentdia += 1
				selectedButton = 0
				soulNode.position = Vector2(999,999)
				return
					
			match selectedButton:
				0:
					# FIGHT
					soulNode.global_position = Vector2(fightXSoul, soulY)
					fightNode.region_rect = Rect2(8, fightVOffset + selectedVOffset, 110, 42)
					actNode.region_rect = Rect2(8, actVOffset, 110, 42)
					itemNode.region_rect = Rect2(8, itemVOffset, 110, 42)
					mercyNode.region_rect = Rect2(8, mercyVOffset, 110, 42)
				1:
					# ACT
					soulNode.global_position = Vector2(actXSoul, soulY)
					fightNode.region_rect = Rect2(8, fightVOffset, 110, 42)
					actNode.region_rect = Rect2(8, actVOffset + selectedVOffset, 110, 42)
					itemNode.region_rect = Rect2(8, itemVOffset, 110, 42)
					mercyNode.region_rect = Rect2(8, mercyVOffset, 110, 42)
				2:
					# ITEM
					soulNode.global_position = Vector2(itemXSoul, soulY)
					fightNode.region_rect = Rect2(8, fightVOffset, 110, 42)
					actNode.region_rect = Rect2(8, actVOffset, 110, 42)
					itemNode.region_rect = Rect2(8, itemVOffset + selectedVOffset, 110, 42)
					mercyNode.region_rect = Rect2(8, mercyVOffset, 110, 42)
				3:
					# MERCY
					soulNode.global_position = Vector2(mercyXSoul, soulY)
					fightNode.region_rect = Rect2(8, fightVOffset, 110, 42)
					actNode.region_rect = Rect2(8, actVOffset, 110, 42)
					itemNode.region_rect = Rect2(8, itemVOffset, 110, 42)
					mercyNode.region_rect = Rect2(8, mercyVOffset + selectedVOffset, 110, 42)
			pass
		MenuMode.ITEM:
			var offset = page * 4
			greenSoulPartsNode.visible = false;
			soulNode.visible = true;
			option0Node.visible = true
			if canNavTo(menuOptions, 0):
				option0Node.text = "*  " + str(menuOptions[0 + offset])
			else :
				option0Node.text = ""
			option1Node.visible = true
			if canNavTo(menuOptions, 1):
				option1Node.text = "*  " + str(menuOptions[1 + offset])
			else :
				option1Node.text = ""
			option2Node.visible = true
			if canNavTo(menuOptions, 2):
				option2Node.text = "*  " + str(menuOptions[2 + offset])
			else :
				option2Node.text = ""
			option3Node.visible = true
			if canNavTo(menuOptions, 3):
				option3Node.text = "*  " + str(menuOptions[3 + offset])
			else :
				option3Node.text = ""
			textNode.visible = false;
			if canNavTo(menuOptions, selectedButton + 1) && Input.is_action_just_pressed("ui_right") && ((selectedButton != 1  && selectedButton != 3) || menuOptions.size() > (4 + offset)) :
				if (selectedButton + 1 == 2) || (selectedButton + 1 == 4):
					selectedButton = 0
					page += 1;
					menuMoveNode.play()
					return
				selectedButton += 1
				menuMoveNode.play()
				
			if Input.is_action_just_pressed("ui_left") && (page > 0 || (canNavTo(menuOptions, selectedButton - 1) && (selectedButton != 2  && selectedButton != 0))) :
				if (selectedButton - 1 == -1) || (selectedButton - 1 == 1):
					selectedButton = 0
					page -= 1;
					menuMoveNode.play()
					return
				selectedButton -= 1
				menuMoveNode.play()
				
			if canNavTo(menuOptions, selectedButton - 2) && Input.is_action_just_pressed("ui_up") && (selectedButton != 0 && selectedButton != 1) :
				selectedButton -= 2
				menuMoveNode.play()
				
			if canNavTo(menuOptions, selectedButton + 2) && Input.is_action_just_pressed("ui_down") && (selectedButton != 2 && selectedButton != 3) :
				selectedButton += 2
				menuMoveNode.play()
				
			if Input.is_action_just_pressed("ui_cancel") :
				menuMode = MenuMode.OPTION_MODE
				selectedButton = lastOption
				currentTextI = 0
				return
			if Input.is_action_just_pressed("ui_select") :
				menuSelectNode.play()
				menuMode = MenuMode.NO_MODE
				soulNode.visible = false
				if str(menuOptions[selectedButton + offset]) == "Check":
					showText(checkText)
				elif str(menuOptions[selectedButton + offset]) == "Spare":
					attack()
				elif str(menuOptions[selectedButton + offset]) == "Dead Buster (100% TP)":
					if tp >= 100:
						currentText = ""
						var random := randi_range(1243153, 5143234)
						var damage: int = 10000000 + random
						$Undyne/Body/DeadBuster.emitting = true
						$SndRudebusterSwing.play()
						await get_tree().create_timer(1).timeout
						doDamage(damage)
						$SndRudebusterHit.play()
						$FleshImpact.play()
						tp = 0
						return
					else:
						return
				elif str(menuOptions[selectedButton + offset]) == enemyName:
					attackTargetAnimation.play("in")
					canAttack = false
					moveIndic = true
					attackIndicBar.position.x = -85.0
					menuMode = MenuMode.ATTACK
					await get_tree().create_timer(0.3).timeout
					canAttack = true
					enemyHealthBar.visible = false
				else:
					print(food)
					$SndHealC.play()
					var selected :Item = menuOptions[selectedButton + offset]
					heal(selected.Health)
					showText(selected.dio)
					selected.eaten()
					page = 0
					food.remove_at(food.find(selected))
					return
			soulNode.position = optionPoses[selectedButton]
			return
