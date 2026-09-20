extends Area2D
signal hit

@export var speed = 400
var screen_size

var dash_speed = 900
var dash_duration = 0.15
var dash_cooldown = 2.0
var can_dash = true
var is_dashing = false

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	var velocity = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

		if velocity.x != 0:
			$AnimatedSprite2D.animation = "caminar"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y != 0:
			$AnimatedSprite2D.animation = "arriba"
			$AnimatedSprite2D.flip_v = velocity.y > 0

		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

func _on_body_entered(_body):
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func dash(direction):
	if not can_dash or direction == Vector2.ZERO:
		return

	can_dash = false
	is_dashing = true

	var dash_velocity = direction.normalized() * dash_speed
	position += dash_velocity * dash_duration
	position = position.clamp(Vector2.ZERO, screen_size)

	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false

	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed and not event.echo:
			var direction = Vector2.ZERO

			if Input.is_action_pressed("move_right"):
				direction.x += 1
			if Input.is_action_pressed("move_left"):
				direction.x -= 1
			if Input.is_action_pressed("move_down"):
				direction.y += 1
			if Input.is_action_pressed("move_up"):
				direction.y -= 1

			dash(direction)
