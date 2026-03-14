extends Sprite2D
class_name BulletDull

const VALUE := 1200

@export var data:BulletData

@export_group("Immunities")
@export var hit_immunity:bool = false
@export var bomb_immunity:bool = false
@export var clear_immunity:bool = false
@export var visibility_immunity:bool = false

@export_group("Flash")
@export var flash_scale:float = 2.0
@export var flash_time:float = 0.2
@export var immunity_time:float = 0.1

var point:bool = true
var time:float

var query:PhysicsShapeQueryParameters2D
var space:PhysicsDirectSpaceState2D

var stagger:int
var active:bool = false

var color:Color

signal bullet_ready
signal bullet_deactivate




func _ready():
	query = PhysicsShapeQueryParameters2D.new()
	space = get_world_2d().direct_space_state
	
	query.collide_with_areas = true
	query.collision_mask = 1
	query.set_shape(data.shape)
	
	activate()


func _process(delta):
	if !%Visibility.is_on_screen() and time > immunity_time and !visibility_immunity:
		deactivate()
		return
	
	time += delta
	
	if stagger != 0:
		stagger -= 1
		return
	else:
		stagger = 1
	
	if GlobalStage.is_current_stage_clear_plain():
		deactivate()
		return
	elif GlobalStage.is_current_stage_clear():
		if clear_immunity:
			return
		if point:
			GlobalPool.particle_clear_spawned.emit(global_position)
		deactivate()
		return
	elif GlobalStage.is_current_stage_bomb():
		if point:
			GlobalPool.item_point_spawned.emit(global_position, true)
			GlobalPool.item_score_spawned.emit(global_position, VALUE)
			GlobalPool.particle_bomb_spawned.emit(global_position, color)
		deactivate()
		return
	
	query.transform = global_transform
	var result = space.intersect_shape(query, 1)
	if result:
		var object:Collider = result[0]["collider"]
		var identity:String = object.identity
		
		if identity == "PlayerGraze":
			GlobalPlayer.player_graze.emit()
			query.set_exclude([result[0]["collider"]])
		elif identity == "Bomb":
			if bomb_immunity:
				return
			if point:
				GlobalPool.item_point_spawned.emit(global_position, true)
				GlobalPool.item_score_spawned.emit(global_position, VALUE)
				GlobalPool.particle_bomb_spawned.emit(global_position, color)
			deactivate()
		elif identity == "PlayerHitbox" and active:
			GlobalPlayer.player_hit.emit()
			if not hit_immunity:
				deactivate()




func activate() -> void:
	self.texture =     data.texture
	self.color =       data.color
	%Visibility.rect = data.visibility
	
	if flash_time == 0:
		scale = Vector2.ONE
		material.set_shader_parameter("flash_color", color)
		material.set_shader_parameter("flash_modifier", 0)
	else:
		scale = Vector2.ONE * flash_scale
		material.set_shader_parameter("flash_color", color)
		material.set_shader_parameter("flash_modifier", 1.0)
	
	var FlashTween = create_tween().set_parallel(true)
	FlashTween.tween_property(self, "scale", Vector2.ONE, flash_time)
	FlashTween.tween_property(material, "shader_parameter/flash_modifier", 0.0, flash_time)
	FlashTween.finished.connect(_on_FlashTween_finished)
	
	Debug.update_dull(1)


func deactivate() -> void:
	set_process(false)
	visible = false
	
	bullet_deactivate.emit()


func reset_data(data:BulletData) -> void:
	query.set_shape(data.shape)
	self.texture =     data.texture
	self.color =       data.color


func collision_disable():
	query.collide_with_areas = false


func collision_enable():
	query.collide_with_areas = true


func flash(value:float, time:float=0):
	var SelfTween = self.create_tween()
	SelfTween.tween_property(material, "shader_parameter/flash_modifier", value, time)




func _on_FlashTween_finished():
	active = true
	bullet_ready.emit()


func _exit_tree():
	Debug.update_dull(-1)
