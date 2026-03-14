extends Background


func background_call(method:String, args:Dictionary={}) -> void:
	if method == "density":
		%World.raise_density(args["density"], args["time"])
	elif method == "practice":
		%World.practice()
