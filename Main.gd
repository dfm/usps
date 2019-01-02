extends Node2D

# Parameters
export(float) var G = 10000000
export(int) var max_trail_length = 100
export(Vector2) var cen_coords = Vector2(0, 0)
export(float) var time_stretch = 2
export(int) var nsteps = 5
export(float) var softening = 5

class Body:
    var mass
    var pos
    var vel
    var acc
    var trail
    var color
    
    var palette = [
        "b3e2cd",
        "fdcdac",
        "cbd5e8",
        "f4cae4",
        "e6f5c9",
        "fff2ae",
        "f1e2cc",
        "cccccc",
    ]
    
    func _init(mass, pos, vel, color=null):
        if color == null:
            var ind = randi()%len(self.palette)
            color = self.palette[ind]
        self.mass = float(mass)
        self.pos = Vector2(pos)
        self.vel = Vector2(vel)
        self.trail = PoolVector2Array()
        self.color = Color(color)
        self.reset()
        
    func reset():
        self.acc = Vector2(0, 0)

# Global coordinates
var bodies = Array()

func _ready():
    randomize()
    
    bodies.append(Body.new(1,    Vector2(0, 0),   Vector2(0, 0)))
    bodies.append(Body.new(0.05, Vector2(0, 400), Vector2(150, 0)))
    bodies.append(Body.new(0.01, Vector2(0, 700), Vector2(170, 0)))
    
    center()
    compute_accelerations()
    set_process(true)
    
func compute_accelerations():
    var eps2 = softening * softening
    for i in range(len(bodies)):
        bodies[i].acc = Vector2(0.0, 0.0)
    for i in range(len(bodies)):
        for j in range(i+1, len(bodies)):
            var delta = bodies[i].pos - bodies[j].pos
            var r2 = delta.length_squared() + eps2
            var a0 = G * delta / (r2 * sqrt(r2))
            bodies[i].acc -= a0 * bodies[j].mass
            bodies[j].acc += a0 * bodies[i].mass
            
func center():
    var total_mass = 0
    var com = Vector2(0, 0)
    for i in range(len(bodies)):
        var mass = bodies[i].mass
        total_mass += mass
        com += bodies[i].pos * mass
    com /= total_mass
    com -= cen_coords
    for i in range(len(bodies)):
        bodies[i].pos -= com
        
func leapfrog(delta):
    var eps = delta / nsteps
    for j in range(nsteps):
        # Initial kick
        for i in range(len(bodies)):
            bodies[i].vel += 0.5 * eps * bodies[i].acc
            bodies[i].pos += eps * bodies[i].vel
            
        # Update the accelerations
        compute_accelerations()
        
        # Syncronize the velocities
        for i in range(len(bodies)):
            bodies[i].vel += 0.5 * eps * bodies[i].acc
        
func update_trails():
    for i in range(len(bodies)):
        var trail = bodies[i].trail
        trail.append(bodies[i].pos)
        if len(trail) > max_trail_length:
            trail.remove(0)
        bodies[i].trail = trail
        
func _draw():
    for i in range(len(bodies)):
        var body = bodies[i]
        if len(body.trail) >= 2:
            draw_polyline(body.trail, bodies[i].color.lightened(0.2), 8, true)
        draw_circle(body.pos, 20 + 30 * bodies[i].mass, bodies[i].color)

func _process(delta):
    leapfrog(time_stretch*delta)
    center()
    update_trails()
    update()
