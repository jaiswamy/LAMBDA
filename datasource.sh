#! /bin/bash
sudo su -i
yum install python3-pip -y
mkdir -p my_layer/python
pip install pymysql -t my_layer/python
yum install tree -y
cd my_layer/
zip -r ../pymysql_layer.zip python/
cd ..
aws s3 cp pymysql_layer.zip s3://lambdathroughterraform18
