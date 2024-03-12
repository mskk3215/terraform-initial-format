# ----------------------
# RDS parameter group
# ----------------------
resource "aws_db_parameter_group" "mysql_standalone_parametergroup" {
  name   = "${var.project}-${var.environment}-mysql-standalone-parametergroup"
  family = "mysql8.0" # MySQL 8.0パラメータグループのファミリー
  # DBの文字コードをutf8mb4に設定
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  # サーバの文字コードをutf8mb4に設定
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

# ----------------------
# RDS option group
# ----------------------
resource "aws_db_option_group" "mysql_standalone_optiongroup" {
  name                 = "${var.project}-${var.environment}-mysql-standalone-optiongroup"
  engine_name          = "mysql"  #関連付けるエンジン名
  major_engine_version = "8.0"    #関連付けるエンジンバージョン
}

# ----------------------
# RDS subnet group
# ----------------------
resource "aws_db_subnet_group" "mysql_standalone_subnetgroup" {
  name = "${var.project}-${var.environment}-mysql-standalone-subnetgroup"
  subnet_ids = [
    aws_subnet.private_subnet_1a.id,
    aws_subnet.private_subnet_1c.id
  ]
  tags = {
    Name    = "${var.project}-${var.environment}-mysql-standalone-subnetgroup"
    Project = var.project
    Env     = var.environment
  }
}

# ----------------------
# RDS instance
# ----------------------
# パスワードをランダム生成
resource "random_string" "db_password" {
  length  = 16
  special = false #特殊文字を含めるか
}
# RDSインスタンス
resource "aws_db_instance" "mysql_standalone" {
  engine         = "mysql"
  engine_version = "8.0.28"
  identifier     = "${var.project}-${var.environment}-mysql-standalone"

  username = "admin"
  password = random_string.db_password.result

  instance_class        = "db.t2.micro"
  allocated_storage     = 20
  max_allocated_storage = 50  #オートスケートの最大ストレージサイズ
  storage_type          = "gp2"
  storage_encrypted     = false #暗号化

  multi_az               = false  #マルチAZ構成
  availability_zone      = "ap-northeast-1a"
  db_subnet_group_name   = aws_db_subnet_group.mysql_standalone_subnetgroup.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  port                   = 3306
 
  db_name              = "tastylog"
  parameter_group_name = aws_db_parameter_group.mysql_standalone_parametergroup.name
  option_group_name    = aws_db_option_group.mysql_standalone_optiongroup.name

  backup_window              = "04:00-05:00"  #バックアップを行う時間帯
  backup_retention_period    = 7              #バックアップの保持日数
  maintenance_window         = "Mon:05:00-Mon:08:00"  #メンテナンスを行う時間帯
  auto_minor_version_upgrade = false  #マイナーバージョンの自動アップグレード

  deletion_protection = false  # 誤削除防止設定
  skip_final_snapshot = true   # RDSインスタンス削除の際、最終スナップショットを取得しない

  apply_immediately = true

  tags = {
    Name    = "${var.project}-${var.environment}-mysql-standalone"
    Project = var.project
    Env     = var.environment
  }
}
