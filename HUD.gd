extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var coins = 0
var max_coins = 0
var fin = false


# Called when the node enters the scene tree for the first time.
func _ready():
	var scene = get_tree().current_scene.name
	max_coins = get_node("/root/"+scene+"/coins").get_child_count()
	$Count.text = "{coins}/{max_coins}".format({"coins": coins, "max_coins":max_coins})


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var _shut_up_delta = delta
	if coins == max_coins and not fin:
		fin = true
		$EndTimer.start()


func _on_coin_collected():
	coins += 1
	# $Count.text = String(coins)
	$Count.text = "{coins}/{max_coins}".format({"coins": coins, "max_coins":max_coins})


func _on_EndTimer_timeout():
	var tree = get_tree()
	match get_tree().current_scene.name:
		"Level1":
			tree.change_scene("res://Level2.tscn")
		"Level2":
			tree.change_scene("res://Level2.tscn")
