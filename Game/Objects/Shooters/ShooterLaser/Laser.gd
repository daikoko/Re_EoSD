extends Node2D
class_name Laser

const MAX_DISTANCE   := 1024
const START_WEIGHT   :=    2.0
const START_MODULATE :=    0.6
const END_MODULATE   :=    1.0

var laser_enabled:bool = false
var target_weight:int
var distance:float
var time:float

var laser_suppressed:bool = false
var suppression:float = 1

var laser_collision:bool = false

var TargetTween:Tween
var SuppressionTween:Tween

var id:int

signal laser_activated
signal laser_deactivated




func _ready():
	self.modulate.a = START_MODULATE
	
	particle_hide()
	%Laser.hide()
	
	set_process(false)
	
	if GlobalStage.is_current_stage_clear() or GlobalStage.is_current_player_bomb():
		suppression = 0


func _process(delta):
	time += delta
	check_casting()
	check_suppresion()
	check_enabled()
	
	update_beam()




func activate(
		color:Color, weight:int, 
		duration:float, delay:float=1.0, grow_time:float=0.4, shrink_time:float=0.2
	) -> void:
	
	self.modulate =   color
	self.modulate.a = START_MODULATE
	target_weight =   START_WEIGHT
	time = 0
	
	set_process(true)
	Debug.update_lasers(1)
	
	laser_activated.emit()
	%Laser.show()
	
	%PlayerCollider.enable()
	%GrazeCollider.enable()
	
	TargetTween = create_tween()
	TargetTween.tween_interval(           delay)
	await TargetTween.finished
	
	laser_enabled = true
	
	TargetTween = create_tween()
	TargetTween.tween_property(           self, "target_weight", weight,        grow_time)
	TargetTween.parallel().tween_property(self, "modulate:a",    END_MODULATE,  grow_time)
	TargetTween.tween_interval(           duration)
	
	TargetTween.tween_property(           self, "target_weight", START_WEIGHT,   shrink_time)
	TargetTween.parallel().tween_property(self, "modulate:a",    START_MODULATE, shrink_time)
	await TargetTween.finished
	
	deactivate()




func immediate_stop():
	if TargetTween:
		TargetTween.kill()
	
	TargetTween = create_tween()
	TargetTween.tween_property(           self, "target_weight", START_WEIGHT,   0.1)
	TargetTween.parallel().tween_property(self, "modulate:a",    START_MODULATE, 0.1)
	await TargetTween.finished
	
	deactivate()


func deactivate():
	particle_hide()
	%Laser.hide()
	
	if laser_enabled:
		Debug.update_lasers(-1)
	
	laser_enabled = false
	laser_collision = false
	laser_deactivated.emit()
	
	set_process(false)


func update_beam():
	var real_weight = ((target_weight - 2) * suppression) + 2
	
	%Beam.size.x     =  distance
	%Beam.size.y     =  real_weight
	%Beam.position.y = -real_weight / 2
	
	%PlayerCollider.position.x = distance / 2
	%PlayerCollider.change_rect_size(Vector2(distance, real_weight))
	
	%GrazeCollider.position.x =  distance / 2
	%GrazeCollider.change_rect_size(Vector2( distance, real_weight))
	
	%Start.scale = Vector2.ONE * real_weight * 0.001
	%End.scale   = Vector2.ONE * real_weight * 0.001
	%End.position.x = distance
	
	%ParticlesEnd.position.x =  distance
	%ParticlesBeam.position.x = distance / 2
	
	%ParticlesStart.process_material.emission_ring_radius = real_weight / 2
	%ParticlesEnd.process_material.emission_ring_radius =   real_weight / 1.5
	%ParticlesBeam.process_material.emission_box_extents =  Vector3(distance / 2, real_weight / 2, 1)


func check_casting():
	%Cast.target_position = Vector2(MAX_DISTANCE, 0)
	if %Cast.is_colliding(): distance = (%Cast.get_collision_point() - self.global_position).length()
	else:                    distance = MAX_DISTANCE


func check_enabled():
	if laser_enabled and not laser_suppressed:
		laser_collision = true
		particle_show()
	else:
		laser_collision = false
		particle_hide()


func check_suppresion():
	var suppressed_environment = GlobalStage.is_current_stage_clear() or GlobalStage.is_current_player_bomb()
	if     suppressed_environment and not laser_suppressed:
		if SuppressionTween: SuppressionTween.kill()
		SuppressionTween = create_tween()
		SuppressionTween.tween_property(self, "suppression", 0, 0.2)
		laser_suppressed = true
	if not suppressed_environment and     laser_suppressed:
		if SuppressionTween: SuppressionTween.kill()
		SuppressionTween = create_tween()
		SuppressionTween.tween_property(self, "suppression", 1, 0.2)
		laser_suppressed = false


func particle_show():
	%ParticlesStart.emitting = true
	%ParticlesEnd.emitting =   true
	%ParticlesBeam.emitting =  true


func particle_hide():
	%ParticlesStart.emitting = false
	%ParticlesEnd.emitting =   false
	%ParticlesBeam.emitting =  false




func _on_PlayerCollider_collider_entered(_collider, identity) -> void:
	if identity == "PlayerHitbox" and laser_collision:
		GlobalPlayer.player_hit.emit()


func _on_GrazeCollider_collider_entered(_collider, identity) -> void:
	if identity == "PlayerGraze" and laser_collision:
		GlobalPlayer.player_graze.emit()
		
		%GrazeCollider.disable()
		%GrazeTimer.start()
		await %GrazeTimer.timeout
		
		%GrazeCollider.enable()
