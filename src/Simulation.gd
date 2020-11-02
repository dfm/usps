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

    set_process(true)

# # Compute the acceleration for each body based on all the others
# func compute_accelerations(masses, positions):
#     if len(masses) == 0:
#         return

#     # Initialize the accelerations to zero
#     var accelerations = []
#     for _i in range(len(masses)):
#         accelerations.push_back(Vector2(0, 0))

#     # Loop over each pair of bodies and compute the acceleration
#     for i in range(len(bodies)):
#         for j in range(i+1, len(bodies)):
#             var delta = positions[i] - positions[j]
#             var r2 = delta.length_squared() + softening_length
#             var a0 = G * delta / (r2 * sqrt(r2))
#             accelerations[i] -= a0 * masses[j]
#             accelerations[j] += a0 * masses[i]

#     return accelerations


# # Integrate the N-body system
# func leapfrog(delta, masses, positions, velocities):
#     var eps = delta / num_leapfrog

#     var accelerations = compute_accelerations(masses, positions)

#     for _j in range(num_leapfrog):
#         # Initial kick
#         for i in range(len(masses)):
#             velocities[i] += 0.5 * eps * accelerations[i]
#             positions[i] += eps * velocities[i]

#         # Update the accelerations
#         accelerations = compute_accelerations(masses, positions)

#         # Syncronize the velocities
#         for i in range(len(masses)):
#             velocities[i] += 0.5 * eps * accelerations[i]

#     return [positions, velocities]

func _process(delta):
    if len(bodies) == 0:
        return

    var masses = []
    var positions = []
    var velocities = []
    for i in range(len(bodies)):
        masses.push_back(bodies[i].mass)
        positions.push_back(bodies[i].position)
        velocities.push_back(bodies[i].velocity)

    # print(integrator.update(masses))

    # [positions, velocities] = leapfrog(time_factor * delta, masses, positions, velocities)
    var result = integrator.update(delta, masses, positions, velocities)
    positions = result[0]
    velocities = result[1]

    for i in range(len(bodies)):
        bodies[i].position = positions[i]
        bodies[i].velocity = velocities[i]


# # Newton's constant in R_sun^3 / (M_sun*day^2)
# export(float) var G = 2942.2

# # The number of simulation "days" per real time second
# export(float) var time_factor = 2

# # The softening length scale in R_sun
# export(float) var softening_length = 0.1

# # The maximum distance that the center of mass can be
# # shifted in one frame
# export(float) var max_drift = 0.1

# # The number of leapfrog steps per frame
# export(int) var num_leapfrog = 3

# # The maximum distance for planets in the system
# export(float) var max_distance = 50

# # The number of pixels per simulation "R_sun"
# export(float) var pixel_resolution = 10

# # The maximum number of points to save in the trail
# export(int) var max_trail_length = 50

# # Global list of bodies
# var bodies = Array()

# var rect_center = Vector2(0, 0)
# var merge = null

# # A color palette
# var palette = [
#     "b3e2cd", "fdcdac", "cbd5e8", "f4cae4",
#     "e6f5c9", "fff2ae", "f1e2cc", "cccccc"]


# # A class to hold the properties of a body
# class Body:
#     var mass
#     var pos
#     var vel
#     var acc
#     var trail
#     var color
#     var pix

#     func _init(mass, pos, vel, color):
#         self.mass = float(mass)
#         self.pos = Vector2(pos)
#         self.vel = Vector2(vel)
#         self.trail = PoolVector2Array()
#         self.color = Color(color)
#         self.acc = Vector2(0, 0)
#         self.pix = Vector2(0, 0)


# # Add a body to the system
# func add_body(mass, pos, color=null, vel=null):
#     # Index into the color palette by default
#     if color == null:
#         color = palette[len(bodies) % len(palette)]

#     # Place on an approximately circular orbit around the com by default
#     if vel == null:
#         if len(bodies) == 0:
#             vel = Vector2(0, 0)
#         else:
#             # Compute the total mass
#             var mu = 0
#             for i in range(len(bodies)):
#                 mu += bodies[i].mass
#             mu *= G

#             # Compute the semimajor axis
#             var delta = pos - bodies[0].pos
#             var a = delta.length()
#             if a < 1:
#                 vel = Vector2(0, 0)
#             else:
#                 # Compute the circular velocity
#                 var vcirc = sqrt(mu / a)

#                 # Compute the tangent vector
#                 vel = vcirc * delta.tangent().normalized()

#     bodies.append(Body.new(mass, pos, vel, color))
#     compute_accelerations()


# # Compute the acceleration for each body based on all the others
# func compute_accelerations():
#     if len(bodies) == 0:
#         return

#     # Pre-compute the square of the softening length
#     var eps2 = softening_length * softening_length

