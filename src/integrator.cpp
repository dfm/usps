#include "integrator.h"

#include <cmath>

using namespace godot;

void USPSItegrator::_register_methods() {
  register_method("reset", &USPSItegrator::reset);
  register_method("add_body", &USPSItegrator::add_body);
  register_method("integrate", &USPSItegrator::integrate);
  register_method("get_position_for_id", &USPSItegrator::get_position_for_id);
  register_property<USPSItegrator, real_t>("grav", &USPSItegrator::set_grav,
                                           &USPSItegrator::get_grav, 5000.0);
  register_property<USPSItegrator, real_t>("time_factor", &USPSItegrator::set_time_factor,
                                           &USPSItegrator::get_time_factor, 2.0);
  register_property<USPSItegrator, real_t>("softening_length",
                                           &USPSItegrator::set_softening_length,
                                           &USPSItegrator::get_softening_length, 0.1);
  register_property<USPSItegrator, int>("num_leapfrog", &USPSItegrator::set_num_leapfrog,
                                        &USPSItegrator::get_num_leapfrog, 3);
}

void USPSItegrator::reset() { bodies.clear(); }

void USPSItegrator::add_body(int instance_id, real_t mass, Vector2 position, Vector2 velocity) {
  bodies.push_back({instance_id, mass, {position.x, position.y}, {velocity.x, velocity.y}});
}

Array USPSItegrator::integrate(real_t delta) {
  int N = bodies.size();
  leapfrog(delta);

  PoolVector2Array final_positions, final_velocities;
  for (int n = 0; n < N; ++n) {
    final_positions.push_back(Vector2(bodies[n].position.x, bodies[n].position.y));
    final_velocities.push_back(Vector2(bodies[n].velocity.x, bodies[n].velocity.y));
  }

  Array result;
  result.push_back(final_positions);
  result.push_back(final_velocities);
  return result;
}

Vector2 USPSItegrator::get_position_for_id(int instance_id) const {
  for (const USPSBody& body : bodies) {
    if (body.instance_id == instance_id) return Vector2(body.position.x, body.position.y);
  }
  return Vector2(0, 0);
}

void USPSItegrator::compute_accelerations() {
  size_t N = bodies.size();

  for (size_t n = 0; n < N; ++n) {
    bodies[n].acceleration = {0, 0};
  }

  for (size_t n = 0; n < N; ++n) {
    for (size_t m = n + 1; m < N; ++m) {
      USPSBody& body1 = bodies[n];
      USPSBody& body2 = bodies[m];
      USPSVector delta = body1.position - body2.position;
      real_t factor = delta.norm() + eps2;
      factor = (grav / (factor * std::sqrt(factor)));
      body1.acceleration.update(-factor * body2.mass, delta);
      body2.acceleration.update(factor * body1.mass, delta);
    }
  }
}

void USPSItegrator::update_positions(real_t eps) {
  size_t N = bodies.size();
  for (size_t n = 0; n < N; ++n) {
    USPSBody& body = bodies[n];
    body.position.update(eps, body.velocity);
  }
}

void USPSItegrator::update_velocities(real_t eps) {
  size_t N = bodies.size();
  for (size_t n = 0; n < N; ++n) {
    USPSBody& body = bodies[n];
    body.velocity.update(eps, body.acceleration);
  }
}

void USPSItegrator::leapfrog(real_t delta) {
  size_t N = bodies.size();
  real_t eps = time_factor * delta / num_leapfrog;

  compute_accelerations();
  update_velocities(0.5 * eps);
  for (int i = 0; i < num_leapfrog - 1; ++i) {
    update_positions(eps);
    compute_accelerations();
    update_velocities(eps);
  }
  update_positions(eps);
  compute_accelerations();
  update_velocities(0.5 * eps);
}
