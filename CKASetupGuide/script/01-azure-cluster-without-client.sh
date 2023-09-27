loc=eastus
rg='rg-cka'
# storageacc=wgckastorage
vmimage=ubuntults
#shutdownutc=1230 #Auto Shutdown time in UTC

vnet='cka-vnet';subnet='cka-subnet';
nsg='cka-nsg';

vnetaddressprefix='10.230.0.0/24'
subnetaddressprefix='10.230.0.0/27'

# Controller VM should have > 2 cpu
controllervmsize='Standard_B2s' # check the available vm sizes in your region
size='Standard_B1s'
# az vm list-sizes -l eastus -o table

controllervmprivateip='10.230.0.10'
controllerpip='controller-pip'
controllernic='controller-nic'


workerprivateippref='10.230.0.2'
workeravblset='worker-avblset'


adminuser=cka
echo 'admin username is $adminuser'

adminpwd='SuperSecret12#$'
# ask for password
# read -s -p "Enter admin Password (should be minimum 12 char strong): " adminpwd
# echo $adminpwd #must be min 12 char long with one number, one special char and alphabet

controllervm='controller-vm'

# to stop 
# az vm deallocate --ids $(az vm list -d -g $rg --query "[?powerState=='VM running'].id" -o tsv)
# az vm deallocate --ids $(az vm list -d -g $rg --query "[].id" -o tsv)
echo "----------------- 1 Creating Resource Group -----------------"
# Create Resource Group in 
az group create -n $rg -l $loc

echo "----------------- 2 Creating Storage Account -----------------"
# Create storage account and storage container
# No need to create any container or use the storage account name while creating vm 
# Because VM will find a storage account in the same resource group and create a container if not present vhds 
# if no storage account is available then vm create will create a storage account if --use-umamanged-disk option is provided.
# az storage account create -n $storageacc -g $rg --sku Standard_LRS
#az storage container create -n vmhdd --account-name $storageacc
echo "Storage Account will be created Automatically while the first VM is created. This is to avoid the name conflict."

echo "----------------- 3 Creating Virtual Network -----------------"
# Create virtual network
az network vnet create -g $rg -n $vnet --address-prefix $vnetaddressprefix

echo "----------------- 4 Creating NSG -----------------"
# Create NSG
az network nsg create -g $rg -n $nsg

# Create a firewall rule to allow external SSH and HTTPS
az network nsg rule create -g $rg -n k8s-allow-ssh --access allow --destination-address-prefixes '*' --destination-port-range 22 --direction inbound --nsg-name $nsg --protocol tcp --source-address-prefixes '*' --source-port-range '*' --priority 1000

az network nsg rule create -g $rg -n k8s-allow-api-server --access allow --destination-address-prefixes '*' --destination-port-range 6443 --direction inbound --nsg-name $nsg --protocol tcp --source-address-prefixes '*' --source-port-range '*' --priority 1001

echo "----------------- 5 Creating Subnet -----------------"
# Create Subnet
az network vnet subnet create -g $rg --vnet-name $vnet -n $subnet --address-prefixes $subnetaddressprefix --network-security-group $nsg

echo "----------------- 6 Creating Ccontroller VM's Public IP -----------------"
# Create nic and pip for controller VM
az network public-ip create -n $controllerpip -g $rg


echo "----------------- 7 Creating Controller VM' NIC -----------------"
# Controller NIC
az network nic create -g $rg -n $controllernic --private-ip-address $controllervmprivateip --public-ip-address $controllerpip --vnet $vnet --subnet $subnet --ip-forwarding

echo "----------------- 8 Creating Controller VM and Provisioning AutoShutdown -----------------"

# Provision controller VM use  --no-wait

az vm create -g $rg -n $controllervm --image $vmimage --nics $controllernic --size $controllervmsize --authentication-type password --admin-username $adminuser --admin-password $adminpwd --use-unmanaged-disk --storage-sku Standard_LRS --os-disk-size-gb 30

# az vm create -g rg-cka -n controller --image UbuntuLTS --size Standard_DS2 --use-unmanaged-disk --authentication-type=password --admin-username wriju --admin-password 'P@ssw0rd!!!!'
#az vm auto-shutdown -g $rg -n $controllervm --time $shutdownutc

# WORKER
echo "----------------- 9 Creating Worker VM's NIC, VM and Provisioning AutoShutdown -----------------"
# Create availability set, nics and pips for worker VMs
az vm availability-set create -g $rg -n $workeravblset --unmanaged

# Provision worker VMs
# Use Loop for >1 nic and VMs - no Public IP
#for i in 0 1; do
for i in 0 1; do	
	echo "----------------- 10a. Creating Worker VM's Public IP($i) -----------------"
	az network public-ip create -n worker-${i}-publicip -g $rg 

	echo "----------------- 10b. Creating Worker VM's NIC($i) -----------------"
	az network nic create -g $rg -n worker-${i}-nic --private-ip-address $workerprivateippref${i} \
			--public-ip-address worker-${i}-publicip --vnet $vnet --subnet $subnet --ip-forwarding

	# az network nic create -g $rg -n worker-${i}-nic --private-ip-address $workerprivateippref${i} \
	# 		--vnet $vnet --subnet $subnet --ip-forwarding

	echo "----------------- 10c. Creating Worker VM($i) -----------------"
	az vm create -g $rg -n worker-${i} --image $vmimage --availability-set  $workeravblset \
		--nics worker-${i}-nic --size $size --authentication-type password --admin-username $adminuser \
		--admin-password $adminpwd --use-unmanaged-disk --storage-sku Standard_LRS --os-disk-size-gb 30
	
	echo "----------------- Configuring Worker VM's Auto Shutdown($i) -----------------"
 	#az vm auto-shutdown -n worker-${i} -g $rg --time $shutdownutc #UTC Zone
done

echo "----------------- DONE -----------------"

# delete all resources
# az group delete -n rg-cka -y


# # ArgoCD
# az network nsg rule create -g rg-cka -n argocd-allow-server-http --access allow --destination-address-prefixes '*' --destination-port-range <NodePort> --direction inbound --nsg-name cka-nsg --protocol '*' --source-address-prefixes '*' --source-port-range '*' --priority 1002
# az network nsg rule create -g rg-cka -n argocd-allow-server-https --access allow --destination-address-prefixes '*' --destination-port-range <NodePort> --direction inbound --nsg-name cka-nsg --protocol '*' --source-address-prefixes '*' --source-port-range '*' --priority 1003