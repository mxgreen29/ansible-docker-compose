from pathlib import Path
import os, re, yaml, sys
dir = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
regex = re.compile('(.*\.yml$)')
def parse():
    result = []
    for root, dirs, files in os.walk(dir):
        for yml in files:
            if regex.match(yml):
                result.append(yml)
    return result


if __name__ == '__main__':
    print(parse())
hosts_file = Path("inventory/default/hosts.yml")
if not hosts_file.is_file():
    with open(hosts_file, 'w+') as f:
        yaml.dump({"all": {"hosts": {}, "children": {"aws": {"hosts":{}}}}}, f)

group = re.sub(".*/", "", dir)
with open(hosts_file,'r') as yamlfile:
    cur_yaml = yaml.safe_load(yamlfile)
    cur_yaml['all']['children'].update({group: {"hosts": {}}})
    for i in range(len(parse())):
        cur_yaml['all']['hosts'].update({parse()[i].replace(".yml", ""): {}}) # Create default section with ALL hosts
        if group != "hetzner":
            cur_yaml['all']['children']['aws']['hosts'].update({parse()[i].replace(".yml", ""): {}}) # create section for group AWS
        cur_yaml['all']['children'][group]['hosts'].update({parse()[i].replace(".yml", ""): {}}) # create section with name of project for match ansible-vault variables
        yml = parse()[i]
        full_path = "{dir}/{yml}".format(dir=dir,yml=yml)
        if regex.match(yml):
            with open(full_path, 'r') as file:
                documents = yaml.full_load(file)
                for k, v in documents['defaults'].items():
                    if v:
                        if "server" in v:
                            cur_yaml['all']['hosts'].update({parse()[i].replace(".yml", ""): {"consul_role": "server"}})
if cur_yaml:
    with open(hosts_file,'w') as yamlfile:
        yaml.safe_dump(cur_yaml, yamlfile)