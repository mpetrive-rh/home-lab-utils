#!/usr/bin/env python 
import subprocess
import json
import copy
import yaml
import os

with open("setup-vars.yml") as f:
    setup_vars = yaml.load(f, Loader=yaml.FullLoader)

tf_cmd = "terraform output -state={0}/{1} -json".format(setup_vars["terraform_project_dir"], setup_vars["terraform_project_state_file"])
inv = json.loads(subprocess.check_output(tf_cmd, shell=True))
inv_host = inv["ipv4address"]["value"] if "ipv4address" in inv else []
inv_host_public = inv["ipv4address_bridge"]["value"] if "ipv4address_bridge" in inv else []
inv_host.sort(key=lambda x: int(x.split(".")[3]))

_gv_tmpl = { "hosts" : [], "vars" : {}  }

group_list = [ "database", "automationhub", "tower", "podman" ]
groups = {}
for g in group_list:
    groups[g] = copy.deepcopy(_gv_tmpl)

all = { "all" : { "vars": {} } }
meta = { "_meta": { "hostvars": {} } }


if inv_host:

    default_passwords = setup_vars["_tower_installer"]['passwords_to_default']
                
    db_hosts = setup_vars["_tower_installer"]['db_hosts_to_default']
    db_ports = setup_vars["_tower_installer"]["ports_to_default"]

    cluster_size=setup_vars["_tower_installer"]["cluster_size"]
    machine_count = setup_vars["terraform_machine_count"]
    for gh in [ "database", "automationhub" ] + ([ "tower" ] * cluster_size) + ([ "podman" ] * (machine_count - 2 - cluster_size )   ):
        if not inv_host:
            continue
        h = inv_host.pop()
        groups[gh]["hosts"].append(h)
        meta["_meta"]["hostvars"][h] = { "public_ip": inv_host_public.pop() if inv_host_public else None } 

    for pw in setup_vars["_tower_installer"]['passwords_to_default']:
        all["all"]["vars"][pw] = setup_vars["_tower_installer"]['default_password']

    for db in setup_vars["_tower_installer"]['db_hosts_to_default']:
        all["all"]["vars"][db] = groups["database"]["hosts"][0]

    for p in setup_vars["_tower_installer"]["ports_to_default"]:
        all["all"]["vars"][p] = setup_vars["_tower_installer"]["default_port"]

    conn_defaults = {
        "ansible_user": "ansible",
        "ansible_ssh_common_args": "-o StrictHostKeyChecking=no",
        "ansible_become" : "true",
        "ansible_private_key_file": os.getenv('HOME', '~')+"/.ssh/id_rsa", 
    }

    if groups["tower"]["hosts"]:
        tower_host1 = groups["tower"]["hosts"][0]
        ah_host1 = groups["automationhub"]["hosts"][0]
        lab_defaults = {
            "tower_url" : "https://{0}".format(tower_host1),
            "tower_url_public" : "https://{0}".format(meta["_meta"]["hostvars"][tower_host1]["public_ip"]),
            "ah_url" : "https://{0}".format(ah_host1),
            "ah_url_public" : "https://{0}".format(meta["_meta"]["hostvars"][ah_host1]["public_ip"])
        }

        all["all"]["vars"].update(lab_defaults)

    all["all"]["vars"].update(conn_defaults)
    
all.update(meta)
all.update(groups)
print(json.dumps( all ))
