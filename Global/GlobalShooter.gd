extends Node

const SHAPE_TEMPLATE := preload("res://Game/Objects/Shooters/Shooter/ShapeTemplate.tscn")
const POINTER := preload("res://Game/Objects/Shooters/Shooter/Pointer.tscn")
const LASER := preload("res://Game/Objects/Shooters/ShooterLaser/Laser.tscn")

const SHOOTER_BASIC :=  preload("res://Game/Objects/Shooters/ShooterBasic/Shooter_Basic.tscn")
const SHOOTER_LINEAR := preload("res://Game/Objects/Shooters/ShooterLinear/Shooter_Linear.tscn")
const SHOOTER_SHAPE :=  preload("res://Game/Objects/Shooters/ShooterShape/Shooter_Shape.tscn")
const SHOOTER_SINE :=   preload("res://Game/Objects/Shooters/ShooterSine/Shooter_Sine.tscn")
const SHOOTER_TWEEN :=  preload("res://Game/Objects/Shooters/ShooterTween/Shooter_Tween.tscn")
const SHOOTER_ARROW :=  preload("res://Game/Objects/Shooters/ShooterArrow/Shooter_Arrow.tscn")
const SHOOTER_LASER :=  preload("res://Game/Objects/Shooters/ShooterLaser/Shooter_Laser.tscn")

