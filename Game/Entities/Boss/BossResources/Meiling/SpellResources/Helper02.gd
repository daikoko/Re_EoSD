extends Node2D

const POINTER := preload("res://Game/Objects/Shooters/Shooter/Pointer.tscn")


func build_basic() -> Array:
	var spawner_map = []
	var column = []
	for marker in get_children():
		var pointer = POINTER.instantiate()
		pointer.transform = marker.transform
		column.append(pointer)
	
	spawner_map.append(column)
	return spawner_map


func get_a_bullets() -> RowData:
	var bullets = RowData_Column.new([
		ColumnData_Bullet.new([
			GlobalShooter.SPADE_YELLOW,
			GlobalShooter.SPADE_RED,
			GlobalShooter.SPADE_RED,
			GlobalShooter.SPADE_RED,
			GlobalShooter.SPADE_YELLOW,
			
			GlobalShooter.SPADE_RED,
			GlobalShooter.SPADE_YELLOW,
			
			GlobalShooter.SPADE_RED,
			GlobalShooter.SPADE_YELLOW,
			
			GlobalShooter.SPADE_GREEN,
			GlobalShooter.SPADE_CYAN,
			GlobalShooter.SPADE_BLUE,
			GlobalShooter.SPADE_MAGENTA,
			GlobalShooter.SPADE_BLUE,
			GlobalShooter.SPADE_CYAN,
			GlobalShooter.SPADE_GREEN,
		])
	])
	
	return bullets
