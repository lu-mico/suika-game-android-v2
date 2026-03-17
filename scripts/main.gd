extends Node2D

## Game configuration
const WALL_THICKNESS = 20
const DEAD_LINE_Y = 150
const DROP_Y = 50
const SPAWN_INTERVAL = 0.5

var current_fruit: RigidBody2D = null
var can_drop: bool = true
var next_fruit_type: int = 0
var score: int = 0
var game_over: bool = false

@onready var container_width = get_viewport_rect().size.x
@onready var container_height = get_viewport_rect().size.y

func _ready():
	# Create walls
	create_walls()
	
	# Spawn first preview
	spawn_next_fruit_preview()
	
	# Connect input
	set_process_input(true)

func create_walls():
	# Ground
	var ground = StaticBody2D.new()
	var ground_shape = RectangleShape2D.new()
	ground_shape.size = Vector2(container_width, WALL_THICKNESS * 2)
	ground.position = Vector2(container_width / 2, container_height + WALL_THICKNESS)
	ground.create_shape_owning(ground_shape)
	add_child(ground)
	
	# Left wall
	var left_wall = StaticBody2D.new()
	var left_shape = RectangleShape2D.new()
	left_shape.size = Vector2(WALL_THICKNESS, container_height)
	left_wall.position = Vector2(-WALL_THICKNESS / 2, container_height / 2)
	left_wall.create_shape_owning(left_shape)
	add_child(left_wall)
	
	# Right wall
	var right_wall = StaticBody2D.new()
	var right_shape = RectangleShape2D.new()
	right_shape.size = Vector2(WALL_THICKNESS, container_height)
	right_wall.position = Vector2(container_width + WALL_THICKNESS / 2, container_height / 2)
	right_wall.create_shape_owning(right_shape)
	add_child(right_wall)

func spawn_next_fruit_preview():
	# Random fruit type (0-3 for small fruits)
	next_fruit_type = randi() % 4

func _input(event):
	if game_over:
		return
	
	if event is InputEventMouseMotion and can_drop:
		if current_fruit:
			current_fruit.position.x = clamp(event.position.x, WALL_THICKNESS + 50, container_width - WALL_THICKNESS - 50)
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		drop_fruit()

func drop_fruit():
	if not can_drop or game_over:
		return
	
	can_drop = false
	
	# Create fruit
	var fruit_scene = preload("res://scenes/fruit.tscn")
	var fruit = fruit_scene.instantiate()
	fruit.setup(next_fruit_type)
	fruit.position = Vector2(container_width / 2, DROP_Y)
	add_child(fruit)
	
	# Wait for next fruit
	await get_tree().create_timer(SPAWN_INTERVAL).timeout
	spawn_next_fruit_preview()
	can_drop = true

func merge_fruits(fruit_a: Fruit, fruit_b: Fruit):
	if fruit_a.is_merging or fruit_b.is_merging:
		return
		
	fruit_a.is_merging = true
	fruit_b.is_merging = true
	
	# Calculate new position
	var mid_pos = (fruit_a.position + fruit_b.position) / 2
	var new_type = fruit_a.fruit_type + 1
	
	# Add score
	score += FRUITS[new_type].score
	$CanvasLayer/UI/ScoreLabel.text = "Score: " + str(score)
	
	# Remove old fruits
	fruit_a.queue_free()
	fruit_b.queue_free()
	
	# Create new fruit
	if new_type < FRUITS.size():
		await get_tree().create_timer(0.1).timeout
		var fruit_scene = preload("res://scenes/fruit.tscn")
		var new_fruit = fruit_scene.instantiate()
		new_fruit.setup(new_type)
		new_fruit.position = mid_pos
		add_child(new_fruit)

func handle_fruit_collision(fruit_a: Fruit, fruit_b: Fruit):
	if fruit_a.fruit_type == fruit_b.fruit_type:
		merge_fruits(fruit_a, fruit_b)
