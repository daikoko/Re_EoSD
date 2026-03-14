extends Background




func background_call(method:String, _args:Dictionary={}) -> void:
	if method == "pan_up":
		%World.pan_up()
