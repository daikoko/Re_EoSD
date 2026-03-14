extends Button

var data:Dictionary

signal data_return(button)




func set_option_name(option_name:String) -> void:
	self.text = " " + option_name


func set_option_name_numbered(option_name:String, num:int) -> void:
	self.text = " " + str(num) + ". "+ option_name


func set_option_data(data:Dictionary) -> void:
	self.data = data


func get_option_data() -> Dictionary:
	return self.data




func _on_SelectPracticeButton_pressed() -> void:
	data_return.emit(self)
