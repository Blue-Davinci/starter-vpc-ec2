# Terraform VPC with EC2 - Modular Infrastructure

This project creates a modular AWS infrastructure using Terraform, allowing for environment-specific deployments (development, production, etc.). The architecture follows Terraform best practices with clear separation of components.

## 🌟 Key Features
- **Environment Isolation**: Separate configurations for development/production
- **Modular Design**: Reusable components for network and compute
- **Makefile Automation**: Simplified deployment workflows
- **Remote State Management**: Secure state storage with S3 backend
- **Infrastructure as Code**: Fully reproducible AWS resources


## 🌟 Key Features
- **Environment Isolation**: Separate configurations for development/production
- **Modular Design**: Reusable components for network and compute
- **Makefile Automation**: Simplified deployment workflows
- **Remote State Management**: Secure state storage with S3 backend
- **Infrastructure as Code**: Fully reproducible AWS resources

<br>


## Project Structure
```bash
│   .gitignore
│   README.md
│
├───backend
│   │   .terraform.lock.hcl
│   │   backend.plan
│   │   main.tf
│   │   outputs.tf
│   │   providers.tf
│   │   terraform.tfstate
│   │   variables.tf
│
└───infra
    │   .terraform.lock.hcl
    │   infra.plan
    │   main.tf
    │   outputs.tf
    │   providers.tf
    │   variables.tf

```


## 🚀 Deployment Workflows

### Prerequisites
- Terraform v1.0+
- AWS CLI configured
- Make (for simplified commands)

### 🔧 Initial Setup
1. Clone the repository:
```bash
git clone https://github.com/Blue-Davinci/starter-vpc-ec2
cd starter-vpc-ec2
```

2. Bootstrap the remote backend (S3 + DynamoDB):
```bash
make deploy/backend
```

## 🏗 Environment Deployment

**Using Makefile (Recommended)**
```bash
# Show available commands
make help

# Deploy to development environment
make deploy/modularized ENV=development

# Deploy to production environment
make deploy/modularized ENV=production

# Destroy development environment
make destroy/modularized ENV=development
```
**Manual Deployment**

1. Navigate to your target environment:
```bash
cd environment/<ENV_NAME>
```

2. Initialize Terraform:
```bash
terraform init
```
    
3. Review and apply:
```bash
terraform plan -out "infra.plan"
terraform apply "infra.plan"
```

## 🧹 Cleanup
```bash
# Destroy specific environment
make destroy/modularized ENV=development

# Destroy backend infrastructure (after all environments are destroyed)
cd bootstrap
terraform destroy
```

## 🧩 Module Structure
1. Network Module

    - VPC with public/private subnets

    - Internet Gateway

    - Route tables

    - NAT Gateway **(optional, in next update of the series)**

    - Security Groups

2. Compute Module

    - EC2 instances

    - Auto Scaling Groups  **(optional, in next update of the series)**

    - Load Balancers  **(optional, in next update of the series)**

    - Route 53  **(optional, in next update of the series)**

    - User-data scripts

## 🔄 Workflow Diagram
```bash
graph TD
A[Make Command] --> B[Select Environment]
B --> C[Initialize Backend]
C --> D[Deploy Modules]
D --> E[Network Components]
D --> F[Compute Components]
```

## 🛠 Makefile Reference
| Command                               | Description                        |
|---------------------------------------|------------------------------------|
| `make help`                           | Show available commands            |
| `make deploy/backend`                 | Deploy S3/DynamoDB backend         |
| `make deploy/modularized ENV=<env>`   | Deploy to specified environment    |
| `make destroy/modularized ENV=<env>`  | Destroy specified environment      |

## 🔒 Security Notes

1. Always review Terraform plans before applying

2. Production environment should have additional safeguards

3. Consider adding state encryption for sensitive data

## 📝 Best Practices

1. Version Control: Always commit your Terraform files

2. State Management: Never modify state files manually

3. Variables: Use variables for environment-specific values

4. Modules: Keep modules focused and reusable

5. Documentation: Update README when making changes