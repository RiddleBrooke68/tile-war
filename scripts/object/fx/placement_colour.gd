extends Node2D

var colour = Color(1.0, 1.0, 1.0, 1.0)

func start(c):
	$Sprite2D.set_instance_shader_parameter("shader_parameter/color",c)
	$AnimationPlayer.play("spike")

func end():
	self.queue_free()
