## 主菜单背景漂浮粒子
extends Control

const COUNT := 40

var _particles: Array[Dictionary] = []
var _time: float = 0.0


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var s := _screen_size()
	for i: int in COUNT:
		_particles.append(_new_particle(s, true))


func _process(delta: float) -> void:
	_time += delta
	var s := _screen_size()
	for p: Dictionary in _particles:
		p["x"] += p["vx"] * delta + sin(_time * 0.6 + p["phase"]) * 0.4
		p["y"] += p["vy"] * delta
		p["life"] += delta * 0.1
		if p["y"] < -10.0 or p["life"] >= 1.0:
			p.merge(_new_particle(s, false), true)
	queue_redraw()


func _draw() -> void:
	for p: Dictionary in _particles:
		var a: float = (1.0 - p["life"]) * 0.35
		draw_circle(Vector2(p["x"], p["y"]), p["size"], Color(p["r"], p["g"], p["b"], a))


func _new_particle(screen: Vector2, scatter: bool) -> Dictionary:
	return {
		"x": randf() * screen.x,
		"y": (randf() * screen.y) if scatter else (screen.y + randf() * 20.0),
		"vx": randf_range(-8.0, 8.0),
		"vy": randf_range(-30.0, -10.0),
		"size": randf_range(1.0, 3.0),
		"r": randf_range(0.55, 0.85),
		"g": randf_range(0.04, 0.15),
		"b": randf_range(0.02, 0.08),
		"phase": randf() * TAU,
		"life": randf() if scatter else 0.0,
	}


func _screen_size() -> Vector2:
	return size if size.x > 0.0 else Vector2(720, 1280)