const SMALL_RED :=      preload("res://Game/Objects/Bullets/BulletList/Bullet_SmallRed.tres")
const SMALL_YELLOW :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_SmallYellow.tres")
const SMALL_GREEN :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_SmallGreen.tres")
const SMALL_CYAN :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_SmallCyan.tres")
const SMALL_BLUE :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_SmallBlue.tres")
const SMALL_MAGENTA :=  preload("res://Game/Objects/Bullets/BulletList/Bullet_SmallMagenta.tres")
const SMALL_WHITE :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_SmallWhite.tres")
const SMALL_BLACK :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_SmallBlack.tres")
const STONE_RED :=      preload("res://Game/Objects/Bullets/BulletList/Bullet_StoneRed.tres")
const STONE_YELLOW :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_StoneYellow.tres")
const STONE_GREEN :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_StoneGreen.tres")
const STONE_CYAN :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_StoneCyan.tres")
const STONE_BLUE :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_StoneBlue.tres")
const STONE_MAGENTA :=  preload("res://Game/Objects/Bullets/BulletList/Bullet_StoneMagenta.tres")
const STONE_WHITE :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_StoneWhite.tres")
const STONE_BLACK :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_StoneBlack.tres")
const SPADE_RED :=      preload("res://Game/Objects/Bullets/BulletList/Bullet_SpadeRed.tres")
const SPADE_YELLOW :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_SpadeYellow.tres")
const SPADE_GREEN :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_SpadeGreen.tres")
const SPADE_CYAN :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_SpadeCyan.tres")
const SPADE_BLUE :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_SpadeBlue.tres")
const SPADE_MAGENTA :=  preload("res://Game/Objects/Bullets/BulletList/Bullet_SpadeMagenta.tres")
const SPADE_WHITE :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_SpadeWhite.tres")
const SPADE_BLACK :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_SpadeBlack.tres")
const KUNAI_RED :=      preload("res://Game/Objects/Bullets/BulletList/Bullet_KunaiRed.tres")
const KUNAI_YELLOW :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_KunaiYellow.tres")
const KUNAI_GREEN :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_KunaiGreen.tres")
const KUNAI_CYAN :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_KunaiCyan.tres")
const KUNAI_BLUE :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_KunaiBlue.tres")
const KUNAI_MAGENTA :=  preload("res://Game/Objects/Bullets/BulletList/Bullet_KunaiMagenta.tres")
const KUNAI_WHITE :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_KunaiWhite.tres")
const KUNAI_BLACK :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_KunaiBlack.tres")
const KNIFE_RED :=      preload("res://Game/Objects/Bullets/BulletList/Bullet_KnifeRed.tres")
const KNIFE_YELLOW :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_KnifeYellow.tres")
const KNIFE_GREEN :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_KnifeGreen.tres")
const KNIFE_CYAN :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_KnifeCyan.tres")
const KNIFE_BLUE :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_KnifeBlue.tres")
const KNIFE_MAGENTA :=  preload("res://Game/Objects/Bullets/BulletList/Bullet_KnifeMagenta.tres")
const KNIFE_WHITE :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_KnifeWhite.tres")
const KNIFE_BLACK :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_KnifeBlack.tres")
const SEED_RED :=       preload("res://Game/Objects/Bullets/BulletList/Bullet_SeedRed.tres")
const SEED_YELLOW :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_SeedYellow.tres")
const SEED_GREEN :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_SeedGreen.tres")
const SEED_CYAN :=      preload("res://Game/Objects/Bullets/BulletList/Bullet_SeedCyan.tres")
const SEED_BLUE :=      preload("res://Game/Objects/Bullets/BulletList/Bullet_SeedBlue.tres")
const SEED_MAGENTA :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_SeedMagenta.tres")
const SEED_WHITE :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_SeedWhite.tres")
const SEED_BLACK :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_SeedBlack.tres")
const BRIGHT_RED :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_BrightRed.tres")
const BRIGHT_YELLOW :=  preload("res://Game/Objects/Bullets/BulletList/Bullet_BrightYellow.tres")
const BRIGHT_GREEN :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_BrightGreen.tres")
const BRIGHT_CYAN :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_BrightCyan.tres")
const BRIGHT_BLUE :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_BrightBlue.tres")
const BRIGHT_MAGENTA := preload("res://Game/Objects/Bullets/BulletList/Bullet_BrightMagenta.tres")
const BRIGHT_WHITE :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_BrightWhite.tres")
const BRIGHT_BLACK :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_BrightBlack.tres")
const MEDIUM_RED :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_MediumRed.tres")
const MEDIUM_YELLOW :=  preload("res://Game/Objects/Bullets/BulletList/Bullet_MediumYellow.tres")
const MEDIUM_GREEN :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_MediumGreen.tres")
const MEDIUM_CYAN :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_MediumCyan.tres")
const MEDIUM_BLUE :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_MediumBlue.tres")
const MEDIUM_MAGENTA := preload("res://Game/Objects/Bullets/BulletList/Bullet_MediumMagenta.tres")
const MEDIUM_WHITE :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_MediumWhite.tres")
const MEDIUM_BLACK :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_MediumBlack.tres")
const LARGE_RED :=      preload("res://Game/Objects/Bullets/BulletList/Bullet_LargeRed.tres")
const LARGE_YELLOW :=   preload("res://Game/Objects/Bullets/BulletList/Bullet_LargeYellow.tres")
const LARGE_GREEN :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_LargeGreen.tres")
const LARGE_CYAN :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_LargeCyan.tres")
const LARGE_BLUE :=     preload("res://Game/Objects/Bullets/BulletList/Bullet_LargeBlue.tres")
const LARGE_MAGENTA :=  preload("res://Game/Objects/Bullets/BulletList/Bullet_LargeMagenta.tres")
const LARGE_WHITE :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_LargeWhite.tres")
const LARGE_BLACK :=    preload("res://Game/Objects/Bullets/BulletList/Bullet_LargeBlack.tres")

const STANDARD_START := 20.0

var template:ShapeTemplate




func _ready():
	template = SHAPE_TEMPLATE.instantiate()
	self.add_child(template)




