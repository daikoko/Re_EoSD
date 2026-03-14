extends Node2D

const PARTICLES := preload("res://Game/Entities/Boss/BossResources/_General/Death/Particles_BossMinor.tres")

var color:Color




func set_color(color:Color):
	self.color = color


func start():
	var particle = PARTICLES.create_particle(global_position)
	particle.modulate = color
	GlobalStage.request_add_object.emit(particle)
