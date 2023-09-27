import yaml
from pathlib import Path


def parse():
    result = {}
    compose = Path("docker-compose.yml")
    if compose.exists():
        with open(compose, 'r') as file:
            documents = yaml.full_load(file)
            for k, v in documents['services'].items():
                try:
                    result[k] = v['ports']
                except KeyError:
                    pass
    return result


if __name__ == '__main__':
    print(parse())