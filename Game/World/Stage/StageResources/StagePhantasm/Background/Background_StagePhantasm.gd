extends Background


func background_call(method:String, _args:Dictionary={}) -> void:
	if method == "reverse":
		%World.reverse()
	elif method == "practice":
		%World.practice()
