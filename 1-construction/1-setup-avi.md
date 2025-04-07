- [Guide](#guide)
- [WELCOME ADMIN](#welcome-admin)
- [Administration](#administration)
  - [License](#license)
  - [NTP](#ntp)
  - [Regenerate a new Server cert for the avi-controller](#regenerate-a-new-server-cert-for-the-avi-controller)
- [Infrastructure](#infrastructure)
  - [Clouds](#clouds)
  - [Cloud Resources - Service Engine Group](#cloud-resources---service-engine-group)
  - [Cloud Resources - Networks](#cloud-resources---networks)
  - [Cloud Resources - VRF Context](#cloud-resources---vrf-context)
- [Templates - IPAM Profile](#templates---ipam-profile)
- [Test deploy - AVI-SE](#test-deploy---avi-se)

# Guide
- [official](https://techdocs.broadcom.com/us/en/vmware-tanzu/standalone-components/tanzu-kubernetes-grid/2-5/tkg/mgmt-reqs-network-nsx-alb-install.html)
- [Download ALB](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware%20Avi%20Load%20Balancer)
  - Target AVI Load Balancer version is `v22.1.7`


# WELCOME ADMIN
- DNS Resolvers: `192.168.201.1`
- DNS Search Domain: `lab.net`
- Email/SMTP: `None`
- Multi-Tenant: Default
- Check "Setup Cloud After"
- SAVE

# Administration

## License
- Enterprise license is required to enable auto upload OVA into Content Library
- (TOP) Administration --> Licensing
  - Click gear icon
  - Select `Enterprise Tier`
  - SAVE

## NTP
- (TOP) Administration --> System Settings --> EDIT --> DNS/NTP - NET Servers
  - Delete existing 4 servers
  - Add `192.168.201.1`
  - SAVE

## Regenerate a new Server cert for the avi-controller
- (TOP)Templates --> Security --> SSL/TLS Certificates --> CREATE --> Controller Certificate
  - Name; `alb-s1.lab.net`
  - Common Name: `alb-s1.lab.net`
  - Subject Alternate Name (SAN) --> ADD
    - Name: `alb-s1.lab.net`
  - SAVE
- Apply the new generated cert against this avi-controller
  - (TOP) Administraton --> System Settings --> EDIT --> Access --> SSL/TLS --> SSL/TLS Certificate
    - Delete existing 2 certs
      - System-Default-Portal-Cert
      - System-Default-Portal-Cert-EC256
    - Select a new created cert: `alb-s1.lab.net`
    - Do not change "Secure Channel SSL/TLS"
    - SAVE
  - Reload the browser, check server cert via browser
  
# Infrastructure
## Clouds
- (TOP) Infrastructure --> Clouds --> Default-Cloud --> Click edit icon
  - General
    - Type: `VMware vCenter/vSphere ESX`
    - Template Service Engine Group: `Default-Group`
  - vCenter/vSphere
    - SET CREDENTIALS
      - vCenter Address: `vc-s1.lab.net`
      - Username: `administrator@vsphere.local`
      - Password: `xxxxxxxxxxxxxxx`
  - Data Center - `Datacenter`
  - Use Contet Library: Check
  - Content Library: `cl-1`
  - SAVE & RELAUNCH
  - Management Network: `vlan201-mgmt`
  - IP Subnet: `192.168.201.0/24`
  - Default Gateway: `192.168.201.1`
  - Static IP Adderss Pool: `192.168.201.110-192.168.201.119`
  - SAVE

## Cloud Resources - Service Engine Group
- (TOP) Infrastructure --> Cloud Resources --> Service Engine Group --> Default-Group --> Click edit icon
- Placement
  - High Availability Mode: N+M
- Service Engine
  - Number of Service Engines: 10 --> 1
  - Buffer Service Engines: 1 --> 0
    - [williamlam](https://williamlam.com/2021/09/quick-tip-how-to-deploy-nsx-advanced-load-balancer-nsx-alb-with-a-single-service-engine.html)
- Virtual Service
  - Virtual Service per Service Engine: 10 --> 30 (Max number of the VIP)
- SAVE

## Cloud Resources - Networks
- (TOP) Infarstructure --> Cloud Resources  --> Networks
- Select vlan202-vip --> Click Edit icon
  - Subnets --> ADD
  - Subnet Prefix: `192.168.202.0/24`
  - Check `Use Static IP Address for VIPs and SE`
  - Static IP Ranges --> ADD
    - `192.168.202.110-192.168.202.129`
    - SAVE
  - SAVE
- Select vlan203-workload --> Click Edit icon
  - Subnets --> ADD
  - Subnet Prefix: `192.168.203.0/24`
  - `UnCheck` - Use Static IP Address for VIPs and SE
  - Static IP Ranges --> ADD
    - `192.168.203.110-192.168.203.129`
    - Use For: `SE vNIC`
    - SAVE
  - SAVE

## Cloud Resources - VRF Context
- (TOP) Infarstructure --> Cloud Resources  --> VRF Context
- Edit global
  - Static Route --> ADD
    - Gateway Subnet: `0.0.0.0/0`
    - Next Hop: `192.168.202.1`
    - SAVE

# Templates - IPAM Profile
- (TOP) Templates --> Profiles --> IPAM/DNS Profiles --> CREATE --> IPAM Profile
  - Name: `ipam-profile-vip-s1`
  - Cloud: `Default-Cloud`
  - Usable Networks --> ADD
    - Select `vlan202-vip - 192.168.202.0/24`
  - SAVE
- (TOP) Infrastructure --> Clouds --> Default-Cloud --> Click edit icon
  - Select IPAM/DNS tab
  - IPAM Profile - `ipam-profile-vip-s1`
  - SAVE

# Test deploy - AVI-SE
- (TOP) Applications --> Virtual Services --> CREATE VIRTUAL SERVICE --> Basic Setup
  - Name: test
  - VS VIP --> Create VS VIP
    - VIPs --> ADD
      - VIP Address Allocation Network: Select `vlan202-vip - 192.168.202.0/24`
      - IPv4 Subnet: Select `192.168.202.0/24`
      - SAVE
    - SAVE
  - Save
- Go back to vCenter UI, new AVI-SE OVA file will be uploaded to the Content Library
- New AVI-SE VM will be deployed
