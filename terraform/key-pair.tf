resource "aws_key_pair" "drupal_key" {
  key_name   = "drupal-ha-key"
  public_key = file(pathexpand("~/.ssh/drupal_ha_key.pub"))

  tags = {
    Name    = "Drupal-HA-Key"
    Project = "Drupal-HA"
  }
}
