<p align="center">
  <h3 align="center"><b>Calibre</b></h3>
  <p align="center">Continuous monitoring of Security Issues in AWS Env using Steampipe's query-driven rules.
</p>
  <p align="center">
    <a href="https://github.com/instriq/calibre/blob/master/LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg">
    </a>
     <a href="https://github.com/instriq/calibre/releases">
      <img src="https://img.shields.io/badge/version-0.0.1-blue.svg">
    </a>
  </p>
</p>

---

### Summary

Calibre is a tool for continuous monitoring of security issues in AWS environments, using Steampipe's query-driven rules. By executing predefined security rules across multiple AWS accounts, Calibre simplifies complience enforcement and security assessments.

With Calibre you can define customizable cloud security queries in YAML, generate reports for multiple active AWS accounts in your organization and streamline reports through single or multiple reports with output formatted for YAML. 

By default, Calibre comes with 30+ pre-built queries, including reconnaissanse queries for attack surface mapping. However, it's fully extensible — allowing you to _calibrate_ it with your own security rules.

---

### Prerequisites 

- Perl 5.030+
- [AWS CLI](https://hub.steampipe.io/plugins/turbot/aws)
- [Steampipe](https://steampipe.io/)
- [AWS Steampipe Plugin](https://hub.steampipe.io/plugins/turbot/aws)
- AWS credentials with read-only security access

---

### Installation

```bash
# Clone repository
$ git clone https://github.com/yourorg/calibre && cd calibre

# Install libs and dependencies 
$ sudo cpanm --installdeps .
```

---

### Configuration 

Edit the template configuration file (```config.yaml```) to define your organization and associated AWS accounts. Replace placeholder values with actual information, following this format:

```yaml
organization
 name: The name of your organization.
 accounts: A list of accounts, each with the following fields:
  - name: The account's descriptive name.
    code: A unique identifier for the account.
    access_key: AWS access key.
    secret_key: AWS secret key.
    status: Set to 'active' or 'inactive' depending on the account's usage status.
    details: Additional account-specific details such as:
      type: The type of resource (e.g., IAM, S3, EC2).
      region: The AWS region associated with the account (e.g., us-west-1).
```

### Example

```yaml
organization:
 name: "LESIS"
 accounts:
  - name: "PRODUCTION"
    code: "AWS-ACC-001"
    access_key: "AKIA4YFAKEKEYXTDS252"
    secret_key: "SH42YMW5p3EThisIsNotRealzTiEUwXN8BOIOF5J8m"
    status: "active"
    details: 
      type: "IAM"
      region: "us-west-1"

  - name: "QA"
    code: "AWS-ACC-002"
    access_key: "AKIA4YFAKEKEYXTDS252"
    secret_key: "SH42YMW5p3EThisIsNotRealzTiEUwXN8BOIOF5J8m"
    status: "active"
    details: 
      type: "EC2"
      region: "eu-west-1"

```

Add or duplicate account structures as needed.

---

### Usage

```
$ perl calibre.pl

Calibre Tool v0.0.1
Core Commands
==============
Command                 Description
-------                 -----------
-i, --input             Input file with queries in YAML format
-r, --report            Report type:
                        - 's' or 'single' for a single report of all queries
                        - 'm' or 'multiple' for individual reports for each query
-c, --config            Configuration file with data in YAML format

```

### Example

```bash
$ perl calibre.pl --input <QUERY_FILE> --report <REPORT_TYPE> --config <CONFIG_FILE>

$ perl calibre.pl --input aws-queries.yaml --report multiple --config config.yaml
```

---

### Writing Custom Queries

To create custom queries, refer to the [AWS Steampipe plugin documentation](https://hub.steampipe.io/plugins/turbot/aws/tables) for table definitions. After that, add your query to a YAML file, such as ```aws-queries.yaml``` or ```recon-queries.yaml```, or create your own YAML file to add your query, following Calibre's query's format:

```yaml
query_name:
  description: "Query description"
  query: |
```
Below ```query: |``` is where you add your query.

### Example

```yaml
check_mfa:
  description: "Verify and list MFA status for AWS IAM users"
  query: |
    select
      title,
      create_date,
      mfa_enabled
    from
      aws_iam_user
```

Extending Calibre is as easy as this!

---

### Contribution

Your contributions and suggestions are heartily ♥ welcome. [See here the contribution guidelines.](/.github/CONTRIBUTING.md) Please, report bugs via [issues page](https://github.com/instriq/sentra/issues) and for security issues, see here the [security policy.](/SECURITY.md) (✿ ◕‿◕)

---

### License

This work is licensed under [MIT License.](/LICENSE.md)
