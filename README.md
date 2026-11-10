# Financial Operations (FinOps) demo

This project template is designed to practice monitoring on Azure.

## Important Commands

Set an environment variable in Git Bash for the subscription ID

```bash
export ARM_SUBSCRIPCION_ID="my-subscription-ID"
```

Display Azure CLI user

```bash
az account show --query "{subscription:id, state:state}" --output table
```

Connect to a VM using a TLS key

```bash
ssh -i ~/.ssh/vm1 my-admin@my-public-ip
```
