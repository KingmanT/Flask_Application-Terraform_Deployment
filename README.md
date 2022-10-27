
# Terraform Deployment 4
October 27, 2022

By: Kingman Tam- Kura Labs

# Purpose:

To deploy a Flask Application in a custom VPC using Terraform

Previously, Flask Applications were deployed into infrastructure that had to be manually created in AWS. Creating VPCs, Subnets, EC2s, and their configurations (routing tables, CIDR blocks, security groups) one by one by visiting the appropriate AWS resource webpage was a tedious and time consuming task. By utilizing Terraform, we are able to use Jenkins to not only create the desired infrastructure for our application, but to also deploy it all in one click (and a bunch of terraform files!).

# Steps:

1. Launch an EC2 with Jenkins installed and activated

- Jenkins is the main tool used in this deployment for pulling the program from the GitHub repository, then building, testing, and deploying it to a server.
- The Jenkins EC2 from previous deployments was used. It is on the default VPC that AWS provides

2. Install Terraform in the Jenkins Server

- In order for Jenkins to execute Terraform commands, it first needs to be installed onto the instance.
- Similar to the installation of Jenkins, the terraform installation files and keyrings needed to be downloaded from hashicorp.com, decrypted, and added to the sources.list.d directory.
  - wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

  - echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb\_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

  - sudo apt update && sudo apt install terraform

3. Configure AWS credentials on Jenkins

- The ability to create/modify infrastructure requires an AWS user with the proper permissions and privileges. In order for Jenkins to be able to carry out those tasks, AWS credentials must be input.
- AWS\_ACCESS\_KEY and AWS\_SECRET\_KEY were added as "Secret Test" for credentials in Jenkins. The values would then be able to be called on in the Jenkinsfile similarly as variables would be in Python or BASH.

4. Create Terraform files

- Terraform is able to create infrastructure based on configurations that are outlined in terraform files.
- In the project's root directory, terraform reads the file named "main.tf" that includes instructions for how to organize the VPC and EC2.
- Variables that are called in "main.tf" are set in "variables.tf" and defined in "terraform.tfvars".
- Modules were used in this deployment so that the root directory's "main.tf" file was concise and easy to read.
  - The directory named "D4\_Terraform\_Modules" includes two additional directories: 'vpc' and 'instance'
    - Each module directory has its own 'main.tf', 'variables.tf', and 'outputs.tf' files.

5. Additions to pipeline

- Slack notification commands were added to the Jenkinsfile so that the results of each stage in the pipeline would be forwarded to the specified member/channel via Slack.
  - The "Slack Notifications" plugin needs to be updated whenever the EC2 that hosts Jenkins is restarted due to the Public IP address changing each time that happens.
- The file "test\_urls.py" was added to the repository that checked for specific content in the "urls.json" file

6. Build the pipeline

- With all of Jenkins, Jenkinsfile, and the Terraform files set up, a multi-branch pipeline can be created through Jenkins which would pull the files from the GitHub repository and execute all of the commands in the stages as configured in the Jenkinsfile
  - In order for Jenkins to be able to pull from GitHub, a GutHub access token must be input into Jenkins as well as the URL for the repository.
- The pipeline for this deployment included the stages: Build, Test, Init, Plan, Apply.
  - Build- Virtual environment activated and dependencies installed so that Flask run the application
  - Test- pytest runs and performs function tests that are in the application's directory
  - Init- Terraform is initialized in the D4\_Terraform directory so that Terraform commands can be run
  - Plan- Terraform will use the tf files in the directory to plan out the infrastructure that it will need to create and will save the plan as "plan.tfplan"
  - Apply- if the Plan stage was successful, Terraform will apply the plan and build the infrastructure using the AWS credentials saved in Jenkins.
- After all of the stages have successfully completed, the application should be running on port 8000 the public IP of the EC2 that was created.
  - The EC2 itself should be located in the public subnet of the VPC that was also created by Terraform.

7. FOR TESTING PURPOSES ONLY- Add "Destroy" Stage to pipeline

- Because the infrastructure created by Terraform would incur charges if left running, the application and infrastructure should be terminated if the application is not in use.
  - To do this, a "Destroy" stage is added to the pipeline that would terminate all of the infrastructure that was created by it during the other stages.
  - Note: if Jenkins attempts to build the pipeline again, the application will not be running after the stages are complete unless the "destroy" stage is removed from the pipeline.

# ISSUES/TROUBLESHOOTING:

Jenkins pipeline failed after having successful builds- During testing of the pipeline, the stages would suddenly start failing despite having previously successful builds. Looking at the 'console output' revealed the following error:

![](RackMultipart20221027-1-texd2w_html_88c7e0facccb8356.png)

The error code read: 'timeout while waiting for plugin to start.' With some research, it was found that Terraform was unable to perform any more actions because the EC2 (which is also running Jenkins) had reached its limit on resources. The EC2 instance was rebooted and the build was successful after that.

![](RackMultipart20221027-1-texd2w_html_43ea432ebd33a704.png)

# Conclusion:

The infrastructure that an application runs on is as vital to a company's success as the application itself. An application can run flawlessly in a development environment, but in production- if it is not secure, or cannot handle the amount of traffic that it will inevitably have to face during peak hours, it will fail. The ability to modify the infrastructure quickly and effortlessly by using tools like Terraform gives the company full control of how to use their resources efficiently. With Terraform, different configurations can be applied by simply adjusting the value of a variable in a directory. In addition, by reusing Terraform modules in other projects, the risk of having inconsistencies is reduced. If errors occur, one only needs to look at the module that the error is occurring in, or the value of the variable that is set. By not needing to manually create infrastructure, more efforts can be applied to the creation of new, innovating ideas and products.
