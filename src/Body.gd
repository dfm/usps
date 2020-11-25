extends RigidBody2D

export(float) var maximum_velocity: = 1000.0
export(float) var rescale: = 1.0

func _ready() -> void:
    $CollisionShape2D.global_scale = Vector2(rescale, rescale)

func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
    pass
    # var vel: Vector2 = state.linear_velocity
    # if vel.length() > maximum_velocity:
    #     state.linear_velocity = vel.clamped(maximum_velocity)
