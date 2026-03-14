extends CanvasLayer


func background_call(method:String, args:Dictionary={}) -> void:
	if method == "approach":
		%Backdrop.approach(args["mansion"], args["wall"], args["time"])
