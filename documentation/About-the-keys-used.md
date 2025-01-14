### Why is This Type of Access Key Necessary for Security Audits?

In a security audit, it is crucial to have a user that can access AWS resources and configurations programmatically in order to analyze the environment’s security posture, investigate potential vulnerabilities, and gather necessary data. An Access Key is required for this purpose because it allows automation and access via the AWS Command Line Interface (CLI), SDKs, or APIs, which is essential for conducting thorough security audits without manual intervention through the AWS Management Console.

This approach ensures that the audit process can be automated, repeatable, and consistent, which is critical for tracking security changes over time and for compliance with security best practices. Additionally, by using programmatic access, auditors can avoid human error associated with manual logins and work directly with AWS resources in a secure and controlled manner.

---

### What Permissions Does This Access Key Have?

The access key created for the security audit user is granted the following permissions:

**SecurityAudit:**

This policy provides read-only access to a wide range of AWS services for auditing purposes. It enables the user to view configurations and settings across the account but prevents making changes to any resources. The goal is to allow auditors to gather information about the security state of the environment, such as IAM roles, security groups, and network configurations, without the risk of modifying the resources.

**ReadOnlyAccess:**

This policy grants the user read-only access to all AWS resources. This is essential for auditing because it ensures that the auditor can inspect the state of various services and resources in the account, including EC2 instances, S3 buckets, IAM policies, and more. However, they cannot make any changes, ensuring the audit process remains non-invasive and does not inadvertently alter the environment.

---

Access keys generated with the SecurityAudit and ReadOnlyAccess policies do not have the ability to modify any resources or configurations within the AWS account. These keys are strictly read-only, meaning they can only be used to view the state of resources, but not to change or delete anything. As a result, they cannot cause any negative impact on the environment, ensuring that the auditing process is non-invasive. This makes them ideal for security audits, as auditors can gather necessary information and perform assessments without the risk of accidentally altering settings or disrupting services.