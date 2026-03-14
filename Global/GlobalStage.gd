extends Node
## Global script to interact with the level

const ZERO := 0
const ONE  := 1

## Enumerations for difficulty scaling
var MODIFIER_SPAWN := {
	GlobalSettings.DIFFICULTY.EASY: {
		"amount": 0.75,
		"health": 1.0
	},
	GlobalSettings.DIFFICULTY.NORMAL: {
		"amount": 1.0,
		"health": 1.0
	},
	GlobalSettings.DIFFICULTY.HARD: {
		"amount": 1.1,
		"health": 1.0
	},
	GlobalSettings.DIFFICULTY.LUNATIC: {
		"amount": 1.2,
		"health": 1.2
	},
	GlobalSettings.DIFFICULTY.EXTRA: {
		"amount": 1.0,
		"health": 1.0
	},
	GlobalSettings.DIFFICULTY.PHANTASM: {
		"amount": 1.0,
		"health": 1.0
	},
	GlobalSettings.DIFFICULTY.PRACTICE: {
		"amount": 1.0,
		"health": 1.0
	}
}

var MODIFIER_SHOOTER := {
	GlobalSettings.DIFFICULTY.EASY: {
		"fire":    0.8,
		"spawner": 0.8,
		"shape":   0.8,
		"arrow":   0.8
	},
	GlobalSettings.DIFFICULTY.NORMAL: {
		"fire":    1,
		"spawner": 1,
		"shape":   1,
		"arrow":   1
	},
	GlobalSettings.DIFFICULTY.HARD: {
		"fire":    1.1,
		"spawner": 1.1,
		"shape":   1.1,
		"arrow":   1.1
	},
	GlobalSettings.DIFFICULTY.LUNATIC: {
		"fire":    1.2,
		"spawner": 1.2,
		"shape":   1.2,
		"arrow":   1.2
	},
	GlobalSettings.DIFFICULTY.EXTRA: {
		"fire":    1,
		"spawner": 1,
		"shape":   1,
		"arrow":   1
	},
	GlobalSettings.DIFFICULTY.PHANTASM: {
		"fire":    1,
		"spawner": 1,
		"shape":   1,
		"arrow":   1
	},
	GlobalSettings.DIFFICULTY.PRACTICE: {
		"fire":    1,
		"spawner": 1,
		"shape":   1,
		"arrow":   1
	}
}

const BONUS := {
	"extra_graze":         1000,
	"lives_lost":          1000,
	"bombs_used":          500,
	"continues_used":      5000,
	"spellcards_captured": 0.5,
}

const VIEWPORT_SIZE := Vector2(680, 780)
const PLAYER_DEFAULT_POSITION := Vector2(340, 650)
const BOSS_DEFAULT_POSITION := Vector2(340, 200)
const MAX_DIAGONAL := 1050.0

var current_section:int
var current_difficulty:int
var current_player:int
var current_shot:int
var player_default_position = PLAYER_DEFAULT_POSITION

## States for any active clears/bombs
var current_stage_clear:bool
var current_stage_clear_plain:bool
var current_stage_bomb:bool
var current_player_bomb:int

var global_rng:RandomNumberGenerator

signal stage_reset

## Add objects to the level scene
signal request_add_object(object)
signal request_add_object_path(object, index)
signal request_add_background(background)
signal request_add_portrait(portrait)

## Dialogue
signal request_dialogue(dialogue_name, script, shot_enable)
signal dialogue_start(shot_enable)
signal dialogue_end

## Boss
signal boss_hit(damage)
signal boss_hit_passed
signal boss_heal_passed
signal boss_end_phase
signal boss_end

##
signal stage_progress_update(value)

# Shake
signal request_shake(amplitude, duration, hold)
signal request_shake_release

## Slowdown
signal request_slow
signal request_slow_release

# Stop
signal request_stop
signal request_stop_reload
signal request_stop_release

## Music
signal request_music_play(music)
signal request_music_stop
signal request_music_pause
signal request_music_resume




func _ready():
	global_rng = RandomNumberGenerator.new()



## -------------------------- ##
## ---- PUBLIC FUNCTIONS ---- ##
## -------------------------- ##


