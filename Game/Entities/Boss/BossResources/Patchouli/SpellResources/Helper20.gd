extends Node2D

var direction:Vector2
var speed:float

var turn:float
var turn_delay:float
var turn_time:float
var turn_max:float

var hue:float
var sat:float
const HUE_DELAY := 0.4
const HUE_TIME  := 0.8




func _ready() -> void:
	direction = self.transform.x
	hue = 0.166
	sat = 0.0
	
	var ColorTween = self.create_tween()
	ColorTween.tween_property(self, "sat", 1, HUE_DELAY)
	ColorTween.tween_property(self, "hue", 0, HUE_TIME)
	
	var TurnTween = self.create_tween()
	TurnTween.tween_interval(turn_delay)
	TurnTween.tween_property(self, "turn", turn_max, turn_time)


func _process(delta):
	self.position += direction * speed * delta
	
	direction += transform.y * turn * delta
	direction = direction.normalized()
	
	self.rotation = direction.angle()
	%Sprite.modulate = Color.from_hsv(hue, sat, 1, 1)




func build(
		bullet_data:BulletData,
		bullet_speed:float,
		turn_delay:float,
		turn_time:float,
		turn_max:float,
	) -> void:
	
	%BulletDull.data = bullet_data
	self.speed       = bullet_speed
	self.turn_delay  = turn_delay
	self.turn_time   = turn_time
	self.turn_max    = turn_max




func _on_BulletDull_bullet_deactivate() -> void:
	queue_free()
