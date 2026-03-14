extends Node2D

const FLASH_TRESHOLD := 0.6
const FLASH_START_SCALE := 0.5
const FLASH_START_MODULATE := 0.0
const FLASH_END_SCALE := 0.0
const FLASH_END_MODULATE := 0.4

var MainShooter:Shooter_Basic
var Bullets:Array[RowData_Column]
var bullet_speed:float
var spawn_stack_count:int
var spawn_stack_speed:float
var aim:bool

var current_time:float
var travel_distance_curve:Curve
var travel_distance_multiplier:float
var travel_time:float

var original_position:Vector2
var direction:Vector2

var start_flash:bool = false
var mute:bool




func _ready():
	set_process(false)


func _process(delta:float) -> void:
	current_time += delta
	
	if current_time > (travel_time * FLASH_TRESHOLD) and not start_flash:
		start_flash = true
		flash()
	if current_time > travel_time:
		set_process(false)
		start()
	
	var distance = travel_distance_curve.sample(current_time/travel_time) * travel_distance_multiplier
	position = original_position + (direction * distance)




func activate(
		transform:Transform2D,
		data:BulletData,
		travel_distance_curve:Curve, 
		travel_distance_multiplier:float, 
		travel_time:float,
		bullets:Array[RowData_Column],
		bullet_speed:float, 
		spawn_stack_count:int, spawn_stack_speed:float,
		aim:bool
	) -> void:
	
	%BulletDull.reset_data(data)
	self.transform = transform
	self.original_position = global_position
	self.direction = Vector2.RIGHT.rotated(self.rotation)
	
	self.travel_distance_curve = travel_distance_curve
	self.travel_distance_multiplier = travel_distance_multiplier
	self.travel_time = travel_time
	
	self.Bullets = bullets
	self.bullet_speed = bullet_speed
	self.spawn_stack_count = spawn_stack_count
	self.spawn_stack_speed = spawn_stack_speed
	self.aim = aim
	
	%Flash.scale = Vector2.ONE * FLASH_START_SCALE
	%Flash.modulate.a = FLASH_START_MODULATE
	
	set_process(true)




func flash():
	var FlashTweener = self.create_tween().set_parallel(true)
	FlashTweener.tween_property(%Flash, "scale", Vector2.ONE * FLASH_END_SCALE, travel_time * (1 - FLASH_TRESHOLD))
	FlashTweener.tween_property(%Flash, "modulate:a", FLASH_END_MODULATE, travel_time * (1 - FLASH_TRESHOLD))


func start():
	MainShooter.mute = mute
	
	if aim:
		MainShooter.global_rotation = GlobalPlayer.angle_to_player(MainShooter.global_position)
	MainShooter.fire_round_stack(
		Bullets,
		1, 0,
		bullet_speed, 0,
		0, 0,
		spawn_stack_count, spawn_stack_speed
	)
	
	%BulletDull.deactivate()



func _on_BulletDull_bullet_deactivate() -> void:
	await GlobalStage.create_timer_short(self, 0.5).timeout
	
	queue_free()
