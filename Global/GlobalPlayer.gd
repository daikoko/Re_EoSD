extends Node

## Global script to interact with the player object

## Pointer to the player object
## Assigned by the player object in _ready()
var player:Player

## Signal bus
## Called by object when they hit/graze the player
signal player_hit
signal player_graze

## Signal bus
## Manage player state
signal player_death
signal player_respawned
signal player_over
signal player_continued
signal player_quit

## Signal bus
## Called by player shot type objects
signal player_used_flash(spell_name)
signal player_used_bomb(spell_name)
signal player_used_bomb_stop
signal player_used_power

## Signal bus
## Called by item objects when collected
signal life_get
signal bomb_get
signal point_get(value)
signal power_get(value)
signal score_get(value, mode)

## Signal bus
## Related to bosses
signal spellcard_passed(captured)
signal bonus_spell_get(value)
signal bonus_graze_get(value)
signal bonus_clear_get(value)

## Signal bus
## Called when various stats are changed
signal updated_bomb(avaliable)
signal updated_graze(avaliable)
signal updated_power(percentage)




## -------------------------- ##
## ---- PUBLIC FUNCTIONS ---- ##
## -------------------------- ##


## Set the current player object
## Called by player object
func set_player(player:Player) -> void:
	self.player = player


func set_player_position(position:Vector2) -> void:
	player.global_position = position


## Get the player's global position
func get_player_position() -> Vector2:
	return player.global_position


## From a position, get the direction vector to the player object
func angle_to_player(position:Vector2) -> float:
	return position.angle_to_point(get_player_position())


func angle_to_player_degrees(position:Vector2) -> float:
	return rad_to_deg(position.angle_to_point(get_player_position()))


func direction_to_player(position:Vector2) -> Vector2:
	return position.direction_to(get_player_position())


func distance_to_player(position:Vector2) -> float:
	return position.distance_to(get_player_position())


func move_player(position:Vector2) -> void:
	player.position = position