func create_basic_shooter(
		spawner_count:int=1, 
		column_count:int=1, column_range:float=360, shot_range:float=360,
		distance:float=STANDARD_START, 
		random:bool=false, 
		RNG:RandomNumberGenerator=null
	) -> Shooter_Basic:
	
	var shooter = SHOOTER_BASIC.instantiate() 
	var spawner_map = build_basic(spawner_count, 
		column_count, column_range, shot_range,
		distance, random, RNG)
	for j in column_count:
		var columns = spawner_map[j]
		for k in spawner_count:
			var spawner = columns[k]
			shooter.add_child(spawner)
	
	shooter.spawner_map = spawner_map
	shooter.spawner_count = spawner_count
	shooter.column_count = column_count
	
	return shooter


func create_basic_shooter_map(
		spawner_map:Array
	) -> Shooter_Basic:
	
	var shooter = SHOOTER_BASIC.instantiate() 
	var column_count = spawner_map.size()
	var spawner_count = spawner_map[0].size()
	for j in column_count:
		var columns = spawner_map[j]
		for k in spawner_count:
			var spawner = columns[k]
			shooter.add_child(spawner)
	
	shooter.spawner_map = spawner_map
	shooter.spawner_count = spawner_count
	shooter.column_count = column_count
	
	return shooter


func create_linear_shooter(
		spawner_count:int=1, 
		column_count:int=1, column_range:float=360, shot_range:float=360,
		distance:float=STANDARD_START, random:bool=false, RNG:RandomNumberGenerator=null
	) -> Shooter_Linear:
	
	var shooter = SHOOTER_LINEAR.instantiate() 
	var spawner_map = build_basic(spawner_count, 
		column_count, column_range, shot_range,
		distance, random, RNG)
	for j in column_count:
		var columns = spawner_map[j]
		for k in spawner_count:
			var spawner = columns[k]
			shooter.add_child(spawner)
	
	shooter.spawner_map = spawner_map
	shooter.spawner_count = spawner_count
	shooter.column_count = column_count
	
	return shooter


func create_shape_shooter(
		spawner_count:int,
		shape:int=ShapeTemplate.SHAPE.CIRCLE, 
		scale:Vector2=Vector2.ONE,
		distance:float=STANDARD_START,
	) -> Shooter_Shape:
	
	var shooter = SHOOTER_SHAPE.instantiate()
	var spawner_map = build_shape(
		spawner_count,
		shape, 
		scale,
		distance
	)
	for k in spawner_map.size():
		var spawner = spawner_map[k]
		shooter.add_child(spawner)
	
	shooter.spawner_map = spawner_map
	shooter.spawner_count = spawner_count
	
	return shooter


func create_sine_shooter(
		spawner_map:Array
	) -> Shooter_Sine:
	
	var shooter = SHOOTER_SINE.instantiate() 
	var column_count = spawner_map.size()
	var spawner_count = spawner_map[0].size()
	for j in column_count:
		var columns = spawner_map[j]
		for k in spawner_count:
			var spawner = columns[k]
			shooter.add_child(spawner)
	
	shooter.spawner_map = spawner_map
	shooter.spawner_count = spawner_count
	shooter.column_count = column_count
	
	return shooter


func create_tween_shooter(
		spawner_map:Array
	) -> Shooter_Tween:
	
	var shooter = SHOOTER_TWEEN.instantiate()
	var spawner_count = spawner_map.size()
	for k in spawner_count:
		var spawner = spawner_map[k]
		shooter.add_child(spawner)
	
	shooter.spawner_map = spawner_map
	shooter.spawner_count = spawner_count
	
	return shooter


func create_arrow_shooter(
		primary_map:Array,
		arrow_size:int=1, arrow_length:float=100, arrow_width:float=100,
		arrow_displacement:float=250, 
		arrow_fill:bool=false
	) -> Shooter_Arrow:
	
	var shooter = SHOOTER_ARROW.instantiate()
	var primary_columns = primary_map.size()
	var primary_spawners = primary_map[0].size()
	for j in primary_columns:
		var columns = primary_map[j]
		for k in primary_spawners:
			var spawner = columns[k]
			shooter.add_child(spawner)
	
	var secondary_map = template.generate_arrow(
		arrow_size, arrow_length, arrow_width,
		arrow_displacement, 
		arrow_fill
	)
	
	var secondary_object = Node2D.new()
	for pointer in secondary_map:
		secondary_object.add_child(pointer)
	
	shooter.primary_map = primary_map
	shooter.primary_spawners = primary_spawners
	shooter.primary_columns = primary_columns
	shooter.secondary_object = secondary_object
	shooter.add_child(secondary_object)
	
	return shooter


