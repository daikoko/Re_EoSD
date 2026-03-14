extends Label
class_name ItemScore

const TARGET := Vector2(840, 172)

const DELAY := 0.6
const DELAY_RANGE := 0.2
const TIME := 1.0
const TIME_RANGE := 0.5

var id: int = 0
var value: float = 0
var mode:int = 0

var delay_offset:float
var time_offset:float

var LabelTween:Tween


func _ready():
	visible = false


func _process(_delta):
	if GlobalStage.is_current_stage_clear_plain():
		deactivate()


func activate(position:Vector2, value:int, mode:int) -> void:
	self.position = position
	self.value = value
	self.mode = mode
	visible = true
	set_process(true)
	
	text = "+" + str(value) + " pts"
	position.x -= (size.x / 2)
	position.y -= (size.y / 2)
	
	LabelTween = self.create_tween()
	LabelTween.finished.connect(_on_tweener_finished)
	LabelTween.tween_interval(DELAY + delay_offset)
	LabelTween.tween_property(self, "position", TARGET, TIME + TIME_RANGE)


func deactivate():
	GlobalPool.item_score_despawned.emit(id)
	visible = false
	set_process(false)
	
	if LabelTween:
		LabelTween.kill()




func _on_tweener_finished():
	GlobalPlayer.score_get.emit(value, mode)
	deactivate()
