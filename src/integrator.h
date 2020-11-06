#ifndef _INTEGRATOR_H_
#define _INTEGRATOR_H_
#include <Godot.hpp>
#include <Reference.hpp>
#include <vector>

namespace godot {

struct USPSVector {
  real_t x = 0.0;
  real_t y = 0.0;
  real_t norm() { return x * x + y * y; }
  void update(real_t factor, const USPSVector& delta) {
    x += factor * delta.x;
    y += factor * delta.y;
  }
  USPSVector operator-(const USPSVector& other) const { return {x - other.x, y - other.y}; }
  USPSVector& operator+=(const USPSVector& other) {
    x += other.x;
    y += other.y;
    return *this;
  }
};

struct USPSBody {
  float mass;
  USPSVector position;
  USPSVector velocity;
  USPSVector acceleration;
};

class USPSItegrator : public Reference {
  GODOT_CLASS(USPSItegrator, Reference)

 private:
  real_t grav;
  real_t time_factor;
  real_t softening_length;
  real_t eps2;
  int num_leapfrog;

  std::vector<USPSBody> bodies;

 public:
  static void _register_methods();
  void _init(){};

  USPSItegrator(){};
  ~USPSItegrator(){};

  real_t get_grav() const { return grav; }
  void set_grav(real_t value) { grav = value; }

  real_t get_time_factor() const { return time_factor; }
  void set_time_factor(real_t value) { time_factor = value; }

  real_t get_softening_length() const { return softening_length; }
  void set_softening_length(real_t value) {
    softening_length = value;
    eps2 = softening_length * softening_length;
  }

  int get_num_leapfrog() const { return num_leapfrog; }
  void set_num_leapfrog(int value) { num_leapfrog = value; }

  void add_body(real_t mass, Vector2 position, Vector2 velocity) {
    bodies.push_back({mass, {position.x, position.y}, {velocity.x, velocity.y}});
  }

  void compute_accelerations();
  void update_positions(real_t);
  void update_velocities(real_t);
  void leapfrog(real_t);

  Array integrate(real_t delta);
};

}  // namespace godot

#endif