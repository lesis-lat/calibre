# How to Create an Access Key in AWS for Security Audit

1. **Access IAM**: Go to the IAM console at [console.aws.amazon.com/iam/home](https://console.aws.amazon.com/iam/home).
2. **Click on "Users"**: In the left-hand menu, select "Users."
3. **Click on "Add Users"**: Press the button to add a new user.
4. **Set a username**: Enter a descriptive username, such as `calibre-security-audit`, and click "Next."
5. **Assign permissions**:
   - Select the option **"Attach policies directly."**
   - In the "Permissions policies" search bar, locate and select the following policies:
     - **SecurityAudit**
     - **ReadOnlyAccess**
   - Click "Next."
6. **Review and create the user**: Verify the details and click **"Create User."**
7. **Open the user details**: Click on the username to view the user's details.
8. **Create an access key**: On the right-hand side of the screen, click **"Create access key."**
9. **Choose CLI option**:
   - Select **"Command Line Interface (CLI)"** as the use case.
   - Check **"I understand the above recommendation and want to proceed to create an access key."**
   - Click "Next."
10. **Generate the access key**: Click **"Create access key."**
11. **Save the key securely**: Copy the **Access Key ID** and **Secret Access Key**, and save them in a secure location.

> ⚠️ **Important**: Ensure the access key details are stored securely. Do not share them or expose them publicly.
> The user will have CLI access only and will not be able to access the AWS Management Console.