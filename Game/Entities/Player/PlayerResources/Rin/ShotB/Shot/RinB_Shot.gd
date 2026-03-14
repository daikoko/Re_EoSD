extends Node2D

const BULLET_GENERAL := preload("res://Game/Entities/Player/PlayerResources/_General/Shot/PlayerBullet_General.tscn")

const RIN_MAIN     := preload("res://Game/Entities/Player/PlayerResources/Rin/ShotA/Shot/Bullet_RinNormal.tres")
const RIN_FLOWER   := preload("res://Game/Entities/Player/PlayerResources/Rin/ShotB/Shot/Bullet_RinWind.tres")

const RIN_SIDE     := preload("res://Game/Entities/Player/PlayerResources/Rin/ShotB/Shot/Side_RinWind.tscn")

const DISTANCE       := 70.0
const DISTANCE_FOCUS := 50.0
const ANGLES := [
	0,
	TAU * (1/4.0),
	TAU * (2/4.0),
	TAU * (3/4.0),
]

const MAIN_BASE_FIRE_TIME := 0.1
const MAIN_BASE_SPEED := 1000.0
const MAIN_BASE_DAMAGE := 40
const MAIN_BASE_EXTRA := 80
const MAIN_BASE_DECAY := 10

const MAIN_FOCUS_FIRE_TIME := 0.08
const MAIN_FOCUS_SPEED := 1200.0
const MAIN_FOCUS_DAMAGE := 0

const SIDE_BASE_FIRE_TIME := 0.2
const SIDE_BASE_SPEED := 600.0
const SIDE_BASE_DAMAGE := 0
const SIDE_BASE_EXTRA := 60
const SIDE_BASE_DECAY := 0

const SIDE_FOCUS_FIRE_TIME := 0.1
const SIDE_FOCUS_SPEED := 800.0
const SIDE_FOCUS_DAMAGE := 0

const ROTATION_SPEED := 120.0

const MAX_POWER_USAGE := 0
var power_usage:int

var enabled:bool = false
var shooting:bool = false
var deflator:float = 1.0

var power: float = 0.0
var focusing:bool = false
var focus_hold:bool = false
var focus_enabled:bool = false




