extends Node2D

var trailers:Node2D

enum FACE {
	LEFT,
	TOP,
	RIGHT,
	BOTTOM
}

var RNG:RandomNumberGenerator
var disabled:bool

const DISTANCE_MIN   := 80
const DISTANCE_MAX   := 200
const FIRE_WAIT_TIME := 0.15

const HELPER_02 := preload("res://Game/Entities/Boss/BossResources/Flandre/SpellResources/Helper02.tscn")




func build() -> void:
	trailers = Node2D.new()
	GlobalStage.request_add_object.emit(trailers)


func fire(
		speed:float,
		max_turns:int,
		trailer_count:int
	) -> void:
	
	var face = RNG.randi_range(0, 3)
	var origin:Vector2 = Vector2.ZERO
	var rotation_start:float
	match face:
		FACE.LEFT:
			origin = Vector2(
				20,
				RNG.randf_range(40, 740)
			)
			rotation_start = 0
		FACE.TOP:
			origin = Vector2(
				RNG.randf_range(40, 640),
				20
			)
			rotation_start = 90
		FACE.RIGHT:
			origin = Vector2(
				660,
				RNG.randf_range(40, 740)
			)
			rotation_start = 180
		FACE.BOTTOM:
			origin = Vector2(
				RNG.randf_range(40, 640),
				760
			)
			rotation_start = 270
	
	var directions:Array = [
		Vector2(
			0,
			RNG.randf_range(
				DISTANCE_MIN,
				DISTANCE_MAX
			)
		)
	]
	for _i in max_turns:
		directions.append(
			generate_instruction()
		)
	
	for i in trailer_count:
		if disabled: return
		
		var trailer = HELPER_02.instantiate()
		trailer.position = origin
		trailer.rotation = deg_to_rad(rotation_start)
		trailer.build(
			(i == 0),
			directions,
			speed
		)
		
		%Sound.play()
		trailers.add_child(trailer)
		await self.create_tween().tween_interval(FIRE_WAIT_TIME).finished


func disable() -> void:
	disabled = true
	
	await self.create_tween().tween_interval(2.0).finished
	
	trailers.queue_free()




func generate_instruction() -> Vector2:
	var rotation = 0
	match RNG.randi_range(0, 1):
		GlobalStage.ZERO:
			rotation = -90
		GlobalStage.ONE:
			rotation =  90
	var distance = RNG.randf_range(
		DISTANCE_MIN,
		DISTANCE_MAX
	)
	
	return Vector2(
		rotation,
		distance
	)
