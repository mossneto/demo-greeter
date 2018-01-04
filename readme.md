The idea of this project is to have everything as codes, including CI/CD. To achieve this, the following things are used
1. Jenkins Declarative Pipeline to declare build pipeline as codes.
2. Terraform to provision VMs required for deployment
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