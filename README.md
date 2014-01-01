Juniper Top of Rack tempating engine for EX4200 series including virtual chassis if required. 
Additional template for management switch included also. 

Usage 
```

:~/code/torgen/bin$ ruby torgen.rb 
Missing options: silo
Usage: torgen [options]
    -s, --silo SILO                  E.g prod.dc1 or nprd.dc1
    -c, --csv [CSV]                  CSV file conversion script for template generation
    -f, --file FILE                  YAML file containing SW devices to template
    -t, --template [TEMPLATE]        Template type using set or hierarcy Junos wnaset (tor, tor_set, mgmt_set, mgmt, vlan, generic) Default: tor
    -h, --help
```

To convert specially formatted CSV file ../csv/SWADD.csv containing details on TOR switches into YAML data file for ingestion by templating engine for silo/site = prod.dc1  (Note silo is a mandatory switch) 
Contents of SWADD.csv

```
Host,vcp0,vcp1,ipaddr,vcp
asw011,BP6612466148,BP6613024113,10,vcp
asw012,BP6613024084,BP6612446321,11,vcp
asw021,BP6612446379,BP6613024920,12,vcp
```



```
:~/code/torgen/bin$ ruby torgen.rb -s prod.dc1 -c ../csv/SWADD.csv
	 Generating YAML SW source file ../yaml/prod.dc1-capadd.yaml
---
:hostnames:
  asw011:
    :vcp0: BP6612466148
    :vcp1: BP6613024113
    :ipaddr: 10
    :vcp: vcp
  asw012:
    :vcp0: BP6613024084
    :vcp1: BP6612446321
    :ipaddr: 11
    :vcp: vcp
  asw021:
    :vcp0: BP6612446379
    :vcp1: BP6613024920
    :ipaddr: 12
    :vcp: vcp
```
 
To use this YAML file for ingestion into the templating engine for silo prod.dc1 and for default Juniper template to create hierarchical config for a TOR  
```
:~/code/torgen/bin$ ruby torgen.rb -s prod.dc1 -f ../yaml/prod.dc1-capadd.yaml 
	 Generating ../prod.dc1/asw011.prod.dc1.wd.wnaset
	 Generating ../prod.dc1/asw012.prod.dc1.wd.wnaset
	 Generating ../prod.dc1/asw021.prod.dc1.wd.wnaset
```
If you want to use different template e.g creation of TOR config using set commands instead 

```
:~/code/torgen/bin$ ruby torgen.rb -s prod.dc1 -f ../yaml/prod.dc1-capadd.yaml -t tor_set
	 Generating ../prod.dc1/asw011.prod.dc1.wd.wnaset
	 Generating ../prod.dc1/asw012.prod.dc1.wd.wnaset
	 Generating ../prod.dc1/asw021.prod.dc1.wd.wnaset

```
Example contents below of asw011.prod.dc.wd.wnaset
```
:~/code/torgen/bin$ more ../prod.dc1/asw011.prod.dc1.wd.wnaset 
set system host-name asw011.prod.dc1.wd
set system services ssh root-login allow
set system services ssh protocol-version v2
set system root-authentication encrypted-password "XXXXXX"
del interfaces vme unit 0 family inet dhcp
set interfaces vme unit 0 family inet address 10.16.29.10/20 
set interfaces xe-0/1/0 disable 
set interfaces xe-0/1/0 unit 0 family ethernet-switching port-mode trunk
set interfaces xe-0/1/0 unit 0 family ethernet-switching vlan members all
delete protocol rstp
```
