extends Node2D

const ID := GlobalSettings.SHOT.MARISA_B
var spellname: String

const DURATION_TIME := 1.0
const DAMAGE := 800.0

var avaliable:bool
var enabled:bool

var LaserTween:Tween




func _ready():
	GlobalPlayer.updated_graze.connect(_on_GlobalPlayer_updated_charge)
	%DurationTimer.wait_time = DURATION_TIME
	%Sprite.visible = false
	%Beam.scale.x = 0
	%Origin.scale = Vector2.ZERO
	%Collider.disable()
	%Bomb.disable()
	
	spellname = GlobalSettings.get_shot_text(ID, "flash")


func _input(event):
	if event.is_action_pressed("game_flash") and enabled and avaliable:
		use_flash()




func toggle(enable:bool) -> void:
	self.enabled = enable


func use_flash() -> void:
	GlobalPlayer.player_used_flash.emit(spellname)
	
	%Sprite.visible = true
	
	set_tween()
	LaserTween.tween_property(%Beam, "scale:x", 1.0, 0.1)
	LaserTween.tween_property(%Origin, "scale", Vector2.ONE * 0.02, 0.1)
	%DurationTimer.start()
	%IntervalTimer.start()
	%Bomb.enable()
	
	%Sound.play()


func set_tween() -> void:
	if LaserTween:
		LaserTween.kill()
	LaserTween = create_tween().set_parallel(true)




func _on_GlobalPlayer_updated_charge(avaliable):
	self.avaliable = avaliable


func _on_Collider_collider_entered(collider, identity):
	if identity == "Enemy":
		collider.hit(DAMAGE)


func _on_DurationTimer_timeout():
	%IntervalTimer.stop()
	%Collider.disable()
	%Bomb.disable()
	
	set_tween()
	LaserTween.tween_property(%Beam, "scale:x", 0.0, 0.2)
	LaserTween.tween_property(%Origin, "scale", Vector2.ZERO, 0.2)
	LaserTween.chain().tween_property(%Sprite, "visible", false, 0.1)


func _on_IntervalTimer_timeout():
	%Collider.enable()
	
	%FrameTimer.start()
	await %FrameTimer.timeout
	
	%Collider.disable()
