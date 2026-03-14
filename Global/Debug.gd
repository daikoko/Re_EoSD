extends CanvasLayer

var debug_mode:bool = false

var hits:int = 0
var graze:int = 0

var bullets:int = 0
var bullets_gravity:int = 0
var bullets_linear:int = 0
var bullets_tween:int = 0
var bullets_sine:int = 0
var bullets_dull:int = 0

var lasers:int = 0

var score_items:int  = 0
var score_bullet:int = 0
var score_enemy:int  = 0
var score_boss:int   = 0
var score_spell:int  = 0
var score_graze:int  = 0
var score_clear:int  = 0
var score_total:int  = 0




func _process(_delta):
	%FPS.text = str(Engine.get_frames_per_second())




func hide_all():
	self.hide()


func show_all():
	self.show()


func add_hit() -> void:
	hits += 1
	%Hits.text = str(hits)


func add_graze() -> void:
	graze += 1
	%Graze.text = str(graze)


func update_bullets(value:int) -> void:
	bullets += value
	%Bullets.text = str(bullets)
	if debug_mode == false:
		if bullets == 0:
			%BulletBox.hide()
		else:
			%BulletBox.show()


func update_gravity(value:int) -> void:
	bullets_gravity += value
	%GravityBullets.text = str(bullets_gravity)
	update_bullets(value)


func update_linear(value:int) -> void:
	bullets_linear += value
	%LinearBullets.text = str(bullets_linear)
	update_bullets(value)


func update_tween(value:int) -> void:
	bullets_tween += value
	%TweenBullets.text = str(bullets_tween)
	update_bullets(value)


func update_sine(value:int) -> void:
	bullets_sine += value
	%SineBullets.text = str(bullets_sine)
	update_bullets(value)


func update_dull(value:int) -> void:
	bullets_dull += value
	%DullBullets.text = str(bullets_dull)
	update_bullets(value)


func update_lasers(value:int) -> void:
	lasers += value
	%Lasers.text = str(lasers)
	if debug_mode == false:
		if lasers == 0:
			%LaserBox.hide()
		else:
			%LaserBox.show()


func update_score_items(value:int) -> void:
	score_items += value
	score_total += value


func update_score_bullet(value:int) -> void:
	score_bullet += value
	score_total += value


func update_score_enemy(value:int) -> void:
	score_enemy += value
	score_total += value


func update_score_boss(value:int) -> void:
	score_boss += value
	score_total += value


func update_score_spell(value:int) -> void:
	score_spell += value
	score_total += value


func update_score_graze(value:int) -> void:
	score_graze += value
	score_total += value


func update_score_clear(value:int) -> void:
	score_clear += value
	score_total += value


func display_score() -> void:
	pass
	
	#print("=== Score Breakdown ===")
	#
	#if score_total == 0:
		#print("ERROR: No Score")
		#print(" ")
	#else:
		#print("Items:  ", round((score_items  / float(score_total)) * 100), "% (", score_items,  ")")
		#print("Bullet: ", round((score_bullet / float(score_total)) * 100), "% (", score_bullet, ")")
		#print("Enemy:  ", round((score_enemy  / float(score_total)) * 100), "% (", score_enemy,  ")")
		#print("Boss:   ", round((score_boss   / float(score_total)) * 100), "% (", score_boss,   ")")
		#print("Spells: ", round((score_spell  / float(score_total)) * 100), "% (", score_spell,  ")")
		#print("Graze:  ", round((score_graze  / float(score_total)) * 100), "% (", score_graze,  ")")
		#print("Clear:  ", round((score_clear  / float(score_total)) * 100), "% (", score_clear,  ")")
		#print(" ")


func show_debug() -> void:
	%BulletList.show()
	if debug_mode == false:
		%Drop.hide()
		%BulletBox.hide()
		%GravityBulletBox.hide()
		%LinearBulletBox.hide()
		%SineBulletBox.hide()
		%TweenBulletBox.hide()
		%DullBulletBox.hide()
		%LaserBox.hide()
		%GameList.hide()
	else:
		%Drop.show()
		%BulletBox.show()
		%GravityBulletBox.show()
		%LinearBulletBox.show()
		%SineBulletBox.show()
		%TweenBulletBox.show()
		%DullBulletBox.show()
		%LaserBox.show()
		%GameList.show()


func hide_debug() -> void:
	%Drop.hide()
	%BulletList.hide()
	%GameList.hide()


func reset_debug() -> void:
	hits = 0
	graze = 0
	
	bullets = 0
	bullets_gravity = 0
	bullets_linear = 0
	bullets_tween = 0
	bullets_sine = 0
	bullets_dull = 0
	lasers = 0
	
	score_items  = 0
	score_bullet = 0
	score_enemy  = 0
	score_boss   = 0
	score_spell  = 0
	score_bullet = 0
	score_clear  = 0
	score_total  = 0
	
	%Hits.text =           "0"
	%Graze.text =          "0"
	%Bullets.text =        "0"
	%GravityBullets.text = "0"
	%LinearBullets.text =  "0"
	%TweenBullets.text =   "0"
	%SineBullets.text =    "0"
	%DullBullets.text =    "0"
	%Lasers.text =         "0"
