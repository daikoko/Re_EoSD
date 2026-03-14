extends Button




func set_record(rank:int, record:RecordFile) -> void:
	%Rank.text =       str(rank)
	%Name.text =       record.name
	%Character.text =  record.character
	%Difficulty.text = record.difficulty
	%Stage.text =      record.highest_stage
	%Score.text =      str(record.score)
	%Date.text =       record.date
	
	%Score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	%Date.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


func set_label_rank(string:String) -> void:
	%Rank.text = string


func set_label_name(string:String) -> void:
	%Name.text = string


func set_label_character(string:String) -> void:
	%Character.text = string


func set_label_difficulty(string:String) -> void:
	%Difficulty.text = string


func set_label_stage(string:String) -> void:
	%Stage.text = string


func set_label_score(string:String) -> void:
	%Score.text = string


func set_label_date(string:String) -> void:
	%Date.text = string
