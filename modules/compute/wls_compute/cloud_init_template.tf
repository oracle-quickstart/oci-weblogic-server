
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.key_script.rendered
  }
  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content      = file(format("%s/%s", path.module, var.bootstrap_file))
  }
}