#     # Initialize the accelerations to zero
#     for i in range(len(bodies)):
#         bodies[i].acc = Vector2(0, 0)

#     # Loop over each pair of bodies and compute the acceleration
#     for i in range(len(bodies)):
#         for j in range(i+1, len(bodies)):
#             var delta = bodies[i].pos - bodies[j].pos
#             var r2 = delta.length_squared() + eps2
#             if merge == null and r2 < 2*eps2:
#                 merge = [i, j]
#             var a0 = G * delta / (r2 * sqrt(r2))
#             bodies[i].acc -= a0 * bodies[j].mass
#             bodies[j].acc += a0 * bodies[i].mass


# # Integrate the N-body system
# func leapfrog(delta):
#     var eps = delta / num_leapfrog
#     for j in range(num_leapfrog):
#         # Initial kick
#         for i in range(len(bodies)):
#             bodies[i].vel += 0.5 * eps * bodies[i].acc
#             bodies[i].pos += eps * bodies[i].vel

#         # Update the accelerations
#         compute_accelerations()

#         # Syncronize the velocities
#         for i in range(len(bodies)):
#             bodies[i].vel += 0.5 * eps * bodies[i].acc


# func compute_center_of_mass(robust=false):
#     var total_mass = 0
#     var com = Vector2(0, 0)
#     for i in range(len(bodies)):
#         var mass = bodies[i].mass
#         if robust:
#             var x = bodies[i].pos.length()
#             var weight = 1.0 / (1 + exp(10*(x/max_distance - 0.5)))
#             mass *= weight
#         total_mass += mass
#         com += bodies[i].pos * mass
#     com /= total_mass
#     return com


# # Move the center of mass to zero
# func center(robust=false, check_bound=false):
#     var com = compute_center_of_mass(robust)
#     for i in range(len(bodies)):
#         bodies[i].pos -= com

#     if not check_bound:
#         return
#     for i in range(len(bodies)):
#         if (bodies[i].pos - com).length() > max_distance:
#             bodies.remove(i)
#             return


# # Save the current state of the system to the particle trails
# func save_trails():
#     for i in range(len(bodies)):
#         var trail = bodies[i].trail
#         trail.append(bodies[i].pix)
#         if len(trail) > max_trail_length:
#             trail.remove(0)
#         bodies[i].trail = trail


# # Integrate the system one frame of length "delta"
# func integrate(delta):
#     # Integrate the system forward in time
#     leapfrog(time_factor*delta)

#     if merge != null:
#         var body1 = bodies[merge[0]]
#         var body2 = bodies[merge[1]]
#         if body1.mass > body2.mass:
#             body2 = body1
#             body1 = bodies[merge[1]]
#         var total_mass = body1.mass + body2.mass
#         var pos = (body1.mass * body1.pos + body2.mass * body2.pos) / total_mass
#         var vel = (body1.mass * body1.vel + body2.mass * body2.vel) / total_mass
#         var body = Body.new(total_mass, pos, vel, body2.color)
#         body.acc = (body1.mass * body1.acc + body2.mass * body2.acc) / total_mass
#         body.trail = body2.trail
#         bodies[merge[0]] = body
#         bodies.remove(merge[1])
#         merge = null

#     # Kick the center of mass towards zero
#     center(true, true)

#     for i in range(len(bodies)):
#         bodies[i].pix = to_pixels(bodies[i].pos)

#     # Update the particle trails
#     save_trails()


# # Interface functions
# func _ready():
#     randomize()

#     var rect = get_viewport_rect()
#     rect_center = 0.5*rect.size + rect.position

#     add_body(1, Vector2(0, 0))
#     add_body(0.5, Vector2(10, 0))

#     for i in range(50):
#         var theta = rand_range(0, 2*PI)
#         add_body(exp(rand_range(log(0.0001), log(0.001))),
#                  exp(rand_range(log(20), log(40)))*Vector2(sin(theta), cos(theta)))

# #    add_body(0.001, Vector2(0, 10))
# #    add_body(0.001, Vector2(0, -12))
# #    add_body(0.001, Vector2(0, 20))

#     # add_body(0.1, Vector2(10, 10))
#     # add_body(0.01, Vector2(-5, 0))
#     center()
#     set_process(true)


# func to_pixels(from):
#     return pixel_resolution*from + rect_center


# func _draw():
#     pass
# #    for i in range(len(bodies)):
# #        var body = bodies[i]
# #        var color = body.color.lightened(0.5)
# #        var trail = body.trail
# #        draw_polyline(trail, color, 2, true)
# #    for i in range(len(bodies)):
# #        var body = bodies[i]
# #        draw_circle(body.pix, 5+10*sqrt(body.mass), body.color)


# # func _process(delta):
# #     integrate(delta)
# #     update()
