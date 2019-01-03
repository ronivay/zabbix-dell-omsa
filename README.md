# Dell Omsa Zabbix monitoring

This repository includes script, config and zabbix template for monitoring different components and information from a dell server running omsa on linux.

Tested with:
OMSA: 8.1.0
Zabbix: 4.0.0

#### OMSA

Dell OpenManage Server Administrator tools allows you to query and configure physical components on the server.

https://www.dell.com/support/article/yu/en/yudhs1/sln312492/openmanage-server-administrator-omsa?lang=en

#### Zabbix

Zabbix is an open source monitoring solution

https://www.zabbix.com/

#### What

Script and template in this repository will monitor the most important components and information from the server. It won't show every little detail provided by omsa. Below is a list of provided information:

Discovered items:
- Virtual disks and their controller
- Physical disks and their controller
- Fans with their index number
- PSU's with their index number
- Temperature sensors
- RAM with their index number

Monitored items and triggers:
- Individual physical disks and their status
  `Trigger: physical disk not online or predictive failure is true`
- Individual virtual disk RAID type/size and status
  `Trigger: virtual disk status is not ok`
- Individual fans and their status and RPM
  `Trigger: fan status not ok`
- Individual PSU's and their status
  `Trigger: PSU status not ok`
- Individual temperature sensors and their value
- Individual RAM modules and their status
  `Trigger: RAM status not ok`
- Server model
- Server service tag
- Server BIOS version
- Server iDRAC version
- Server general health status
  `Trigger: if any of the status indicators is not ok`

This is all based on what i find useful. If you think something important is missing, please make a pull request or suggestion to make it even better.

#### Installation

- Start up by installing dell omsa if you don't have it already. Follow instructions in: http://linux.dell.com/repo/hardware/omsa.html

- Clone this repository to your zabbix-agent path
```
git clone https://github.com/ronivay/zabbix-dell-omsa /etc/zabbix/dell-omsa
```
- Edit your zabbix agent configuration and add
```
Include=/etc/zabbix/dell-omsa/omsa.conf
```
- Restart zabbix-agent

- Add sudo permissions for zabbix-agent to run omsa.sh script
```
visudo

add line:
zabbix ALL=(ALL)  NOPASSWD: /etc/zabbix/dell-omsa/omsa.sh
```
Zabbix agent part is now done, we can move to our zabbix-server

* Download the `dell-omsa-template.xml` file from this repository to your local machine and open your zabbix-server WebUI.

* Navigate to `configure` -> `templates` -> `import`

* Choose the .xml file and hit import

Now we should have a new template called `Template OMSA` which we can add to our host.

Many of the items are checked once in 24hours since they are something that won't really change. Failing and changing items are checked more frequently, but not more often than 5minutes. Feel free to change these values if you wish.

#### Tips

omsa.sh script has a OMSABIN variable which points by default to `/opt/dell/srvadmin/bin/omreport`
If for some reason your omsa installation is located somewhere else, you need to change this variable.

