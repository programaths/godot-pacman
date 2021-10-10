extends Area2D
tool

export var target_tilemap:NodePath
onready var tilemap=get_node(target_tilemap)

export var target_chompman:NodePath
onready var chompman=get_node(target_chompman)

onready var tween=$Tween
onready var timer=$Timer

var astar:AStar2D=AStar2D.new()
var speed = 1.0/5.0

enum Mode{SCATTER,CHASE}

var mode=Mode.CHASE

var chase_time=6
var scatter_time=3
export var scatter_position:Vector2=Vector2.ZERO
export var color:Color=Color.white

func _draw():
	draw_rect(Rect2(Vector2(-8,-8),Vector2(16,16)),color)

func _ready():
	if Engine.editor_hint: return
	for row in range(18):
		for col in range(32):
			var pos=Vector2(col,row)
			if is_free(pos):
				astar.add_point(cell_to_id(pos),pos)
	for row in range(18):
		for col in range(32):
			var pos=Vector2(col,row)
			if is_free(pos):
				var pos_id=cell_to_id(pos)
				if is_free(pos+Vector2.UP):
					astar.connect_points(cell_to_id(pos+Vector2.UP),pos_id)
				if is_free(pos+Vector2.DOWN):
					astar.connect_points(cell_to_id(pos+Vector2.DOWN),pos_id)
				if is_free(pos+Vector2.LEFT):
					astar.connect_points(cell_to_id(pos+Vector2.LEFT),pos_id)
				if is_free(pos+Vector2.RIGHT):
					astar.connect_points(cell_to_id(pos+Vector2.RIGHT),pos_id)
	timer.start(chase_time)
	timer.connect("timeout",self,"change_mmode")

func change_mmode():
	if mode==Mode.CHASE:
		mode=Mode.SCATTER
	else:
		mode=Mode.CHASE
	if mode==Mode.CHASE:
		timer.start(chase_time)
	else:
		timer.start(scatter_time)

func _process(delta):
	if Engine.editor_hint: return
	if tween.is_active(): return
	var target = scatter_position
	if mode==Mode.CHASE:
		target=player_pos()
	var path:PoolVector2Array=astar.get_point_path(cell_to_id(my_pos()),cell_to_id(target))
	if path.size()>1:
		tween.interpolate_property(self,"position",position,path[1]*32,speed)
		tween.start()

func cell_to_id(pos:Vector2):
	return pos.y*32+pos.x

func id_to_cell(id:int):
	return Vector2(id%32,id/32)

func is_free(pos:Vector2)->bool:
	return tilemap.get_cellv(pos)==TileMap.INVALID_CELL

func map_pos(pos):
	var local_position = tilemap.to_local(pos)
	return tilemap.world_to_map(local_position)

func my_pos():
	var local_position = tilemap.to_local(global_position)
	return tilemap.world_to_map(local_position)

func player_pos():
	var local_position = tilemap.to_local(chompman.global_position)
	return tilemap.world_to_map(local_position)
