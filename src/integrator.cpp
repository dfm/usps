#include "integrator.h"

#include <cmath>

using namespace godot;

void USPSItegrator::_register_methods() {
  register_method("update", &USPSItegrator::update);
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

USPSItegrator::USPSItegrator() {}

USPSItegrator::~USPSItegrator() {
  // add your cleanup here
}

void USPSItegrator::compute_accelerations(std::vector<USPSBody>& bodies) {
  size_t N = bodies.size();
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

void USPSItegrator::leapfrog(real_t delta, std::vector<USPSBody>& bodies) {
  size_t N = bodies.size();
  real_t eps = time_factor * delta / num_leapfrog;
  compute_accelerations(bodies);

  for (size_t n = 0; n < N; ++n) {
    USPSBody& body = bodies[n];
    body.velocity.update(0.5 * eps, body.acceleration);
  }

  for (int i = 0; i < num_leapfrog; ++i) {
    for (size_t n = 0; n < N; ++n) {
      USPSBody& body = bodies[n];
      body.position.update(eps, body.velocity);
    }
    compute_accelerations(bodies);
    for (size_t n = 0; n < N; ++n) {
      USPSBody& body = bodies[n];
      body.velocity.update(eps, body.acceleration);
    }
  }

  for (size_t n = 0; n < N; ++n) {
    USPSBody& body = bodies[n];
    body.velocity.update(-0.5 * eps, body.acceleration);
  }
}

void USPSItegrator::_init() {}

Array USPSItegrator::update(real_t delta, PoolRealArray masses, PoolVector2Array positions,
                            PoolVector2Array velocities) {
  int N = masses.size();
  std::vector<USPSBody> bodies(N);
  for (int n = 0; n < N; ++n) {
    bodies[n] = {masses[n], {positions[n].x, positions[n].y}, {velocities[n].x, velocities[n].y}};
  }

  leapfrog(delta, bodies);

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