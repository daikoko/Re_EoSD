extends Resource
class_name ParticleData
## Contains data for automated particles

const PARTICLE := preload("res://Game/Objects/Particles/Particles.tscn")

@export_group("Amount")
@export_range(0.1,5,0.1,"or_greater") var lifetime:float = 1
@export_range(1,100,1,"or_greater") var amount:int = 1

@export_group("Material")
@export var texture:Texture2D
@export var modulate:Color = Color(1,1,1,1)
@export var material:ParticleProcessMaterial
@export var z_index:int = 20

@export_group("OneShot")
@export var one_shot:bool




func create_particle(position:Vector2=Vector2.ZERO) -> GPUParticles2D:
	var particle = PARTICLE.instantiate()
	particle.position = position
	particle.lifetime = lifetime
	particle.amount = amount
	particle.texture = texture
	particle.modulate = modulate
	particle.process_material = material
	particle.z_index = z_index
	particle.z_as_relative = false
	
	if one_shot:
		particle.one_shot = true
		particle.explosiveness = 1
	
	return particle
