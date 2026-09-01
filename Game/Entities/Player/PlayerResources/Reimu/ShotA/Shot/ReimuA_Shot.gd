extends Node2D

const BULLET_GENERAL := preload("res://Game/Entities/Player/PlayerResources/_General/Shot/PlayerBullet_General.tscn")
const BULLET_HOMING  := preload("res://Game/Entities/Player/PlayerResources/Reimu/ShotA/Shot/PlayerBullet_ReimuHoming.tscn")

const REIMU_MAIN     := preload("res://Game/Entities/Player/PlayerResources/Reimu/ShotA/Shot/Bullet_ReimuMain.tres")
const REIMU_HOMING   := preload("res://Game/Entities/Player/PlayerResources/Reimu/ShotA/Shot/Bullet_ReimuHoming.tres")

const REIMU_SIDE     := preload("res://Game/Entities/Player/PlayerResources/Reimu/ShotA/Shot/Side_Reimu.tscn")

const MAIN_BASE_FIRE_TIME := 0.1
const MAIN_BASE_SPEED := 1000.0
const MAIN_BASE_DAMAGE := 80
const MAIN_BASE_EXTRA := 20
const MAIN_BASE_DECAY := 20

const MAIN_FOCUS_FIRE_TIME := 0.05
const MAIN_FOCUS_SPEED := 1200.0
const MAIN_FOCUS_DAMAGE := 120 / (MAIN_BASE_FIRE_TIME / MAIN_FOCUS_FIRE_TIME)

const SIDE_BASE_FIRE_TIME := 0.4
const SIDE_BASE_SPEED := 600.0
const SIDE_BASE_DAMAGE := 10
const SIDE_BASE_EXTRA := 0
const SIDE_BASE_DECAY := 0

const SIDE_FOCUS_FIRE_TIME := 0.3
const SIDE_FOCUS_SPEED := 800.0
const SIDE_FOCUS_DAMAGE := 10

const ROTATION_SPEED := 120.0

const MAX_POWER_USAGE := 500
var power_usage:int

