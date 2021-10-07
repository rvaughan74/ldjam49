extends Area2D


signal coin_collected


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

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	match get_tree().current_scene.name:
		"Level1":
			pass
		"Level2":
			pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimatedSprite_animation_finished():
	match $AnimatedSprite.get_animation():
		"spin":
			$AnimatedSprite.play("shine")
		# "shine":
			# $AnimatedSprite.play("blink")
		"shine":
			$AnimatedSprite.play("spin")


func _on_Coin_body_entered(body):
	var _shut_up_body = body
	#body.add_coin()
	emit_signal("coin_collected")
	$AnimationPlayer.play("bounce")


func _on_AnimationPlayer_animation_finished(anim_name):
	var _shut_up_anim_name = anim_name
	queue_free()
