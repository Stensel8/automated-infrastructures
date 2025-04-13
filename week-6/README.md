# pfSense Ansible Playbooks

These Ansible playbooks are designed to configure your pfSense firewall using the **pfsensible.core** collection. They provide sample configurations to allow or deny specific traffic types (for example, HTTP/HTTPS, FTP, ICMP, etc.) by modifying firewall rules through pfSense’s API.

## Prerequisites

- **pfSense Setup:**  
  Your pfSense machine must have SSH enabled. To do this, log in via the WebGUI, navigate to *System → Advanced → Admin Access*, and enable Secure Shell.

- **Ansible Collection Installation:**  
  Install the **pfsensible.core** collection:
  ```bash
  ansible-galaxy collection install pfsensible.core
  ```

- **Inventory Configuration:**  
  Ensure your inventory file correctly points to your pfSense device and includes valid SSH credentials. For example:
  ```ini
  [pfsense]
  192.168.1.1 ansible_connection=ssh ansible_user=admin ansible_password=pfsense ansible_python_interpreter=/usr/local/bin/python3
  ```

## Usage

Run any of the provided playbooks with:
```bash
ansible-playbook -i inventory.ini <playbook_name>.yml
```
For example:
```bash
ansible-playbook -i inventory.ini allow_http_https.yml
```

These playbooks use the **pfsense_rule** module (and related modules) from the **pfsensible.core** collection to modify firewall rules on your pfSense device.
