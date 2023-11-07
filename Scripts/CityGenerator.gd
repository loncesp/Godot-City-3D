extends Spatial

const DISTRICT_ROOT = "res://Scenes/Districts/District"

var district_array = []
var city_array = {}

export var city_size = 15
export var district_count = 75

var random_max = 1

#Generation
func add_one_district(i, j):
	if district_count > 0:
		var district = rand_range(0, random_max)

		if district >= 1:
			if ((i >= 0) && (i < city_size) && (j >= 0) && (j < city_size) && (city_array[Vector2(i, j)] != 1)):
				city_array[Vector2(i, j)] = 1
				district_count -= 1
				return Vector2(i, j)
	return Vector2(-1, -1)

func add_districts(i, j):
	var add: Vector2

	add = add_one_district(i - 1, j)
	if add != Vector2(-1, -1):
		add_districts(add.x, add.y)

	add = add_one_district(i + 1, j)
	if add != Vector2(-1, -1):
		add_districts(add.x, add.y)

	add = add_one_district(i, j - 1)
	if add != Vector2(-1, -1):
		add_districts(add.x, add.y)

	add = add_one_district(i, j + 1)
	if add != Vector2(-1, -1):
		add_districts(add.x, add.y)

func generate_city():
	for i in range(city_size):
		for j in range(city_size):
			city_array[Vector2(i, j)] = 0

	if city_array.size() < district_count:
		district_count = city_array.size()

	city_array[Vector2(round(city_size / 2), round(city_size / 2))] = 1

	while district_count > 0:
		add_districts(round(city_size / 2), round(city_size / 2))

		random_max += 1
		if random_max > 10:
			break

#Things for object manipulating
func get_district_path(index):
	return DISTRICT_ROOT + str(index) + ".tscn"
	
func get_district_array():
	var i = 1
	while true:
		if load(get_district_path(i)) != null:
			district_array.append(load(get_district_path(i)))
		else:
			break
		i += 1

func set_random_direction(district):
	var angle = rand_range(0, 360)
	
	if angle < 90 and angle >= 0:
		angle = 0
	elif angle < 180 and angle >= 90:
		angle = 90
	elif angle < 270 and angle >= 180:
		angle = 180
	elif angle < 360 and angle >= 270:
		angle = 270
	else:
		angle = 0
	
	district.transform.basis = Basis().rotated(Vector3(0, 0, 0), deg2rad(angle))

#Drawing
func draw_cell(i, j):
	var random_district = district_array[rand_range(0, district_array.size())].instance()
	random_district.transform.origin = Vector3(i * 10, 0, j * 10)
	
	set_random_direction(random_district)

	add_child(random_district)
	
func draw_base(i, j):
	var base = load("res://Scenes/Districts/Base.tscn").instance()
	base.transform.origin = Vector3(i * 10, 0, j * 10)

	add_child(base)

#Building
func build_city():
	for i in range(city_size):
		for j in range(city_size):
			if city_array[Vector2(i, j)] == 0:
				draw_base(i, j)
			elif city_array[Vector2(i, j)] == 1:
				draw_cell(i, j)
				city_array[Vector2(i, j)] = -1


func _ready():
	randomize()
	generate_city()
	get_district_array()
	build_city()
