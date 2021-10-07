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
const HORIZONTAL_MOTION_INPUT = {
	"ui_left": {"velocity": -1, "flip":true, "weight": WEIGHT["horizontal"]},
	"ui_right": {"velocity": 1, "flip":false, "weight": WEIGHT["horizontal"]}
}
const VERTICAL_MOTION_INPUT = {
	"ui_up": {"velocity": -1, "flip":false, "weight": WEIGHT["vertical"]},
	# "ui_down": {"velocity": 1, "flip":false, "weight": WEIGHT["vertical"]}
}
const HORIZONTAL_SPEED = 350
const VERTICAL_SPEED = 1000
const BOUNCE_SPEED = -500
const GRAVITY = 35
const CHARACTER_NAME = "Bob"

# V A R I A B L E S
var velocity = Vector2(0,0)
var alive = true


func make_insensitive():
	"""make_insensitive: Change the player character to no longer detect collisions.
	"""
	#Disable the following LAYERS
	var to_disable = [
		"player", "fallzone", "item", "enemy"
	]

	for disable in to_disable:
		self.set_collision_layer_bit(LAYER[disable], false)
		self.set_collision_mask_bit(LAYER[disable], false)

	#Make the player a part of the ghost LAYER (no checking of ANYTHING)
	self.set_collision_layer_bit(LAYER["ghost"], true)


func ouch(nme_posx):
	"""ouch: Handle player collision with an enemy.

	Args:
		nme_posx (int): Where the enemy is on the x axis.
	"""
	alive = false #All hits are fatal right now

	make_insensitive()
	set_modulate(Color(1,0.3,0.3,0.6))
	#Jump up
	bounce()

	#Jump away from the enemy
	if position.x < nme_posx:
		velocity.x = BOUNCE_SPEED
	else:
		velocity.x = -BOUNCE_SPEED

	var presses = HORIZONTAL_MOTION_INPUT.keys() + VERTICAL_MOTION_INPUT.keys()

	#Stop player controlled motion until pressing another key.
	for kp in presses:
		Input.action_release(kp)

	$DeathTimer.start()


func bounce():
	"""bounce: Handle automatic jumping up from player interactions.
	"""
	velocity.y = BOUNCE_SPEED


func die():
	"""die: This is the end
	Here's where
	you'll die
	Legends should
	scatter
	So just say
	goodbye
	"""
	var scene = get_tree().current_scene.name
	var _shut_up_tree = get_tree().change_scene("res://"+scene+".tscn")


func _ready():
	"""_ready: What to do when ready state is called.
	"""
	print(get_tree().current_scene.name)
	print(velocity)
	print(InputMap.get_actions())


func _physics_process(delta):
	"""_physics_process: Handle general physics for the player.

	Args:
		delta (float): Seconds (determine frame)
	"""

	var _shut_up_delta = delta
	var horizontal = false

	for kp in HORIZONTAL_MOTION_INPUT:
		if alive and Input.is_action_pressed(kp):
			horizontal = true
			velocity.x = lerp(velocity.x, HORIZONTAL_MOTION_INPUT[kp]["velocity"] * HORIZONTAL_SPEED, HORIZONTAL_MOTION_INPUT[kp]["weight"])
			# velocity.x = HORIZONTAL_MOTION_INPUT[kp]["velocity"]
			$Sprite.flip_h = HORIZONTAL_MOTION_INPUT[kp]["flip"]

	for kp in VERTICAL_MOTION_INPUT:
		if alive and Input.is_action_just_pressed(kp) and is_on_floor():
			velocity.y = lerp(velocity.y, VERTICAL_MOTION_INPUT[kp]["velocity"] * VERTICAL_SPEED, VERTICAL_MOTION_INPUT[kp]["weight"])

	velocity.y += GRAVITY
	if not horizontal:
		velocity.x = lerp(velocity.x, Vector2.ZERO.x, WEIGHT["horizontal"])

	velocity = move_and_slide(velocity, Vector2.UP)

	# velocity.y = lerp(velocity.y, Vector2.ZERO.y, WEIGHT["vertical"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	"""_process: General logic processing at the end of the frame

	Args:
		delta (float): Seconds (determine frame)
	"""
	var _shut_up_delta = delta
	var horizontal = false
	var vertical = false

	for kp in HORIZONTAL_MOTION_INPUT:
		if alive and Input.is_action_pressed(kp):
			horizontal = true

	# for kp in VERTICAL_MOTION_INPUT:
	# 	if alive and Input.is_action_just_pressed(kp) and is_on_floor():
	# 		vertical = true

	if not is_on_floor():
		$Sprite.play("jump")
	elif vertical:
		pass
	elif horizontal:
		$Sprite.play("run")
	elif alive == false:
		$Sprite.play("ded")
	else:
		$Sprite.play("idle")


func _on_Fallzone_body_entered(body):
	"""_on_Fallzone_body_entered: Handle Fallzone_body_entered signals

	Args:
		body (Node2D): The triggering body.
	"""
	var _shut_up_body = body
	if body.get_name() == CHARACTER_NAME:
		# var _shut_up_tree = get_tree().change_scene("res://Level1.tscn")
		die()


func _on_DeathTimer_timeout():
	"""_on_DeathTimer_timeout: What to do when $DeathTimer runs out.
	"""
	die()
