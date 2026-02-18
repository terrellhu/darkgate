## 主菜单场景
extends Control


func _ready() -> void:
	%BtnNewGame.pressed.connect(_on_new_game)
	%BtnContinue.pressed.connect(_on_continue)
	%BtnSettings.pressed.connect(_on_settings)

	# 检查是否有存档来决定"继续"按钮是否可用
	%BtnContinue.disabled = not SaveManager.has_save(0)


func _on_new_game() -> void:
	PlayerData.init_new_game()
	GameManager.change_state(GameManager.GameState.HUB)


func _on_continue() -> void:
	if SaveManager.load_game(0):
		GameManager.change_state(GameManager.GameState.HUB)


func _on_settings() -> void:
	# TODO: 打开设置面板
	pass
