extends Node2D

export(float) var G = 1000000.0
export(float) var eps2 = 0.1

func _ready() -> void:
    set_physics_process(true)

func _physics_process(_delta: float) -> void:
    var children: = get_children()    
    var num_children: = len(children)
    var m1: float
    var x1: Vector2
    var force1: Vector2
    var dx: Vector2
    var force: Vector2
    
    var masses: = []
    var positions: = []
    var forces: = []
    for child in children: 
        masses.push_back(child.mass)
        positions.push_back(child.position)
        forces.push_back(Vector2.ZERO)
    
    for n in range(num_children):
        m1 = G * masses[n]
        x1 = positions[n]
        force1 = forces[n]
        for m in range(n + 1, num_children):
            dx = x1 - positions[m]
            force = dx.normalized() * m1 * masses[m] / (dx.length_squared() + eps2)
            force1 -= force
            forces[m] += force
        children[n].set_applied_force(force1)
