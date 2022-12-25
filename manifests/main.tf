terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}


#Provider settngs
provider "yandex" {
  zone = "ru-central1-a"
}

#NAT Instance
resource "yandex_compute_instance" "default" {
  name        = "nat"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    ip_address = "192.168.10.254"
    nat = true
  }

}

#PUBLIC Instance
resource "yandex_compute_instance" "public-nat" {
  name        = "public-nat"
  zone        = "ru-central1-a"


  resources {
    cores  = 2
    memory = 2
    }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/vagrant/.ssh/id_rsa.pub")}"
  }

  boot_disk {
    initialize_params {
      image_id = "fd8b24tqvq7t2f8a1o1s"
    }
  }


}



#PRIVATE Instance
resource "yandex_compute_instance" "private-nat" {
  name        = "private-nat"
  zone        = "ru-central1-a"


  resources {
    cores  = 2
    memory = 2
    }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.private.id}"

  }

  boot_disk {
    initialize_params {
      image_id = "fd8b24tqvq7t2f8a1o1s"
    }
  }

  metadata = {
    user-data = "${file("data.txt")}"
  }

}




resource "yandex_vpc_network" "network" {
  name = "empty-network"
}

resource "yandex_vpc_subnet" "public" {
  name = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network.id}"
}


resource "yandex_vpc_subnet" "private" {
  name = "private"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network.id}"
}


resource "yandex_vpc_route_table" "route-table" {
  name = "table"
  network_id = "${yandex_vpc_network.network.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}