## Set the rng seed
## If set to the default value, use time based seed
func set_rng_seed(level_seed:int=-1) -> void:
	if level_seed == -1:
		global_rng.randomize()
	else:
		global_rng.seed = level_seed


## Create a timer with preset parameters
func create_timer(parent:Node, wait_time:float=1, one_shot:bool=true) -> Timer:
	if wait_time == 0:
		return null
	
	var timer = ObjectTimer.new()
	timer.wait_time = wait_time
	timer.one_shot = one_shot
	
	parent.add_child(timer)
	
	return timer


## Create a timer with preset parameters
func create_timer_short(parent:Node, wait_time:float=1) -> Timer:
	if wait_time == 0:
		return null
	
	var timer = ShortTimer.new()
	timer.wait_time = wait_time
	timer.autostart = true
	
	parent.add_child(timer)
	
	return timer


func create_dummy_node() -> Node2D:
	var dummy = Node2D.new()
	self.add_child(dummy)
	return dummy



## Get a random range
## Can set a custom rng resource (for spellcards) 
## or use the level rng by default
func random_range(start:float=0, end:float=0, rng:RandomNumberGenerator=null) -> float:
	if end < start:
		return start
	
	if rng == null:
		rng = global_rng
	
	return rng.randf_range(start, end)


## Get a random range between 0 and 6.28 rad
## Can set a custom rng resource (for spellcards) 
## or use the level rng by default
func random_angle(start:float=0, end:float=TAU, rng:RandomNumberGenerator=null) -> float:
	# if end < start:
	# 	return start
	
	if rng == null:
		rng = global_rng
	
	var rand = rng.randf_range(start, end)
	
	return rand


## Get a random position in within a bounding rectangle
## and a certain distance from a starting position
## Can set a custom rng resource (for spellcards) 
## or use the level rng by default
func random_position(bound_right:float, bound_left:float, bound_top:float, bound_bottom:float, 
	pos:Vector2, distance:float, RNG:RandomNumberGenerator=null) -> Vector2:
	
	var tries = 5
	for i in tries:
		var rand_rad = RNG.randf_range(0, TAU)
		var rand_pos = pos + (Vector2.RIGHT * distance).rotated(rand_rad)
		if rand_pos.x < bound_right and rand_pos.x > bound_left and rand_pos.y > bound_top and rand_pos.y < bound_bottom:
			return rand_pos
	
	var center := Vector2(
		bound_left + ((bound_right-bound_left)/2),
		bound_top + ((bound_bottom-bound_top)/2)
	)
	var direction = (center - pos).normalized()
	var default_pos = pos + (direction * distance)
	return default_pos


func toggle_stage_clear(toggle:bool) -> void:
	current_stage_clear = toggle


func is_current_stage_clear() -> bool:
	return current_stage_clear


func toggle_stage_clear_plain(toggle:bool) -> void:
	current_stage_clear_plain = toggle


func is_current_stage_clear_plain() -> bool:
	return current_stage_clear_plain


func toggle_stage_bomb(toggle:bool) -> void:
	current_stage_bomb = toggle


func is_current_stage_bomb() -> bool:
	return current_stage_bomb


func player_bomb_activate() -> void:
	current_player_bomb += 1


func player_bomb_deactivate() -> void:
	current_player_bomb -= 1


func is_current_player_bomb() -> bool:
	return current_player_bomb != 0


func reset_states() -> void:
	current_stage_clear =       false
	current_stage_clear_plain = false
	current_stage_bomb =        false
	current_player_bomb =       0


## Get difficulty scaling for enemy spawn
func get_spawn_modifier(key:String) -> float:
	return MODIFIER_SPAWN[current_difficulty][key]


## Get difficulty scaling for enemy shooters
func get_shooter_modifier(key:String) -> float:
	return MODIFIER_SHOOTER[current_difficulty][key]


func get_player_default_position() -> Vector2:
	return player_default_position


func change_player_default_position(player_position:Vector2):
	player_default_position = player_position


func reset_player_default_position():
	player_default_position = PLAYER_DEFAULT_POSITION
