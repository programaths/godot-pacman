extends Area2D
tool

onready var tween=$Tween
export var target_tilemap:NodePath
onready var tilemap:TileMap=get_node(target_tilemap)

enum Dir{UP,DOWN,LEFT,RIGHT,NONE}

var moving_to = Dir.NONE
var speed = 1.0/8.0

var ghost_scr=preload("res://Ghost.gd")

func _ready():
	connect("area_entered",self,"coillision")
	
func coillision(what:Area2D):
	if what is ghost_scr:
		get_tree().reload_current_scene()

func _draw():
	match moving_to:
		Dir.UP:
			draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		Dir.RIGHT:
			draw_set_transform(Vector2.ZERO,TAU/4,Vector2.ONE)
		Dir.DOWN:
			draw_set_transform(Vector2.ZERO,TAU/2,Vector2.ONE)
		Dir.LEFT:
			draw_set_transform(Vector2.ZERO,TAU*3/4,Vector2.ONE)
	if moving_to==Dir.NONE:
		draw_circle(Vector2.ZERO,16,Color.yellow)
	else:
		draw_circle_arc_poly(Vector2.ZERO,16,360-(sin(OS.get_ticks_msec()*TAU/1000.0)*0.5+0.5)*60,(sin(OS.get_ticks_msec()*TAU/1000.0)*0.5+0.5)*60,Color.yellow)


func _process(delta):
	update()
	if Engine.editor_hint: return
	if tween.is_active(): return
	
	var desired_direction=moving_to
	if Input.is_action_pressed("move_right"):
		if is_free(global_position+Vector2.RIGHT*32):
			desired_direction=Dir.RIGHT
	if Input.is_action_pressed("move_left"):
		if is_free(global_position+Vector2.LEFT*32):
			desired_direction=Dir.LEFT
	if Input.is_action_pressed("move_up"):
		if is_free(global_position+Vector2.UP*32):
			desired_direction=Dir.UP
	if Input.is_action_pressed("move_down"):
		if is_free(global_position+Vector2.DOWN*32):
			desired_direction=Dir.DOWN
		
	match desired_direction:
		Dir.UP:
			if is_free(global_position+Vector2.UP*32):
				moving_to=desired_direction
				tween.interpolate_property(self,"position:y",position.y,position.y-32,speed)
				tween.start()
				return
		Dir.DOWN:
			if is_free(global_position+Vector2.DOWN*32):
				moving_to=desired_direction
				tween.interpolate_property(self,"position:y",position.y,position.y+32,speed)
				tween.start()
				return
		Dir.LEFT:
			if is_free(global_position+Vector2.LEFT*32):
				moving_to=desired_direction
				tween.interpolate_property(self,"position:x",position.x,position.x-32,speed)
				tween.start()
				return
		Dir.RIGHT:
			if is_free(global_position+Vector2.RIGHT*32):
				moving_to=desired_direction
				tween.interpolate_property(self,"position:x",position.x,position.x+32,speed)
				tween.start()
				return
	moving_to=Dir.NONE

func is_free(pos:Vector2)->bool:
	var local_position = tilemap.to_local(pos)
	var map_position = tilemap.world_to_map(local_position)
	return tilemap.get_cellv(map_position)==TileMap.INVALID_CELL
	
func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)
