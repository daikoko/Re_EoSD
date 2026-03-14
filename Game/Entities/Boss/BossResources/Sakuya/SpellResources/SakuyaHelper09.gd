extends Node2D

const LENGTH := 2000.0

var distance_change:float




func set_up(spawner_count:int):
	distance_change = LENGTH / spawner_count


func locate_next() -> Transform2D:
	var transform = %Follow.global_transform
	%Follow.progress += distance_change
	
	return transform


func reset():
	%Follow.progress =0
