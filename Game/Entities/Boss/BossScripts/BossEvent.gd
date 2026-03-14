extends Resource
class_name BossEvent

enum TYPE {
	DIALOGUE,
	NON,
	SPELL
}

signal event_ended




func get_type() -> int:
	return -1
