extends RigidBody2D
class_name Fruit

## Fruit type index (0 = cherry, 10 = watermelon)
var fruit_type: int = 0
var is_merging: bool = false

## Fruit definitions
const FRUITS = [
	{"name": "Cherry", "radius": 15, "color": Color(1, 0, 0), "score": 1},
	{"name": "Strawberry", "radius": 25, "color": Color(1, 0.3, 0.3), "score": 3},
	{"name": "Grape", "radius": 35, "color": Color(0.6, 0, 1), "score": 6},
	{"name": "Dekopon", "radius": 45, "color": Color(1, 0.6, 0), "score": 10},
	{"name": "Persimmon", "radius": 58, "color": Color(1, 0.5, 0), "score": 15},
	{"name": "Apple", "radius": 72, "color": Color(1, 0.2, 0), "score": 21},
	{"name": "Pear", "radius": 85, "color": Color(1, 0.9, 0.8), "score": 28},
	{"name": "Peach", "radius": 100, "color": Color(1, 0.8, 0.8), "score": 36},
	{"name": "Pineapple", "radius": 115, "color": Color(1, 1, 0), "score": 45},
	{"name": "Melon", "radius": 135, "color": Color(0.5, 1, 0.5), "score": 55},
	{"name": "Watermelon", "radius": 160, "color": Color(0, 1, 0), "score": 66}
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
	
	# Set visual size
	$Sprite2D.scale = Vector2(fruit_data.radius * 2 / 64.0, fruit_data.radius * 2 / 64.0)
	
	# Set color (temporary, until we have sprites)
	modulate = fruit_data.radius * 2

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