func create_laser_shooter(
		spawner_map:Array
	) -> Shooter_Laser:
	
	var shooter = SHOOTER_LASER.instantiate()
	var column_count = spawner_map.size()
	var spawner_count = spawner_map[0].size()
	for j in column_count:
		var columns = spawner_map[j]
		for k in spawner_count:
			var laser = LASER.instantiate()
			laser.transform = columns[k].transform
			laser.laser_deactivated.connect(shooter._on_Laser_laser_deactivated)
			columns[k].queue_free()
			columns[k] = laser
			shooter.add_child(laser)
	
	shooter.spawner_map = spawner_map
	shooter.spawner_count = spawner_count
	shooter.column_count = column_count
	shooter.free_lasers = column_count * spawner_count
	
	return shooter




func build_basic(
		spawner_count:int=1, 
		column_count:int=1, column_range:float=360, shot_range:float=360,
		distance:float=STANDARD_START, random:bool=false, RNG:RandomNumberGenerator=null
	) -> Array:
	
	column_range = deg_to_rad(column_range)
	shot_range = deg_to_rad(shot_range)
	
	var column_step = 0
	var spawner_step = 0
	var angle = 0
	
	if shot_range == TAU:
		column_step = TAU / column_count
		if (column_range == TAU):
			spawner_step = column_range / spawner_count
		else:
			if spawner_count != 1:
				spawner_step = column_range / (spawner_count-1)
				angle = - column_range / 2
	else:
		column_range = clamp(column_range, 0, shot_range)
		if column_count == 1:
			if spawner_count != 1:
				spawner_step = column_range / (spawner_count-1)
				angle = - column_range / 2
		else:
			column_step = column_range + (shot_range - (column_range * column_count)) / (column_count - 1)
			if spawner_count == 1:
				angle = - (shot_range / 2) + (column_range / 2)
			else:
				spawner_step = column_range / (spawner_count-1)
				angle = - shot_range / 2
	
	var spawner_map:Array = []
	for j in column_count:
		var column:Array = []
		for k in spawner_count:
			var real_angle = 0
			if random:
				real_angle = RNG.randf_range(angle, angle + spawner_step*(spawner_count-1))
			else:
				real_angle = angle + spawner_step*k
			
			var spawner = POINTER.instantiate()
			var vec = Vector2.RIGHT.rotated(real_angle)
			spawner.position = vec * distance
			spawner.rotation = vec.angle()
			column.append(spawner)
		
		spawner_map.append(column)
		angle += column_step
	
	return spawner_map


func build_shape(
		spawners:int,
		shape:int=ShapeTemplate.SHAPE.CIRCLE, 
		scale:Vector2=Vector2.ONE,
		distance:float=STANDARD_START
	) -> Array:
	
	template.load_template(shape)
	return template.generate_transforms(spawners, distance, scale)


func empty_curve() -> Curve:
	return Curve.new()


func make_curve(curve_range:Vector2, points:Array[Vector2]) -> Curve:
	var curve = Curve.new()
	curve.min_value = curve_range.x
	curve.max_value = curve_range.y
	for point in points:
		curve.add_point(point)
	
	return curve


func make_transform_array(vectors:Array) -> Array[Transform2D]:
	var transforms:Array[Transform2D] = []
	for vector in vectors:
		transforms.append(make_transform(vector))
	
	return transforms


func make_transform(vector:Vector3) -> Transform2D:
	return Transform2D(deg_to_rad(vector.z), Vector2(vector.x,vector.y))