var enabled:bool = false
var shooting:bool = false

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
	var main_06 = Marker2D.new()
	
	const ZERO_SET    = Transform2D(deg_to_rad(-90), Vector2.ZERO)
	
	const MAIN_SET_01 = Transform2D(deg_to_rad(-90), Vector2( 12, -24))
	const MAIN_SET_02 = Transform2D(deg_to_rad(-90), Vector2(-12, -24))
	const MAIN_SET_03 = Transform2D(deg_to_rad(-90 + 12), Vector2( 30, -12))
	const MAIN_SET_04 = Transform2D(deg_to_rad(-90 - 12), Vector2(-30, -12))
	const MAIN_SET_05 = Transform2D(deg_to_rad(-90 + 24), Vector2( 48,   0))
	const MAIN_SET_06 = Transform2D(deg_to_rad(-90 - 24), Vector2(-48,   0))
	
	const MAIN_FOCUS_SET_01 = Transform2D(deg_to_rad(-90), Vector2( 12, -24))
	const MAIN_FOCUS_SET_02 = Transform2D(deg_to_rad(-90), Vector2(-12, -24))
	const MAIN_FOCUS_SET_03 = Transform2D(deg_to_rad(-90 +  8), Vector2( 28, -12))
	const MAIN_FOCUS_SET_04 = Transform2D(deg_to_rad(-90 -  8), Vector2(-28, -12))
	const MAIN_FOCUS_SET_05 = Transform2D(deg_to_rad(-90 + 16), Vector2( 44,   0))
	const MAIN_FOCUS_SET_06 = Transform2D(deg_to_rad(-90 - 16), Vector2(-44,   0))
	
	%MainShot.set_levels(
		[main_01, main_02, main_03, main_04, main_05, main_06],
		{
			1: {
				main_01: {
					"transform": ZERO_SET,
					"activated": true
				},
				main_02: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_03: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_04: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_05: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_06: {
					"transform": ZERO_SET,
					"activated": false
				}
			},
			2: {
				main_01: {
					"transform": MAIN_SET_01,
					"activated": true
				},
				main_02: {
					"transform": MAIN_SET_02,
					"activated": true
				},
				main_03: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_04: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_05: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_06: {
					"transform": ZERO_SET,
					"activated": false
				}
			},
			3: {
				main_01: {
					"transform": MAIN_SET_01,
					"activated": true
				},
				main_02: {
					"transform": MAIN_SET_02,
					"activated": true
				},
				main_03: {
					"transform": MAIN_SET_03,
					"activated": true
				},
				main_04: {
					"transform": MAIN_SET_04,
					"activated": true
				},
				main_05: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_06: {
					"transform": ZERO_SET,
					"activated": false
				}
			},
			4: {
				main_01: {
					"transform": MAIN_SET_01,
					"activated": true
				},
				main_02: {
					"transform": MAIN_SET_02,
					"activated": true
				},
				main_03: {
					"transform": MAIN_SET_03,
					"activated": true
				},
				main_04: {
					"transform": MAIN_SET_04,
					"activated": true
				},
				main_05: {
					"transform": MAIN_SET_05,
					"activated": true
				},
				main_06: {
					"transform": MAIN_SET_06,
					"activated": true
				}
			}
		},
		{
			1: {
				main_01: {
					"transform": ZERO_SET,
					"activated": true
				},
				main_02: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_03: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_04: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_05: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_06: {
					"transform": ZERO_SET,
					"activated": false
				}
			},
			2: {
				main_01: {
					"transform": MAIN_FOCUS_SET_01,
					"activated": true
				},
				main_02: {
					"transform": MAIN_FOCUS_SET_02,
					"activated": true
				},
				main_03: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_04: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_05: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_06: {
					"transform": ZERO_SET,
					"activated": false
				}
			},
			3: {
				main_01: {
					"transform": MAIN_FOCUS_SET_01,
					"activated": true
				},
				main_02: {
					"transform": MAIN_FOCUS_SET_02,
					"activated": true
				},
				main_03: {
					"transform": MAIN_FOCUS_SET_03,
					"activated": true
				},
				main_04: {
					"transform": MAIN_FOCUS_SET_04,
					"activated": true
				},
				main_05: {
					"transform": ZERO_SET,
					"activated": false
				},
				main_06: {
					"transform": ZERO_SET,
					"activated": false
				}
			},
			4: {
				main_01: {
					"transform": MAIN_FOCUS_SET_01,
					"activated": true
				},
				main_02: {
					"transform": MAIN_FOCUS_SET_02,
					"activated": true
				},
				main_03: {
					"transform": MAIN_FOCUS_SET_03,
					"activated": true
				},
				main_04: {
					"transform": MAIN_FOCUS_SET_04,
					"activated": true
				},
				main_05: {
					"transform": MAIN_FOCUS_SET_05,
					"activated": true
				},
				main_06: {
					"transform": MAIN_FOCUS_SET_06,
					"activated": true
				}
			}
		}
	)
	
	var side_01 = REIMU_SIDE.instantiate()
	side_01.rotation = deg_to_rad(0)
	side_01.rotation_speed = deg_to_rad(60)
	var side_02 = REIMU_SIDE.instantiate()
	side_02.rotation = deg_to_rad(90)
	side_02.rotation_speed = deg_to_rad(-60)
	var side_03 = REIMU_SIDE.instantiate()
	side_03.rotation = deg_to_rad(180)
	side_03.rotation_speed = deg_to_rad(60)
	var side_04 = REIMU_SIDE.instantiate()
	side_04.rotation = deg_to_rad(270)
	side_04.rotation_speed = deg_to_rad(-60)
	
	%SideShot.set_levels(
		[side_01, side_02, side_03, side_04],
		{
			1: {
				side_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				side_02: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				side_03: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				side_04: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				}
			},
			2: {
				side_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(20, 50)),
					"activated": true
				},
				side_02: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(-20, 50)),
					"activated": true
				},
				side_03: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				side_04: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				}
			},
			3: {
				side_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(20, 50)),
					"activated": true
				},
				side_02: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(-20, 50)),
					"activated": true
				},
				side_03: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(55, 35)),
					"activated": true
				},
				side_04: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(-55, 35)),
					"activated": true
				}
			}
		},
		{
			1: {
				side_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				side_02: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				side_03: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				side_04: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				}
			},
			2: {
				side_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(15, -55)),
					"activated": true
				},
				side_02: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(-15, -55)),
					"activated": true
				},
				side_03: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				},
				side_04: {
					"transform": Transform2D(deg_to_rad(-90), Vector2.ZERO),
					"activated": false
				}
			},
			3: {
				side_01: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(15, -55)),
					"activated": true
				},
				side_02: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(-15, -55)),
					"activated": true
				},
				side_03: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(45, -35)),
					"activated": true
				},
				side_04: {
					"transform": Transform2D(deg_to_rad(-90), Vector2(-45, -35)),
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
				REIMU_MAIN, 
				shot.global_transform, MAIN_FOCUS_SPEED,
				MAIN_FOCUS_DAMAGE, MAIN_BASE_DECAY
			)
		else:
			bullet.set_bullet(
				REIMU_MAIN, 
				shot.global_transform, MAIN_BASE_SPEED,
				(MAIN_BASE_DAMAGE + (MAIN_BASE_EXTRA * power)), MAIN_BASE_DECAY
			)
		
		GlobalStage.request_add_object.emit(bullet)
	
	%Sound_Shoot.play()


func shoot_side():
	# return
	
	if enabled == false:
		return
	
	for shot in %SideShot.get_active_shots():
		var bullet = BULLET_HOMING.instantiate()
		
		if focusing:
			bullet.set_bullet(
			REIMU_HOMING,
				shot.global_transform, SIDE_FOCUS_SPEED,
				SIDE_FOCUS_DAMAGE, SIDE_BASE_DECAY
			)
		else:
			bullet.set_bullet(
				REIMU_HOMING,
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
	if power > 0.2:
		power_usage = MAX_POWER_USAGE * clampf(power, 0.2, 1.0)
	else:
		power_usage = 0
	focus_enabled = percentage > 0.2
	check_focusing()
	
	if percentage < 0.1:
		%MainShot.change_level(1)
		%SideShot.change_level(1)
		
	elif percentage < 0.2:
		%MainShot.change_level(1)
		%SideShot.change_level(2)
		
	elif percentage < 0.3:
		%MainShot.change_level(2)
		%SideShot.change_level(2)
	
	elif percentage < 0.4:
		%MainShot.change_level(3)
		%SideShot.change_level(2)
		
	elif percentage < 0.6:
		%MainShot.change_level(3)
		%SideShot.change_level(3)
		
	else:
		%MainShot.change_level(4)
		%SideShot.change_level(3)
