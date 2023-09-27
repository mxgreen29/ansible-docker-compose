# Ansible

## Ansible vault
```
ansible-vault create secrets.yml
New Vault password: testpassword
Confirm New Vault password: testpassword
```

## I'm sorry that the README is in Russian now, but in the future this will be changed and another part of the README will be added.

## Как это работает?
Вы создаете или используете директорию с именем проекта. В эту директорию добавляете yml файл, который должен быть назван
также как публичный домен сервера, по которому, например, вы делаете ssh. Например:
Обычно вы подключаетесь к серверу так:
` ssh domain.com`
Тогда смело создавайте файл с именем `domain.com.yml`
Этот файл представляет собой укороченную версию docker-compose. Например, вы можете создать docker-compose с любым docker'ом по этому примеру:
```
apps:
  example-container-name:
  container_name: any_name
  image: any-image:any-tag
  proxy_port: 2901 # private container port for nginx proxy config
  volumes:
    - "/custom/dir:/any/dir"
  ports:
    - "5000:5000"
  logging: no # Enable docker logging
  entrypoint: |-
    - sh
    - -euc
    - |
      mkdir -p example
```
*Примечание*: В примеры указаны все возможные функции, вам же может быть достаточно двух image и proxy_port если потребуется.

А также использовать уже подготовленные конфигурации инфраструктурных приложений, например:
```
defaults:
  nginx:
  mongo:
    limit: # Обычно докер лимит RAM для mongo - 2GB, но вы можете переопределить этот лимит здесь, как это сделанно для example.domain.com
  promtail:
  rabbitmq:
  prometheus:
```
