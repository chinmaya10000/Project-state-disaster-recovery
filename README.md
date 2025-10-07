# OpenTofu Infrastructure Migration & Disaster Recovery Setup

## Overview
This repository contains infrastructure-as-code (IaC) originally written in **Terraform** and successfully migrated to **OpenTofu**.  
The setup includes a secure backend for OpenTofu state files using **S3 + DynamoDB**, cross-region replication for disaster recovery (DR), and AWS provider modules compatible with both tools.

OpenTofu still uses the **HashiCorp registry** for provider versions, ensuring compatibility while being fully open-source.

---

## Features

- **OpenTofu migration** from Terraform (v1.13.3)
- **S3 backend** with versioning for reliable state management
- **DynamoDB table** for state locking to prevent concurrent modifications
- **Cross-region S3 replication** for disaster recovery (DR)
- **Provider versions** compatible with existing Terraform code
- Tested and verified with `tofu plan` and incremental changes

---

## Prerequisites & Migration Steps

Before migrating Terraform code to OpenTofu, the following steps were performed:

1. **Prepare a Disaster Recovery Plan**  
   Create a documented plan for state recovery and cross-region replication.

2. **S3 Backend Cleanup**  
   Remove any usage of `use_legacy_workflow` from S3 backend configurations.

3. **Apply Pending Terraform Changes**  
   Ensure all infrastructure is up-to-date (`terraform apply`).

4. **Install OpenTofu CLI**  
   Download and install the latest OpenTofu version compatible with your code.

5. **Backup the State File**  
   Download the latest `.tfstate` from S3 and confirm S3 versioning is enabled.

6. **Initialize OpenTofu**  
   ```bash
   tofu init
   ```

7. **Inspect the Plan**  
   ```bash
   tofu plan
   ```

8. **Test Small, Non-Critical Changes**  
   ```bash
   tofu apply
   ```

---

## Disaster Recovery (DR) Configuration

- **Primary S3 Bucket:** Stores the main OpenTofu state file.
- **DR S3 Bucket:** Receives replicated state files for disaster recovery.
- **Versioning Enabled:** Maintains multiple versions for recovery.
- **Replication Role & Policy:** S3 role allows secure object replication.
- **DynamoDB Table:** Locks the state file during concurrent runs.

This setup ensures state files are safe, recoverable, and versioned in case of accidental deletion or regional outages.

---

## Rollback Procedure

If migration issues occur (e.g., with OpenTofu 1.10.x):

1. **Backup the State File** again.
2. **Remove OpenTofu 1.10.x** and install a previous version (1.7.x/1.8.x/1.9.x).
3. Run:
   ```bash
   tofu init
   tofu plan
   ```
4. Test with a small, non-critical change to confirm rollback works.

---

## Usage

After migration, manage infrastructure with the OpenTofu workflow:

1. **Initialize the working directory:**
   ```bash
   tofu init
   ```
2. **Inspect planned changes:**
   ```bash
   tofu plan
   ```
3. **Apply infrastructure changes:**
   ```bash
   tofu apply
   ```
4. **Destroy resources if needed:**
   ```bash
   tofu destroy
   ```

---

## Providers

OpenTofu still uses the HashiCorp registry for providers. Example:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

---

## Verification Checklist

- Ensure DR bucket replication works by checking versions.
- Test small changes to confirm infrastructure applies correctly.
- Monitor DynamoDB for state locking during concurrent runs.

---

## Notes

- This repository demonstrates state migration, disaster recovery, and safe OpenTofu usage.
- The migration preserves all Terraform behavior while moving to an open-source, community-driven tool.

---

## Interview Questions & Suggested Answers

### Q1: What is the difference between Terraform and OpenTofu?
**A1:**  
OpenTofu is an open-source fork of Terraform, fully compatible with Terraform HCL and provider modules.  
OpenTofu is community-driven and fully open-source, while Terraform uses a Business Source License (BSL) for some features.  
CLI commands are nearly identical (`tofu init`, `tofu plan`, `tofu apply`), and OpenTofu optionally uses its own provider registry.

---

### Q2: Why did you migrate Terraform to OpenTofu?
**A2:**  
Terraform core moved to a BSL, which restricts some commercial or SaaS use.  
OpenTofu is fully open-source, removing these restrictions, while keeping full HCL and provider compatibility.  
Migration allows continued use of the same IaC, state management, DR workflows, and provider modules without licensing concerns.  
Providers (such as `hashicorp/aws`) remain MPL-licensed, so compatibility is preserved.

---

### Q3: How did you migrate Terraform code to OpenTofu?
**A3:**  
- Prepared a DR plan and backed up state files.
- Cleaned up deprecated S3 backend settings.
- Installed OpenTofu CLI.
- Initialized with `tofu init`.
- Verified with `tofu plan` and `tofu apply`.
- Validated state replication and locking.

---

### Q4: How is disaster recovery handled in your setup?
**A4:**  
- Primary state in an S3 bucket with versioning.
- DR bucket in a separate region with cross-region replication.
- DynamoDB table for state locking.
- In case of deletion or regional outage, the DR bucket provides a recoverable copy.

---

### Q5: Are there any differences in providers when using OpenTofu?
**A5:**  
- OpenTofu can use the HashiCorp provider registry, preserving existing versions and functionality.
- Dependency lock files are updated to OpenTofu registry checksums but version numbers remain the same.

---

## License

This repository and all code are released under the [LICENSE](./LICENSE) specified in this repo.  
OpenTofu is [MPL-licensed](https://github.com/opentofu/opentofu/blob/main/LICENSE), and HashiCorp providers remain under their original licenses.

---