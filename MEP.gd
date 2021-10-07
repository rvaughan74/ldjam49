extends KinematicBody2D


# C O N S T A N T S
const LAYER = {
	"player": 0,
	"platform": 1,
	"fallzone": 2,
	"item": 3,
	"enemy": 4,
	"fireball": 5,
	"ghost": 6
}
const GRAVITY = 35


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity = Vector2(0,0) #velocity in the world


func fallzone_death():
	print("WTF")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var _shut_up_delta = delta

	# Gravity's a bitch
	velocity.y += GRAVITY

	velocity = move_and_slide(velocity, Vector2.UP)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AttackChecker_body_entered(body):
	var children = self.get_parent().get_children()
	if not (body in children):
		body.ouch(position.x)# hurt player here
