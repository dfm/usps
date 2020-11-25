class_name GravitationalBody
extends RigidBody2D

var instance_id: int = 0
# var simulation: Simulation = null

func _ready() -> void:
    instance_id = get_instance_id()
    # simulation = get_node("/root/Simulation")

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
    state.linear_velocity.x += 1.0
#     return
#     if simulation == null or instance_id == 0:
#         return
#     # print(simulation.integrator.get_position_for_id(instance_id))
#     var transform = state.get_transform()
#     transform.origin = simulation.integrator.get_position_for_id(instance_id)
#     state.set_transform(transform)
