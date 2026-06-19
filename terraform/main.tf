terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "k3s_network" {
  name                    = "k3s-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "k3s_subnet" {
  name          = "k3s-subnet"
  ip_cidr_range = "10.10.0.0/24"

  region  = var.region
  network = google_compute_network.k3s_network.id
}

resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = google_compute_network.k3s_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "k3s" {
  name    = "allow-k3s"
  network = google_compute_network.k3s_network.name

  allow {
    protocol = "tcp"
    ports = [
      "6443",
      "30000-32767"
    ]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "control_plane" {

  name         = "gcp-control-plane"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-9"
      size  = 20
    }
  }

  network_interface {

    subnetwork = google_compute_subnetwork.k3s_subnet.id

    access_config {}
  }

  metadata_startup_script = <<-EOF
#!/bin/bash

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --token tfm-cluster-token" sh -

EOF

  tags = [
    "k3s"
  ]
}

resource "google_compute_instance" "worker" {

  name         = "gcp-worker"
  machine_type = "e2-small"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-9"
      size  = 20
    }
  }

  network_interface {

    subnetwork = google_compute_subnetwork.k3s_subnet.id

    access_config {}
  }

  metadata_startup_script = <<-EOF
#!/bin/bash

sleep 60

export K3S_URL=https://${google_compute_instance.control_plane.network_interface[0].network_ip}:6443
export K3S_TOKEN=tfm-cluster-token

curl -sfL https://get.k3s.io | sh -

EOF

  tags = [
    "k3s"
  ]

  depends_on = [
    google_compute_instance.control_plane
  ]
}
