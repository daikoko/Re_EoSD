extends CanvasLayer

func background_call(method:String, args:Dictionary={}) -> void:
	if method == "raise":
		%World.raise(args["time"])
