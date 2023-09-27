import os, re, yaml, sys

dir = sys.argv[1] if len(sys.argv) > 1 else os.curdir
regex = re.compile('(.*\.yml$)')
def parse():
    result = {}
    for root, dirs, files in os.walk(dir):
      for yml in files:
        full_path = "{dir}/{yml}".format(dir=dir,yml=yml)
        if regex.match(yml):
            with open(full_path, 'r') as file:
                documents = yaml.full_load(file)
                for k, v in documents['apps'].items():
                    if yml in result:
                        result[yml].append(k)
                    else:
                        result[yml] = [k]

    return result

if __name__ == '__main__':
    print(parse())