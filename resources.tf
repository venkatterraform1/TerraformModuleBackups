module "backupmodule" {

  source = "lgallard/backup/aws"

  # Vault
  vault_name = "Daily"

  # Plan
  plan_name = "Daily"

  # Notifications
  notifications = {
    sns_topic_arn       = "arn:aws:sns:us-east-1:128345231794:Backup"
    backup_vault_events = ["BACKUP_JOB_STARTED", "BACKUP_JOB_COMPLETED", "BACKUP_JOB_FAILED", "RESTORE_JOB_COMPLETED"]
  }

  # Multiple rules using a list of maps
  rules = [
    {
      name                     = "dailyrule-1"
      schedule                 = "cron(0 12 * * ? *)"
      target_vault_name        = null
      start_window             = 120
      completion_window        = 360
      enable_continuous_backup = true
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 30
      },
      copy_actions = [
        {
          lifecycle = {
            cold_storage_after = 0
            delete_after       = 90
          },
          destination_vault_arn = "arn:aws:backup:us-west-2:123456789101:backup-vault:Default"
        },
        {
          lifecycle = {
            cold_storage_after = 0
            delete_after       = 90
          },
          destination_vault_arn = "arn:aws:backup:us-east-2:123456789101:backup-vault:Default"
        },
      ]
      recovery_point_tags = {
        Environment = "sandbox"
      }
    },
    {
      name                = "daily-rule2"
      schedule            = "cron(0 7 * * ? *)"
      target_vault_name   = "Default"
      schedule            = null
      start_window        = 120
      completion_window   = 360
      lifecycle           = {}
      copy_action         = []
      recovery_point_tags = {}
    },
  ]

  selections = [{
      name          = "RDS"
      resources     = ["arn:aws:rds:us-east-1:128345231794:db:database"]
      not_resources = []
      selection_tags = [{
          type  = "STRINGEQUALS"
          key   = "Environment"
          value = "sandbox"
        }]
    }]
  
}