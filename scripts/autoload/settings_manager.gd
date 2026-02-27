## 设置管理器
## 负责游戏设置的持久化存储和应用
extends Node

const SETTINGS_PATH := "user://settings.json"

## 默认设置
const DEFAULTS := {
	"bgm_volume": 0.8,       ## BGM音量 (0.0 ~ 1.0)
	"sfx_volume": 0.8,       ## SFX音量 (0.0 ~ 1.0)
	"master_volume": 1.0,    ## 主音量 (0.0 ~ 1.0)
	"bgm_muted": false,      ## BGM静音
	"sfx_muted": false,      ## SFX静音
	"screen_shake": true,    ## 屏幕震动
	"show_damage_numbers": true,  ## 显示伤害数字
	"auto_save": true,       ## 自动存档
	"text_speed": 1.0,       ## 文字速度 (0.5/1.0/2.0)
}

var _settings: Dictionary = {}


func _ready() -> void:
	_settings = DEFAULTS.duplicate()
	load_settings()
	apply_all()


## ========== 读写 ==========

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return
	var data: Variant = json.data
	if data is Dictionary:
		for key: String in DEFAULTS:
			if data.has(key):
				_settings[key] = data[key]


func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SettingsManager: 无法保存设置文件")
		return
	file.store_string(JSON.stringify(_settings, "\t"))


## ========== 通用访问 ==========

func get_setting(key: String) -> Variant:
	return _settings.get(key, DEFAULTS.get(key))


func set_setting(key: String, value: Variant) -> void:
	_settings[key] = value


## ========== 音量 ==========

func get_master_volume() -> float:
	return float(_settings.get("master_volume", 1.0))

func set_master_volume(value: float) -> void:
	_settings["master_volume"] = clampf(value, 0.0, 1.0)
	_apply_volume("Master", value)

func get_bgm_volume() -> float:
	return float(_settings.get("bgm_volume", 0.8))

func set_bgm_volume(value: float) -> void:
	_settings["bgm_volume"] = clampf(value, 0.0, 1.0)
	var muted: bool = _settings.get("bgm_muted", false)
	_apply_volume("BGM", 0.0 if muted else value)

func get_sfx_volume() -> float:
	return float(_settings.get("sfx_volume", 0.8))

func set_sfx_volume(value: float) -> void:
	_settings["sfx_volume"] = clampf(value, 0.0, 1.0)
	var muted: bool = _settings.get("sfx_muted", false)
	_apply_volume("SFX", 0.0 if muted else value)

func is_bgm_muted() -> bool:
	return bool(_settings.get("bgm_muted", false))

func set_bgm_muted(muted: bool) -> void:
	_settings["bgm_muted"] = muted
	_apply_volume("BGM", 0.0 if muted else get_bgm_volume())

func is_sfx_muted() -> bool:
	return bool(_settings.get("sfx_muted", false))

func set_sfx_muted(muted: bool) -> void:
	_settings["sfx_muted"] = muted
	_apply_volume("SFX", 0.0 if muted else get_sfx_volume())


## ========== 游戏选项 ==========

func is_screen_shake_enabled() -> bool:
	return bool(_settings.get("screen_shake", true))

func is_damage_numbers_enabled() -> bool:
	return bool(_settings.get("show_damage_numbers", true))

func is_auto_save_enabled() -> bool:
	return bool(_settings.get("auto_save", true))

func get_text_speed() -> float:
	return float(_settings.get("text_speed", 1.0))


## ========== 应用 ==========

func apply_all() -> void:
	_apply_volume("Master", get_master_volume())
	var bgm_muted := is_bgm_muted()
	_apply_volume("BGM", 0.0 if bgm_muted else get_bgm_volume())
	var sfx_muted := is_sfx_muted()
	_apply_volume("SFX", 0.0 if sfx_muted else get_sfx_volume())


func _apply_volume(bus_name: String, linear: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		return
	if linear <= 0.001:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear))
