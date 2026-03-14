extends Node2D
class_name Player
## The player object

var enabled_movement:bool = true
var enabled_mouse:bool = false
var viewport:Vector2 = GlobalStage.VIEWPORT_SIZE

var speed_normal:float
var speed_focus:float

var respawn:DeathData
var Hitbox:Node2D
var Shot:Node2D
var Flash:Node2D
var Bomb:Node2D

var immunity_counter:int




func _ready():
	GlobalPlayer.set_player(self)
	GlobalPlayer.player_death.connect(_on_GlobalPlayer_player_death)
	GlobalPlayer.player_over.connect(_on_GlobalPlayer_player_over)
	GlobalPlayer.player_continued.connect(_on_GlobalPlayer_player_continued)
	GlobalPlayer.player_used_bomb.connect(_on_GlobalPlayer_player_used_bomb)
	GlobalPlayer.player_used_bomb_stop.connect(_on_GlobalPlayer_player_used_bomb_stop)
	GlobalStage.dialogue_start.connect(_on_GlobalStage_dialogue_start)
	GlobalStage.dialogue_end.connect(_on_GlobalStage_dialogue_end)
	GlobalStage.request_slow.connect(_on_GlobalStage_request_slow)
	GlobalStage.request_slow_release.connect(_on_GlobalStage_request_slow_release)
	GlobalStage.request_stop.connect(_on_GlobalStage_request_stop)
	GlobalStage.request_stop_release.connect(_on_GlobalStage_request_stop_release)
	
	toggle_movement(false)
	toggle_hitbox(false)
	toggle_shot(false)
	
	modulate.a = 1


func _process(delta):
	var direction: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("game_up"): 
		direction.y += -1
	if Input.is_action_pressed("game_right"):
		direction.x += 1
	if Input.is_action_pressed("game_down"):
		direction.y += 1
	if Input.is_action_pressed("game_left"):
		direction.x += -1
	
	direction = direction.normalized()
	if enabled_movement:
		if Input.is_action_pressed("game_shift"):
			self.position += direction * speed_focus * delta
		else:
			self.position += direction * speed_normal * delta
		
		self.position.x = clamp(position.x, 0, viewport.x)
		self.position.y = clamp(position.y, 0, viewport.y)




func start() -> void:
	toggle_movement(true)
	toggle_hitbox(true)
	toggle_itembox(true)
	toggle_shot(true)
	toggle_shot_visible(true)


func set_sprite(
	sprite_scene:PackedScene,
	sprite_frames:SpriteFrames, sprite_offset:Vector2 ) -> void:
	
	var SpriteObject = sprite_scene.instantiate()
	SpriteObject.sprite_frames = sprite_frames
	SpriteObject.offset = sprite_offset
	SpriteObject.disable_flash()
	self.add_child(SpriteObject)


func set_hitbox(
	hitbox_scene:PackedScene,
	hitbox:int, charge:int, collection:int, 
	inner_hit_marker:Texture2D, outer_hit_marker:Texture2D ) -> void:
	
	Hitbox = hitbox_scene.instantiate()
	Hitbox.set_player_collider(
		hitbox, charge, collection, 
		inner_hit_marker, outer_hit_marker
	)
	self.add_child(Hitbox)


func set_shot(
	respawn:DeathData, 
	bomb_scene:PackedScene, shot_data:ShotData) -> void:
	
	if respawn:
		self.respawn = respawn
	else:
		self.respawn = DeathData.new()
	
	if bomb_scene:
		Bomb = bomb_scene.instantiate()
		self.add_child(Bomb)
	
	if shot_data.shot:
		Shot = shot_data.shot.instantiate()
		self.add_child(Shot)
	
	if shot_data.flash:
		Flash = shot_data.flash.instantiate()
		self.add_child(Flash)


func toggle_movement(enable:bool) -> void:
	enabled_movement = enable


func toggle_hitbox(enable:bool) -> void:
	if enable:
		Hitbox.enable_hit()
	else:
		Hitbox.disable_hit()


func toggle_itembox(enable:bool) -> void:
	if enable:
		Hitbox.enable_item()
	else:
		Hitbox.disable_item()


func toggle_shot(enable:bool) -> void:
	if Bomb:
		Bomb.toggle(enable)
	
	if Shot:
		Shot.toggle(enable)
	
	if Flash:
		Flash.toggle(enable)


func toggle_shot_visible(enable:bool) -> void:
	if Shot:
		Shot.toggle_visible(enable)


func update_check_immunity(amount:int) -> void:
	immunity_counter += amount
	
	if immunity_counter == 0: toggle_hitbox(true)
	else:                     toggle_hitbox(false)




func _on_GlobalPlayer_player_death():
	respawn.start(global_position)
	
	toggle_movement(false)
	toggle_hitbox(false)
	toggle_itembox(false)
	toggle_shot(false)
	toggle_shot_visible(false)
	
	%Animator.play("Death")
	await %Animator.animation_finished
	
	position = GlobalStage.get_player_default_position()
	modulate.a = 0.5
	toggle_movement(true)
	
	%Animator.play("Respawn")
	await %Animator.animation_finished
	
	modulate.a = 1
	toggle_hitbox(true)
	toggle_itembox(true)
	toggle_shot(true)
	toggle_shot_visible(true)
	
	GlobalPlayer.player_respawned.emit()


func _on_GlobalPlayer_player_over():
	respawn.start(global_position)
	
	toggle_movement(false)
	toggle_hitbox(false)
	toggle_itembox(false)
	toggle_shot(false)
	toggle_shot_visible(false)
	
	%Animator.play("Death")


func _on_GlobalPlayer_player_continued():
	position = GlobalStage.PLAYER_DEFAULT_POSITION + Vector2(0, 350)
	modulate.a = 0.5
	
	var tweener = create_tween()
	tweener.tween_property(self, "position", GlobalStage.get_player_default_position(), 1.0)
	%Animator.play("Respawn")
	await %Animator.animation_finished
	
	modulate.a = 1
	toggle_movement(true)
	toggle_hitbox(true)
	toggle_itembox(true)
	toggle_shot(true)
	toggle_shot_visible(true)
	
	GlobalPlayer.player_respawned.emit()


func _on_GlobalPlayer_player_used_bomb(_spell_name):
	update_check_immunity(1)


func _on_GlobalPlayer_player_used_bomb_stop():
	update_check_immunity(-1)


func _on_GlobalStage_dialogue_start(shot_enable):
	update_check_immunity(1)
	
	if shot_enable == false:
		toggle_shot(false)


func _on_GlobalStage_dialogue_end():
	update_check_immunity(-1)
	
	await get_tree().process_frame
	toggle_shot(true)


func _on_GlobalStage_request_slow():
	update_check_immunity(1)


func _on_GlobalStage_request_slow_release():
	update_check_immunity(-1)


func _on_GlobalStage_request_stop():
	update_check_immunity(1)


func _on_GlobalStage_request_stop_release():
	update_check_immunity(-1)
