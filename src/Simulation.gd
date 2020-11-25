class_name Simulation
extends Node2D

# var integrator = load("res://bin/integrator.gdns").new()

# Newton's constant in pixels^3 / (mass_unit * seconds^2)
export(float) var grav = 5000

# The number of simulation "days" per real time second
export(float) var time_factor = 2

# The softening length scale in R_sun
export(float) var softening_length = 0.1

# The number of leapfrog steps per frame
export(int) var num_leapfrog = 1

var bodies: = []

func _ready():
    # integrator.grav = grav
    # integrator.time_factor = time_factor
    # integrator.softening_length = softening_length
    # integrator.num_leapfrog = num_leapfrog
    for body in get_children():
        if not body is GravitationalBody:
            continue
        bodies.push_back(body)

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
    pass
    # for body in bodies:
    #     body.linear_velocity.x += 1.0
    # integrator.reset()
    # for body in bodies:
    #     integrator.add_body(body.get_instance_id(), body.mass, body.transform.origin, body.linear_velocity)
    # var results = integrator.integrate(state.get_step())
    # var final_positions = results[0]
    # var final_velocities = results[1]
    # for n in range(len(bodies)):
    #     # bodies[n].transform.origin = final_positions[n]
    #     bodies[n].linear_velocity = final_velocities[n]
