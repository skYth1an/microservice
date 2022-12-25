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
    core_fraction = 20
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


resource "yandex_iam_service_account" "sa" {
  name = "storageman"
}

// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = "b1gjmrhngcisglrqmhda"
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}


resource "yandex_storage_bucket" "bucket" {
  bucket     = "lebedev25.12.22"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  anonymous_access_flags {
    read = true
    list = true
  }

}

resource "yandex_storage_object" "storage" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "lebedev25.12.22"
  key        = "1.jpg"
  source     = "1.jpg"
}

resource "yandex_storage_object" "storage2" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "lebedev25.12.22"
  key        = "index.html"
  source     = "index.html"
}


#Группа хостов
resource "yandex_compute_instance_group" "group1" {
  name                = "group1"
  folder_id = "b1gjmrhngcisglrqmhda"
  service_account_id  = "${yandex_iam_service_account.sa.id}"
  deletion_protection = false
  instance_template {
    resources {
      memory = 2
      cores  = 2
      core_fraction = 20
    }
    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
      }
    }
    network_interface {
      subnet_ids = ["${yandex_vpc_subnet.public.id}"]
      nat = true
    }
    labels = {
      label1 = "label1-value"
      label2 = "label2-value"
      label3 = "label3-value"
    }
    metadata = {
      user-data = "${file("data.txt")}"
      #ssh-keys = "ubuntu:${file("/home/vagrant/.ssh/id_rsa.pub")}"
    }
    network_settings {
      type = "STANDARD"
    }
  }

  variables = {
    test_key1 = "test_value1"
    test_key2 = "test_value2"
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 3
    max_creating    = 3
    max_expansion   = 3
    max_deleting    = 3
  }
}


resource "yandex_lb_target_group" "tgt" {
  name      = "tgt"

  target {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    address   = "192.168.10.21"
  }

  target {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    address   = "192.168.10.36"
  }

  target {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    address   = "192.168.10.13"
  }

}

resource "yandex_lb_network_load_balancer" "balancer" {
  name = "balancer"

  listener {
    name = "my-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.tgt.id}"

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

resource "yandex_alb_target_group" "tgt2" {
  name      = "tgt2"

  target {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    ip_address  = "192.168.10.21"
  }

  target {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    ip_address   = "192.168.10.36"
  }

  target {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    ip_address   = "192.168.10.13"
  }

}


resource "yandex_alb_backend_group" "backendgroup" {
  name      = "backendgroup"

  http_backend {
    name = "test-http-backend"
    weight = 1
    port = 80
    target_group_ids = ["${yandex_alb_target_group.tgt2.id}"]
    load_balancing_config {
      panic_threshold = 50
    }
    healthcheck {
      timeout = "1s"
      interval = "1s"
      http_healthcheck {
        path  = "/"
      }
    }
    http2 = "false"
  }
}

resource "yandex_alb_http_router" "tf-router" {
  name   = "tf-router"
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name           = "virtual-host"
  http_router_id = "${yandex_alb_http_router.tf-router.id}"
  route {
    name = "my-route"
    http_route {
      http_route_action {
        backend_group_id = "${yandex_alb_backend_group.backendgroup.id}"
        timeout          = "3s"
      }
    }
  }
}
resource "yandex_alb_load_balancer" "balancerl7" {
  name        = "balancerl7"
  network_id  = "${yandex_vpc_network.network.id}"

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = "${yandex_vpc_subnet.public.id}"
    }
  }

  listener {
    name = "listenerl7"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 9000 ]
    }
    http {
      handler {
        http_router_id = "${yandex_alb_http_router.tf-router.id}"
      }
    }
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
    next_hop_address   = "${yandex_compute_instance.default.network_interface[0].ip_address}"
  }

}

