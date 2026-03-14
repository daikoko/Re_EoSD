extends Resource
class_name EnemyShooter

var Main:Node2D
var StartTimer:Timer
var CoolTimer:Timer
var RNG:RandomNumberGenerator

var active:bool

signal deactivated




func set_shooter(_enemy:Node2D) -> void:
	pass


func start() -> void:
	pass


func death_start() -> void:
	pass


func stop() -> void:
	# print("Stop")
	active = false
	if CoolTimer:
		CoolTimer.stop()
	
	Main.disable_wait()


func stop_immediate() -> void:
	active = false
	if CoolTimer:
		CoolTimer.stop()
	
	Main.disable()


func copy() -> Resource:
	return self.duplicate()




func _on_Main_deactivated():
	emit_signal("deactivated")
