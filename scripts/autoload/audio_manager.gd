## 音频管理器
## 负责BGM和SFX的播放控制
extends Node

var _bgm_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []

const MAX_SFX_CHANNELS := 8
const BGM_FADE_DURATION := 1.0

var _bgm_tween: Tween


func _ready() -> void:
	# 初始化BGM播放器
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "BGM"
	add_child(_bgm_player)

	# 初始化SFX播放器池
	for i in MAX_SFX_CHANNELS:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)


## 播放背景音乐（带淡入淡出）
func play_bgm(stream: AudioStream, fade_in: bool = true) -> void:
	if _bgm_player.stream == stream and _bgm_player.playing:
		return

	if _bgm_tween:
		_bgm_tween.kill()

	if _bgm_player.playing and fade_in:
		# 淡出当前BGM
		_bgm_tween = create_tween()
		_bgm_tween.tween_property(_bgm_player, "volume_db", -80.0, BGM_FADE_DURATION)
		_bgm_tween.tween_callback(func():
			_bgm_player.stream = stream
			_bgm_player.volume_db = -80.0
			_bgm_player.play()
			# 淡入新BGM
			_bgm_tween = create_tween()
			_bgm_tween.tween_property(_bgm_player, "volume_db", 0.0, BGM_FADE_DURATION)
		)
	else:
		_bgm_player.stream = stream
		_bgm_player.volume_db = 0.0
		_bgm_player.play()


## 停止BGM
func stop_bgm(fade_out: bool = true) -> void:
	if not _bgm_player.playing:
		return

	if fade_out:
		if _bgm_tween:
			_bgm_tween.kill()
		_bgm_tween = create_tween()
		_bgm_tween.tween_property(_bgm_player, "volume_db", -80.0, BGM_FADE_DURATION)
		_bgm_tween.tween_callback(_bgm_player.stop)
	else:
		_bgm_player.stop()


## 播放音效
func play_sfx(stream: AudioStream) -> void:
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.play()
			return
	# 所有通道都在播放，复用第一个
	_sfx_players[0].stream = stream
	_sfx_players[0].play()
