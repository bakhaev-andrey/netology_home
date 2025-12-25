locals {
  disks_for_backup = concat(
    [yandex_compute_instance.bastion.boot_disk[0].disk_id],
    [for inst in values(yandex_compute_instance.web) : inst.boot_disk[0].disk_id],
    [yandex_compute_instance.prometheus.boot_disk[0].disk_id],
    [yandex_compute_instance.grafana.boot_disk[0].disk_id],
    [yandex_compute_instance.elasticsearch.boot_disk[0].disk_id],
    [yandex_compute_instance.kibana.boot_disk[0].disk_id]
  )
}

resource "yandex_compute_snapshot_schedule" "daily" {
  name = "daily-snapshots"

  schedule_policy {
    expression = var.snapshot_schedule.expression
  }

  retention_period = "${var.snapshot_schedule.retention_days * 24 * 60 * 60}s"

  snapshot_spec {
    description = "Daily auto snapshot"
    labels      = var.snapshot_schedule.snapshot_labels
  }

  disk_ids = local.disks_for_backup
}
