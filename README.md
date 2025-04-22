# 📦 Automated Infrastructures – School Project

This repository contains all Terraform, Ansible, Docker, and Bicep code used throughout the **"Automated Infrastructures"** course at Saxion University. The fictional company used in this project is **Pixel Perfect**, a web design agency aiming to modernize its infrastructure by adopting Infrastructure as Code, containers, and cloud-native principles.

---

## 🏢 Project Context: Pixel Perfect (Case Study)

Pixel Perfect has two DevOps teams:
- **Platform Team** — focused on Joomla and WordPress
- **WebApp Team** — builds custom websites

Their current setup is based on VMware and scattered scripts. The company wants to:
- Migrate to **AWS**
- Adopt **Infrastructure as Code** (Terraform, Ansible, Bicep)
- Containerize workloads using **Docker**
- Enable **HA production environments** with auto-provisioned test/stage setups

---

## 📆 Timeline & Weekly Themes

Each week focuses on different technologies and goals:

### Week 1 - "Terraform: Foundations"
- First VPC in AWS
- Public Subnet, Security Groups
- Simple EC2 Instance

### Week 2 - "Modularity"
- Refactor code into reusable **Terraform modules**
- Add `variables.tf`, `outputs.tf`, and dynamic config structure

### Week 3 - "Ansible Basics"
- First steps with **Ansible** for instance provisioning
- Install Docker & serve HTML or CMS containers

### Week 4 - "Roles, Variables & Templating"
- Use **Ansible roles** for WordPress, Joomla, and Custom websites
- Add `group_vars`, conditionals, and templated pages

### Week 5 - "Load Balancing & Security"
- Deploy **NGINX load balancer** in Docker
- Use Ansible to set up secure users (`servmanager`, etc.)

### Week 6 - "Windows, AD & Firewalls"
- Configure **Windows 10** and **Server 2022** with Ansible
- Manage AD users via YAML/CSV and interact with PFSense

### Week 7 - "Azure & Bicep"
- Deploy to **Azure** using **Bicep**
- Compare IAC tools and write deployment advice

---

## 🏗️ OTAP Environments per Client

Each client can request:
- **Test Environment** (1 EC2 instance with Docker)
- **Production Environment** (3 EC2 instances with Docker & Load Balancer)

Workloads can be:
- WordPress (containerized)
- Joomla (containerized)
- Custom static HTML with customer greeting and logo

---

## 🧰 Technologies Used

| Tech         | Purpose                                  |
|--------------|-------------------------------------------|
| Terraform    | Provision AWS infrastructure             |
| Ansible      | Configure servers & deploy containers    |
| Docker       | Containerize workloads (CMS/static sites)|
| Bicep        | Deploy Azure workloads (Week 7)          |
| AWS          | Cloud provider for infrastructure        |
| YAML/CSV     | Manage users (AD setup)                  |

---

## 📁 Project Structure

```bash
Week 1 - Intro (Terraform, AWS)/
Week 2 - Terraform - variables and modules/
Week 3 - Ansible Intro/
Week 4 - Ansible Roles/
Week 5 - Advanced Ansible + Loadbalancer/
Week 6 - Windows, AD, PFSense/
Week 7 - Azure & Bicep/
```

---

## 🗂️ Example Client Folders

```bash
klantA/test/   # One instance, basic webserver
klantA/prod/   # 3 instances, HA setup, load balanced
klantB/prod/   # WordPress containers
klantC/prod/   # Joomla setup
```

---

## 🚀 Getting Started

### Install required tools

```bash
# Using winget on Windows
winget install -e --id Amazon.AWSCLI
winget install -e --id Hashicorp.Terraform
```

### Set AWS Credentials

```bash
aws configure
```

Or manually create this file:

```ini
~/.aws/credentials

[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
```

### Generate your SSH key

```bash
# Windows
ssh-keygen -t rsa -b 4096 -f "$HOME\.ssh\awskey"

# Linux/macOS
ssh-keygen -t rsa -b 4096 -f ~/.ssh/awskey
```

### Set environment variables

```powershell
# PowerShell (Windows)
$env:TF_VAR_user_home = $env:USERPROFILE
$env:TF_VAR_public_key_path = "$env:USERPROFILE/.ssh/awskey.pub"
```

```bash
# Bash (Linux/macOS)
export TF_VAR_user_home="$HOME"
export TF_VAR_public_key_path="$HOME/.ssh/awskey.pub"
```

### Alternatively: Use `terraform.tfvars`

If environment variables don’t work, you can edit this file directly:

```hcl
# terraform.tfvars

user_home       = "C:/Users/yourname"
public_key_path = "C:/Users/yourname/.ssh/awskey.pub"
```

---

## 🛠️ Run Terraform

```bash
terraform init
terraform plan
terraform apply
```

After applying, connect to a created instance using the public IP address:

```powershell
ssh -i .\.ssh\awskey ec2-user@<PUBLIC_IP>
```

Example output:

```bash
ssh -i .\.ssh\awskey ec2-user@ip-address
...
Amazon Linux 2023
```

---

## ⚙️ Customization

You can override any variable by:
- Using `terraform.tfvars` (preferred)
- CLI flags: `terraform apply -var="instance_count=3"`

---

Each user must:
- Generate their own key
- Set `TF_VAR_user_home` and `TF_VAR_public_key_path`
- Never commit credentials

---

## 🔁 Dynamic SSH Key Path (Cross-platform)

Define these in `variables.tf`:

```hcl
variable "user_home" {
  description = "The home directory of the user"
  type        = string
}

variable "ssh_key_name" {
  description = "The name of the SSH key file"
  type        = string
  default     = "awskey.pub"
}
```

Use them in your module:

```hcl
module "shared_key" {
  source           = "../../Modules/SharedKey"
  key_name         = "awskey"
  public_key_path  = "${var.user_home}/.ssh/${var.ssh_key_name}"
}
```

---

## 📄 License

MIT License. See `LICENSE` file.
