extends Node2D

var integrator = load("res://bin/integrator.gdns").new()

# Newton's constant in pixels^3 / (mass_unit * seconds^2)
export(float) var grav = 5000

# The number of simulation "days" per real time second
export(float) var time_factor = 2

# The softening length scale in R_sun
export(float) var softening_length = 0.1

# The number of leapfrog steps per frame
export(int) var num_leapfrog = 3

var bodies = []


func _ready():
    integrator.grav = grav
    integrator.time_factor = time_factor
    integrator.softening_length = softening_length
    integrator.num_leapfrog = num_leapfrog

    for body in get_node("Planets").get_children():
        bodies.push_back(body)
        integrator.add_body(body.mass, body.position, body.velocity)

    set_process(true)


func _process(delta):
    if len(bodies) == 0:
        return

    var result = integrator.integrate(delta)
    var positions = result[0]
    var velocities = result[1]

    for i in range(len(bodies)):
        bodies[i].position = positions[i]
        bodies[i].velocity = velocities[i]
