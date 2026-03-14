extends Background


func background_call(method:String, _args:Dictionary={}) -> void:
	if method == "turn":
		%World.turn()
	elif method == "practice":
		%World.practice()
