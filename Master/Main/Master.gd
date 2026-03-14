extends Node2D

const MAIN_MENU := preload("res://Menu/Main/MainMenu.tscn")
const MAIN_GAME := preload("res://Game/Main/Main/MainGame.tscn")

@export var debug:bool = false

@export_group("Series")
@export var main:SeriesData
@export var extra:SeriesData
@export var phantasm:SeriesData

var save_mode:bool
var CurrentScene:Node2D
var PreviousScene:Node2D

signal load_complete




func _ready():
	GlobalSettings.set_series(main, extra, phantasm)
	Debug.debug_mode = debug
	load_menu()




func load_menu() -> void:
	var Menu = MAIN_MENU.instantiate()
	Menu.selected_game.connect(_on_Menu_selected_game)
	
	load_in(Menu)
	await self.load_complete
	
	Menu.start_menu()


func load_game(save:SaveFile) -> void:
	var Game = MAIN_GAME.instantiate()
	Game.exited_game.connect(_on_Game_exited_game)
	Game.save = save
	
	load_in(Game)
	await self.load_complete
	
	Game.start_game()


func load_in(Scene:Node2D) -> void:
	if CurrentScene:
		$LoadingScreen.load_in()
		await $LoadingScreen.load_in_done
		
		if ! save_mode:
			CurrentScene.queue_free()
			CurrentScene = Scene
		else:
			PreviousScene = CurrentScene
			PreviousScene.deactivate()
			CurrentScene = Scene
		
		self.add_child(Scene)
		await Scene.ready
		await get_tree().create_timer(0.5).timeout
		
		$LoadingScreen.load_out()
		await $LoadingScreen.load_out_done
	
	else:
		CurrentScene = Scene
		self.add_child(Scene)
		await get_tree().process_frame
	
	load_complete.emit()


func load_in_previous() -> void:
	if CurrentScene:
		$LoadingScreen.load_in()
		await $LoadingScreen.load_in_done
		
		CurrentScene.queue_free()
		CurrentScene = PreviousScene
		CurrentScene.reactivate()
		PreviousScene = null
		
		await get_tree().create_timer(0.5).timeout
		
		$LoadingScreen.load_out()
		await $LoadingScreen.load_out_done
	
	else:
		CurrentScene = PreviousScene
		CurrentScene.reactivate()
		await get_tree().process_frame
	
	load_complete.emit()




func _on_Menu_selected_game(save:SaveFile, save_mode:bool=false):
	self.save_mode = save_mode
	load_game(save)


func _on_Game_exited_game():
	self.save_mode = false
	
	if PreviousScene:
		load_in_previous()
	else:
		load_menu()