func _ready():
	GlobalPlayer.updated_power.connect(_on_GlobalPlayer_updated_power)
	%MainTimer.wait_time = MAIN_BASE_FIRE_TIME
	%SideTimer.wait_time = SIDE_BASE_FIRE_TIME
	
	var main_01 = Marker2D.new()
	var main_02 = Marker2D.new()
	var main_03 = Marker2D.new()
	var main_04 = Marker2D.new()
	var main_05 = Marker2D.new()
	%MainShot.set_levels(
		[main_01, main_02, main_03, main_04, main_05],
		{
			1: {
				main_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": true
				},
				main_02: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				main_03: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				main_04: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				main_05: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				}
			},
			2: {
				main_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(20, 0)),
					"activated": true
				},
				main_02: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(-20, 0)),
					"activated": true
				},
				main_03: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				main_04: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				main_05: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				}
			},
			3: {
				main_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": true
				},
				main_02: {
					"transform": Transform2D(deg_to_rad(-90 + 6), Vector2.ZERO),
					"activated": true
				},
				main_03: {
					"transform": Transform2D(deg_to_rad(-90 - 6), Vector2.ZERO),
					"activated": true
				},
				main_04: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				main_05: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				}
			},
			4: {
				main_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": true
				},
				main_02: {
					"transform": Transform2D(deg_to_rad(-90 + 8), Vector2.ZERO),
					"activated": true
				},
				main_03: {
					"transform": Transform2D(deg_to_rad(-90 - 8), Vector2.ZERO),
					"activated": true
				},
				main_04: {
					"transform": Transform2D(deg_to_rad(-90 + 16), Vector2.ZERO),
					"activated": true
				},
				main_05: {
					"transform": Transform2D(deg_to_rad(-90 - 16), Vector2.ZERO),
					"activated": true
				}
			}
		},
		{
			1: {
				main_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": true
				},
				main_02: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				main_03: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				main_04: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				main_05: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				}
			},
			2: {
				main_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(10, 0)),
					"activated": true
				},
				main_02: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(-10, 0)),
					"activated": true
				},
				main_03: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				main_04: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				main_05: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				}
			},
			3: {
				main_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": true
				},
				main_02: {
					"transform": Transform2D(deg_to_rad(-90 + 2), Vector2.ZERO),
					"activated": true
				},
				main_03: {
					"transform": Transform2D(deg_to_rad(-90 - 2), Vector2.ZERO),
					"activated": true
				},
				main_04: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				main_05: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				}
			},
			4: {
				main_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": true
				},
				main_02: {
					"transform": Transform2D(deg_to_rad(-90 + 4), Vector2.ZERO),
					"activated": true
				},
				main_03: {
					"transform": Transform2D(deg_to_rad(-90 - 4), Vector2.ZERO),
					"activated": true
				},
				main_04: {
					"transform": Transform2D(deg_to_rad(-90 + 8), Vector2.ZERO),
					"activated": true
				},
				main_05: {
					"transform": Transform2D(deg_to_rad(-90 - 8), Vector2.ZERO),
					"activated": true
				}
			}
		}
	)
	
	var side_01 = RIN_SIDE.instantiate()
	var side_02 = RIN_SIDE.instantiate()
	var side_03 = RIN_SIDE.instantiate()
	var side_04 = RIN_SIDE.instantiate()
	
	%SideShot.set_levels(
		[side_01, side_02, side_03, side_04],
		{
			1: {
				side_01: {
					"transform": Transform2D(ANGLES[0], Vector2.ZERO),
					"activated": false
				},
				side_02: {
					"transform": Transform2D(ANGLES[2], Vector2.ZERO),
					"activated": false
				},
				side_03: {
					"transform": Transform2D(ANGLES[1], Vector2.ZERO),
					"activated": false
				},
				side_04: {
					"transform": Transform2D(ANGLES[3], Vector2.ZERO),
					"activated": false
				}
			},
			2: {
				side_01: {
					"transform": Transform2D(ANGLES[0], Vector2.RIGHT.rotated(ANGLES[0]) * DISTANCE),
					"activated": true
				},
				side_02: {
					"transform": Transform2D(ANGLES[2], Vector2.RIGHT.rotated(ANGLES[2]) * DISTANCE),
					"activated": true
				},
				side_03: {
					"transform": Transform2D(ANGLES[1], Vector2.ZERO),
					"activated": false
				},
				side_04: {
					"transform": Transform2D(ANGLES[3], Vector2.ZERO),
					"activated": false
				}
			},
			3: {
				side_01: {
					"transform": Transform2D(ANGLES[0], Vector2.RIGHT.rotated(ANGLES[0]) * DISTANCE),
					"activated": true
				},
				side_02: {
					"transform": Transform2D(ANGLES[2], Vector2.RIGHT.rotated(ANGLES[2]) * DISTANCE),
					"activated": true
				},
				side_03: {
					"transform": Transform2D(ANGLES[1], Vector2.RIGHT.rotated(ANGLES[1]) * DISTANCE),
					"activated": true
				},
				side_04: {
					"transform": Transform2D(ANGLES[3], Vector2.RIGHT.rotated(ANGLES[3]) * DISTANCE),
					"activated": true
				}
			}
		},
		{
			1: {
				side_01: {
					"transform": Transform2D(ANGLES[0], Vector2.ZERO),
					"activated": false
				},
				side_02: {
					"transform": Transform2D(ANGLES[2], Vector2.ZERO),
					"activated": false
				},
				side_03: {
					"transform": Transform2D(ANGLES[1], Vector2.ZERO),
					"activated": false
				},
				side_04: {
					"transform": Transform2D(ANGLES[3], Vector2.ZERO),
					"activated": false
				}
			},
			2: {
				side_01: {
					"transform": Transform2D(ANGLES[0], Vector2.RIGHT.rotated(ANGLES[0]) * DISTANCE_FOCUS),
					"activated": true
				},
				side_02: {
					"transform": Transform2D(ANGLES[2], Vector2.RIGHT.rotated(ANGLES[2]) * DISTANCE_FOCUS),
					"activated": true
				},
				side_03: {
					"transform": Transform2D(ANGLES[1], Vector2.ZERO),
					"activated": false
				},
				side_04: {
					"transform": Transform2D(ANGLES[3], Vector2.ZERO),
					"activated": false
				}
			},
			3: {
				side_01: {
					"transform": Transform2D(ANGLES[0], Vector2.RIGHT.rotated(ANGLES[0]) * DISTANCE_FOCUS),
					"activated": true
				},
				side_02: {
					"transform": Transform2D(ANGLES[2], Vector2.RIGHT.rotated(ANGLES[2]) * DISTANCE_FOCUS),
					"activated": true
				},
				side_03: {
					"transform": Transform2D(ANGLES[1], Vector2.RIGHT.rotated(ANGLES[1]) * DISTANCE_FOCUS),
					"activated": true
				},
				side_04: {
					"transform": Transform2D(ANGLES[3], Vector2.RIGHT.rotated(ANGLES[3]) * DISTANCE_FOCUS),
					"activated": true
				}
			}
		}
	)


