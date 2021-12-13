# Azure Api Multi Deployment
Creating an automatic process to build infrastructure to deploy Api in multiples layers and platforms with strong security
# Infrastructure
![Infrastructure](/images/az-multi-deployment-infra.png)

# Pipelines
A pipeline is the best way to deployment resources in azure on autamtic, we will have the following pipelines, regardless of the use of powershell or azure cli.

#### Infrastructure pipelines
<ol>
  <li>ml-base-infrastructure.yml </li>
  <li>ml-secrets-and-exampledata.yml</li>
  <li>ml-deploy-appservice.yml</li>
  <li>ml-deploy-azure-container-instaces.yml</li>
  <li>ml-deploy-azure-function.yml</li>
  <li>ml-deploy-windows-vm.yml</li>
  <li>ml-deploy-linux-vm.yml</li>
  <li>ml-deploy-aks-vm.yml</li>
</ol>

# All in PowerShell (Windows Scripting)

# All in Azure Cli (Linux Bash)

