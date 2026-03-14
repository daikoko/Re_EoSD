extends Button



func set_record(rank:int, record:RecordFile) -> void:
	%Rank.text =       str(rank)
	%Name.text =       record.name
	%Stage.text =      record.highest_stage
	%Score.text =      str(record.score)


func set_rank(rank:int) -> void:
	%Rank.text = str(rank)
