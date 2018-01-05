The idea of this project is to have everything as codes, including CI/CD. To achieve this, the following things are used
1. Jenkins Declarative Pipeline to declare build pipeline as codes. All the pipline are declared in the file `Jenkinsfile`
2. Terraform to provision VMs required for deployment (scripts are in these folder terraform/develop, and terraform/staging)
3. Spring Boot to help with the usual things needed in micro services. For example, config-server, microservice's communication, service discovery.

Prerequisite before running this projects are
1. AWS Account
2. EC2's image with Java and Maven installed
3. Jenkins Server (>= 2.89) with the following
- pipeline-utility-steps plugin
- jdk 1.8
- apache maven 3.2
- terraform 0.11.1

Build Steps
1. Build using maven to create Spring Boot's self-contained jar ready to be run on any environment with java
2. Perform unit/component tests. This is basically Spring-Boot tests that will make sure the application perform as expected
3. [not-good] Publish the jar in step #1 to S3 via S3-Wagon. This pose a lot of limitations and problems. It is implemented this way to make getting project deploy easier.
4. For develop branch, Jenkins will deploy this project for QA environment. To do so, terraform will spin up an EC2 instance. Then download and run the jar (created in step #3) via maven's dependency plugin.
5. [not-working-right-now] For master branch, Jenkins will also setup cloudwatch to autoscale based on monitor CPU (since the application will consume limit number of memory and not much of disk space, nor network bandwidth).
6. [missing] automation tests should be run against every deployment to make sure that things are working

For production and any custom environment, the application can be deployed by running terraform

cd `folder-contain-terraform-files`

terraform apply -var-file=`variable-file` -var greeter_version=`greeter-version`

The following variable need to be configure in <variable-file>
- greeter_repo_id: This is the id of s3.wagon's repo configured in <server> section of settings.xmml
- greeter_repo_url: URL of s3 bucket containing the s3.wagon's repo

- aws_region: Region of your AWS account
- aws_ami: Custom ami Id that have java and maven installed
- aws_instance_type: Type of instance. t2.micro is good enough

- aws_key_pair_name: Name of the key-pair that will show up in AWS console
- aws_access_key: AWS's access_key that will be used to create and provisioning EC2 instances
- aws_secret_key: AWS's secret_key that will be used to create and provisioning EC2 instances

- aws_private_key: SSH-RSA Private Key for accessing EC2 instances
- aws_public_key: SSH-RSA Public Key for accessing EC2 instances
