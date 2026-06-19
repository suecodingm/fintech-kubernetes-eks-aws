output "control_plane_ip" {
  value = google_compute_instance.control_plane.network_interface[0].access_config[0].nat_ip
}

output "worker_ip" {
  value = google_compute_instance.worker.network_interface[0].access_config[0].nat_ip
}
