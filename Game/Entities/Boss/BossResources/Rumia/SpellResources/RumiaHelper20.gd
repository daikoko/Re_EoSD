extends Node2D

const SPRITE := preload("res://Game/Entities/Boss/BossResources/Rumia/SpellResources/BulletCustom_RumiaDarkGlow.png")

var origin:Vector2
var distance:float
var max_scale:float
var current_rotation:float
var rotation_speed:float
var duration:float

var MainShooter:Shooter_Basic
var MainBullets:Array[RowData_Column]
var fire_count:int
var fire_duration:float
var bullet_speed:float
var shooting_stopped:bool

var RNG:RandomNumberGenerator
var GrowTween:Tween
var linked_sprite:Node2D




func _ready():
	%Sprite.scale = Vector2.ZERO
	
	start()
	
	await create_tween().tween_interval(duration).finished
	
	stop()


func _process(delta:float):
	current_rotation += rotation_speed * delta
	self.position = origin + (Vector2.RIGHT.rotated(deg_to_rad(current_rotation)) * distance)
	
	linked_sprite.global_transform = %Sprite.global_transform




func start():
	if GrowTween:
		GrowTween.kill()
	
	GrowTween = self.create_tween()
	GrowTween.tween_property(%Sprite, "scale", Vector2.ONE * max_scale, 2.0)
	await GrowTween.finished
	
	shoot()


func stop():
	if GrowTween:
		GrowTween.kill()
	
	shooting_stopped = true
	MainShooter.disable()
	
	GrowTween = self.create_tween()
	GrowTween.tween_property(%Sprite, "scale", Vector2.ZERO, 2.0)


func shoot():
	while not shooting_stopped:
		if MainShooter == null:
			return
		
		MainShooter.fire_round(
			MainBullets,
			fire_count, fire_duration,
			bullet_speed
		)
		await MainShooter.finished_round


func create_shooter(
		Bullet:BulletData,
		layout_spawner_count:int,
		layout_distance:float,
		fire_count:int,
		bullet_speed:float,
		shooter_rotation:float,
		shooter_rotation_speed:float
	):
	
	MainShooter = GlobalShooter.create_basic_shooter(
		layout_spawner_count, 
		1, 360,
		360,
		layout_distance
	)
	MainShooter.rotation = shooter_rotation
	MainShooter.rotation_speed = shooter_rotation_speed
	
	var Bullets:Array[RowData_Column] = [
		RowData_Column.new([
			ColumnData_Bullet.new([
				Bullet
			])
		])
	]
	
	self.MainBullets            = Bullets 
	self.fire_count             = fire_count 
	self.fire_duration          = 1.0  
	self.bullet_speed           = bullet_speed
	
	self.add_child(MainShooter)


func get_glow() -> Sprite2D:
	linked_sprite = Sprite2D.new()
	linked_sprite.texture = SPRITE
	linked_sprite.scale = Vector2.ZERO
	
	return linked_sprite



func _on_Collider_collider_entered(_other:Collider, other_identity:String) -> void:
	if (
			other_identity == "PlayerHitbox" and 
			not GlobalStage.is_current_player_bomb() and 
			not GlobalStage.is_current_stage_clear()
		):
		
		GlobalPlayer.player_hit.emit()
