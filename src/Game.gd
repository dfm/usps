extends Node2D


func _ready() -> void:
    pass

func _input(event: InputEvent) -> void:
    if not (event is InputEventMouseMotion):
        return
    var size: = get_viewport_rect().size
    var location: Vector2 = event.position
    var vector: Vector2 = location - Vector2(0, 0.5 * size.y)
    print(vector)
