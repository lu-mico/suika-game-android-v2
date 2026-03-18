extends RigidBody2D
class_name Fruit

## Fruit type index (0 = cherry, 10 = watermelon)
var fruit_type: int = 0
var is_merging: bool = false

## Fruit definitions
const FRUITS = [
	{"name": "Cherry", "radius": 15, "file": "cherry.png", "score": 1},
	{"name": "Strawberry", "radius": 25, "file": "strawberry.png", "score": 3},
	{"name": "Grape", "radius": 35, "file": "grape.png", "score": 6},
	{"name": "Dekopon", "radius": 45, "file": "dekopon.png", "score": 10},
	{"name": "Persimmon", "radius": 58, "file": "persimmon.png", "score": 15},
	{"name": "Apple", "radius": 72, "file": "apple.png", "score": 21},
	{"name": "Pear", "radius": 85, "file": "pear.png", "score": 28},
	{"name": "Peach", "radius": 100, "file": "peach.png", "score": 36},
	{"name": "Pineapple", "radius": 115, "file": "pineapple.png", "score": 45},
	{"name": "Melon", "radius": 135, "file": "melon.png", "score": 55},
	{"name": "Watermelon", "radius": 160, "file": "watermelon.png", "score": 66}
]

func setup(type: int):
	fruit_type = type
	var fruit_data = FRUITS[type]
	
	# Enable contact monitoring
	contact_monitor = true
	max_contacts_reported = 4
	
	# Set collision shape
	var shape = CircleShape2D.new()
	shape.radius = fruit_data.radius
	$CollisionShape2D.shape = shape
	
	# Load sprite
	var texture = load("res://assets/" + fruit_data.file)
	$Sprite2D.texture = texture
	
	# Scale sprite to match radius (original is 64x64)
	var scale_factor = fruit_data.radius * 2 / 64.0
	$Sprite2D.scale = Vector2(scale_factor, scale_factor)

func get_radius() -> float:
	return FRUITS[fruit_type].radius

func get_score() -> int:
	return FRUITS[fruit_type].score

func _integrate_forces(state):
	# Check for contacts
	var contact_count = state.get_contact_count()
	for i in range(contact_count):
		var collider = state.get_contact_collider_object(i)
		if collider is Fruit:
			# Emit signal to main to handle merging
			get_parent().handle_fruit_collision(self, collider)
