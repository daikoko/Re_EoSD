extends Node3D

const RADIUS := 1
const VERTICAL_COUNT := 12
const HORIZONTAL_COUNT := 7

const ROTATION_SPEED_Y := 1

const HELPER_09 := preload("res://Game/Entities/Boss/BossResources/Patchouli/SpellResources/Helper09.tscn")




func _process(_delta:float) -> void:
	self.rotation.y += deg_to_rad(ROTATION_SPEED_Y)




func spawn() -> Array[Node2D]:
	var shot_list:Array[Node2D] = []
	
	var vertical_step = TAU / (VERTICAL_COUNT)
	var horizontal_step = PI / (HORIZONTAL_COUNT - 1)
	
	var horizontal_angle = 0
	for i in HORIZONTAL_COUNT:
		var vertical_angle = 0
		
		for j in VERTICAL_COUNT:
			var vec = Vector3(
				RADIUS * sin(horizontal_angle) * cos(vertical_angle),
				RADIUS * cos(horizontal_angle),
				RADIUS * sin(horizontal_angle) * sin(vertical_angle)
			)
			
			var guide = Marker3D.new()
			guide.position = vec
			self.add_child(guide)
			
			var shot = HELPER_09.instantiate()
			shot.target = guide
			shot_list.append(shot)
			
			vertical_angle += vertical_step
		
		horizontal_angle += horizontal_step
	
	return shot_list
