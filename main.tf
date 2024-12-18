resource "aws_db_instance" "Database18" {
    allocated_storage    = 20
    storage_type         = "gp2"
    engine = "mysql"
    engine_version = "8.0.39"
    instance_class = "db.t4g.micro"
    db_name = "Database18"
    username = "admin"
    password = "Jai082002"
    publicly_accessible = true
    skip_final_snapshot  = true
    vpc_security_group_ids = ["sg-0ecf450487f36196a"] 
}

resource "aws_s3_bucket" "newbucket" {
    bucket = "lambdathroughterraform18"  
}

resource "aws_iam_role" "admin_role" {
  name               = "admin-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = { Service = "ec2.amazonaws.com" }
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "admin_profile" {
  name = "admin-instance-profile"
  role = aws_iam_role.admin_role.name
}

resource "aws_instance" "Lamnda" {
    ami = "ami-0fd05997b4dff7aac"
    instance_type = "t3.micro"
    subnet_id  = "subnet-0b190f22f88c6cd97"
    key_name = "clientkey"
    iam_instance_profile = aws_iam_instance_profile.admin_profile.name
    associate_public_ip_address = true
    connection {
    type        = "ssh"
    user        = "ec2-user"  
    # private_key = file("C:/Users/veerababu/.ssh/id_rsa")
    private_key = file("Downloads/clientkey")  #private key path
    host        = self.public_ip
    }
    user_data = file("datasource.sh")
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = { Service = "lambda.amazonaws.com" }
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_layer_version" "my_lambda_layer" {
  layer_name = "my-layer"
  s3_bucket = "lambdathroughterraform18"      
  s3_key    = "pymysql_layer.zip" 
  compatible_runtimes = ["python3.9"]  
}


resource "aws_lambda_function" "my_lambda" {
  function_name = "my-lambda-function"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "database1.lambda_handler"   
  runtime       = "python3.9"       
  timeout       = 123         
  s3_bucket     = "myawssugar234"     
  s3_key        = "database1.zip" 
  layers        = [aws_lambda_layer_version.my_lambda_layer.arn]
  environment {
    variables = {
      db_host     = "terraform-20241218072010301500000001.c9uoiciogvfw.ap-south-1.rds.amazonaws.com"   
      db_user     = "admin"                  
      db_pass     = "Jai082002"    
    }
  }
}