func _process(delta):
	if Input.is_action_pressed("game_shoot") and !shooting:
		shooting = true
		%MainTimer.one_shot = false
		%SideTimer.one_shot = false
		if %MainTimer.is_stopped():
			shoot_main()
			%MainTimer.start()
			%SideTimer.start()
	elif !Input.is_action_pressed("game_shoot") and shooting:
		shooting = false
		%MainTimer.one_shot = true
		%SideTimer.one_shot = true
	
	if Input.is_action_pressed("game_shift") and !focus_hold:
		toggle_focus(true)
	elif !Input.is_action_pressed("game_shift") and focus_hold:
		toggle_focus(false)
	
	if Input.is_action_pressed("game_shoot") and focusing:
		GlobalPlayer.player_used_power.emit(power_usage * delta)




func toggle(enable:bool) -> void:
	self.enabled = enable


func toggle_visible(enable:bool) -> void:
	self.visible = enable




func shoot_main() -> void:
	if enabled == false:
		return
	
	for shot in %MainShot.get_active_shots():
		var bullet = BULLET_GENERAL.instantiate()
		
		if focusing:
			bullet.set_bullet(
				RIN_MAIN, 
				shot.global_transform, MAIN_FOCUS_SPEED,
				(MAIN_BASE_DAMAGE + (MAIN_BASE_EXTRA * power)) * deflator, MAIN_BASE_DECAY
			)
		else:
			bullet.set_bullet(
				RIN_MAIN, 
				shot.global_transform, MAIN_BASE_SPEED,
				(MAIN_BASE_DAMAGE + (MAIN_BASE_EXTRA * power)) * deflator, MAIN_BASE_DECAY
			)
		
		GlobalStage.request_add_object.emit(bullet)
	
	%Sound_Shoot.play()


func shoot_side():
	if enabled == false:
		return
	
	for shot in %SideShot.get_active_shots():
		var bullet = BULLET_GENERAL.instantiate()
		bullet.pierce = true
		
		if focusing:
			bullet.set_bullet(
				RIN_FLOWER,
				shot.global_transform, SIDE_FOCUS_SPEED,
				SIDE_BASE_DAMAGE + (SIDE_BASE_EXTRA * power), SIDE_BASE_DECAY
			)
		else:
			bullet.set_bullet(
				RIN_FLOWER,
				shot.global_transform, SIDE_BASE_SPEED,
				SIDE_BASE_DAMAGE + (SIDE_BASE_EXTRA * power), SIDE_BASE_DECAY
			)
		
		GlobalStage.request_add_object.emit(bullet)


func toggle_focus(toggle:bool):
	focus_hold = toggle
	check_focusing()


func check_focusing() -> void:
	if (focus_hold and focus_enabled) and !focusing:
		turn_focus()
	elif !(focus_hold and focus_enabled) and focusing:
		turn_unfocus()


func turn_focus():
	focusing = true
	%MainTimer.wait_time = MAIN_FOCUS_FIRE_TIME
	%SideTimer.wait_time = SIDE_FOCUS_FIRE_TIME
	%MainShot.focus()
	%SideShot.focus()


func turn_unfocus():
	focusing = false
	%MainTimer.wait_time = MAIN_BASE_FIRE_TIME
	%SideTimer.wait_time = SIDE_BASE_FIRE_TIME
	%MainShot.unfocus()
	%SideShot.unfocus()




func _on_MainTimer_timeout():
	if shooting:
		shoot_main()


func _on_SideTimer_timeout():
	if shooting:
		shoot_side()


func _on_GlobalPlayer_updated_power(percentage):
	power = percentage
	if power > 0.15:
		power_usage = MAX_POWER_USAGE * clampf(power, 0.2, 1.0)
	else:
		power_usage = 0
	focus_enabled = percentage > 0.15
	check_focusing()
	
	if percentage < 0.1:
		%MainShot.change_level(1)
		%SideShot.change_level(1)
		deflator = 1.0
		
	elif percentage < 0.2:
		%MainShot.change_level(1)
		%SideShot.change_level(2)
		deflator = 1.0
		
	elif percentage < 0.3:
		%MainShot.change_level(2)
		%SideShot.change_level(2)
		deflator = 0.6
	
	elif percentage < 0.4:
		%MainShot.change_level(3)
		%SideShot.change_level(2)
		deflator = 0.4
		
	elif percentage < 0.6:
		%MainShot.change_level(3)
		%SideShot.change_level(3)
		deflator = 0.4
		
	else:
		%MainShot.change_level(4)
		%SideShot.change_level(3)
		deflator = 0.3
