extends KinematicBody2D

export(float) var mass = 1.0
export(Vector2) var velocity = Vector2(0, 0)
export(Vector2) var acceleration = Vector2(0, 0)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func _draw():
    draw_circle(Vector2(0, 0), 10, "#000000");
