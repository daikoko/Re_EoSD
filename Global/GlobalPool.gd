extends Node

signal bullet_gravity_spawned(
	data, transform, 
	speed, rot, rot_speed,
	gravity,
	flash_scale, flash_time, immunity_time
)
signal bullet_gravity_despawned(id)

signal bullet_linear_spawned(
	data, transform, 
	speed, dir, rot, rot_speed,
	delay, duration, speed_change, dir_change,
	flash_scale, flash_time, immunity_time
)
signal bullet_linear_despawned(id)

signal bullet_sine_spawned(
	data, transform, 
	speed, amplitude, compression,
	flash_scale, flash_time, immunity_time
)
signal bullet_sine_despawned(id)

signal bullet_tween_spawned(
	data, transform,
	tween_origin, tween_offset, tween_ratio, tween_rotation_start, 
	tween_time, tween_distance, tween_rotation, tween_reverse,
	bullet_dircet, bullet_rotation_start, bullet_rotation,
	release_speed, release_angle, release_aim,
	flash_scale, flash_time, immunity_time
)
signal bullet_tween_despawned(id)

signal item_life_spawned(transform)
signal item_bomb_spawned(transform)

signal item_point_spawned(transform, bullet)
signal item_point_despawned(id)

signal item_power_spawned(transform)
signal item_power_despawned(id)

signal item_score_spawned(transform, value, mode)
signal item_score_despawned(id)

signal particle_clear_spawned(position)
signal particle_bomb_spawned(position, color)
signal particle_despawned(id)
