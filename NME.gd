extends KinematicBody2D


# C O N S T A N T S
const WEIGHT = {
	"horizontal": 0.25,
	"vertical":1.0
}
const LAYER = {
	"player": 0,
	"platform": 1,
	"fallzone": 2,
	"item": 3,
	"enemy": 4,
	"fireball": 5,
	"ghost": 6
}
const SPEED = 35
const BOUNCE_SPEED = -400
const GRAVITY = 35


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity = Vector2(0,0) #velocity in the world
var alive = true #Am I alive?
enum name_direction {left = -1, still = 0, right = 1}
export(name_direction) var direction = -1
export var detects_cliffs = true


# Called when the node enters the scene tree for the first time.
func _ready():
	if direction != 0:
		$AnimatedSprite.flip_h = direction != name_direction.left
		$FloorChecker.position.x = $CollisionShape2D.shape.get_extents().x * direction
	else:
		$AnimatedSprite.flip_h = false
		$FloorChecker.position.x = $CollisionShape2D.shape.get_extents().x * name_direction.left

	
	if !detects_cliffs:
		$AnimatedSprite.play("default_red")
	else:
		$AnimatedSprite.play("default")
	
	if direction == name_direction.still:
		$AnimatedSprite.play("default_blue")


func turn():
	"""turn: Change the NME character because of a detection.
	"""
	if direction != 0:
		direction *= -1
		$AnimatedSprite.flip_h = direction != -1
		# $AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		$FloorChecker.position.x = $CollisionShape2D.shape.get_extents().x * direction


func _physics_process(delta):
	var _shut_up_delta = delta

	if alive:
		# velocity.x = direction * SPEED
		velocity.x = lerp(velocity.x, direction * SPEED, WEIGHT["horizontal"])
	else:
		velocity.x = lerp(velocity.x, Vector2.ZERO.x, WEIGHT["horizontal"])

	if direction == name_direction.still:
		velocity.x = 0

	# Gravity's a bitch even after death
	velocity.y += GRAVITY

	velocity = move_and_slide(velocity, Vector2.UP)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var _shut_up_delta = delta

	if alive: #if we're alive
		if is_on_wall(): #are we smacking into walls?
			turn()

		if detects_cliffs: #are we about to go over a cliff?
			if not $FloorChecker.is_colliding() and is_on_floor():
				turn()


func _on_SquashChecker_body_entered(body):
	"""_on_SquashChecker_body_entered: Check for death from above!

	Args:
		body (Node2D): The triggering body.
	"""
	alive = false
	insensitive()

	$AnimatedSprite.stop()
	$AnimationPlayer.play("die")
	$Timer.start()
	body.bounce()


func insensitive():
	var to_disable = [
		self, $AttackChecker,
		#$SquashChecker
	]

	for disable in to_disable:
		disable.set_collision_layer_bit(LAYER["enemy"], false)
		disable.set_collision_layer_bit(LAYER["ghost"], true)
		disable.set_collision_mask_bit(LAYER["player"], false)


func fallzone_death():
	alive = false
	
	insensitive()

	$AnimatedSprite.stop()
	velocity.y = BOUNCE_SPEED
	$Timer.start()


func _on_AttackChecker_body_entered(body):

	var children = self.get_parent().get_children()
	if body in children:
		turn() #one of us
	else:
		body.ouch(position.x)# hurt player here


func _on_Timer_timeout():
	queue_free()
