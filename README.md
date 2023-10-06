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
## Common things
1. Как настроена архитектура ansible.
   В данном проекте Ansible создано 2 роли. Первая - base_role(ansible/roles/base_role), которая отвечает за базовую настройку сервера - репозитории, установки пакетов,
   создание пользователей, установка сертификатов и т.д. Вторая роль это DEV роль - dev_app(ansible/roles/dev_app)
2. Как создаются пользователи.
   Пользователи, которых необходимо создать, указываются в файле ansible/roles/base_role/defaults/users.yml. Пользователи создаются с помощью
   ansible task в базовой роли.
   Пример такого пользователя:
```
    itbot:
    groups: [ 'admin', 'adm', 'users' ]
    key: 'sshkey~'
```

3. Создание приложений с помощью docker-compose.
   Для сервера необходимо создать одноименный файл с расширением yml в ЛОКАЛЬНОМ запуске inventory/local/group_vars/all/compose.yml
   или в remote запуске в директории например server если вы собираетесь запускать CI/CD.
   Например:
   example.com.yml. В данном файле как минимум должны быть указаны строки:
    ```
    defaults:
      nginx:
    ```
   Чтобы добавить докер приложение на сервер, необходимо указать блок, начинающийся с [apps]. После чего указать нужные приложения.
   Так как для web-приложений требуется nginx, мы добавляем их в [defaults].

   У каждого приложения есть свои стандартные параметры, которые нужны для docker-compose. Например:
   **image** - указывается версия docker'а приложения; **ports** - порт, на котором работает приложение в докере; **environment** - указание переменных, направляемых в докер; а также **command** и т.п; **volumes** - чтобы прокинуть директории с сервера в докер; **entrypoint** - добавить кастомный entrypoint; Также для приложение можно и нужно указать docker memory limit. Например

```
  deploy:
    resources:
      limits:
        memory: 1G
```

Но для каждого приложения можно, а иногда нужно, указать инфраструктурный параметр, называющийся **proxy_port** - этот порт необходим в случае прокси порта для nginx. Пример porxy_port: 3000 когда например веб приложение в контейнере запущено на 3000 порте. Эта настройка используется для создания nginx конфигов(ansible/roles/dev_app/templates/nginx).


## Features
Автоматическая генерация Ansible Inventory благодаря скрипту inventory_builder.py. Собственно берется лист из yml файлом.
Создается секция `[All]`, `[aws]`, `[<Project group>]`. Автоматическая генерация секции, например вы создаете сервера в 
AWS регионе `[us-east-1]`
позволяет сделать group_vars директорию, например us-east-1, в которую можно поместить кастомные переменные для этого региона/проекта ,
а также разделить и секреты между регионами/проектами если это требуется.

Также, вам не нужно самостоятельно задавать приватный IP-адрес в docker-compose - он подберется самостоятельно из свободных.
Также вы можете не беспокоиться о том, что вы попробуете использовать порт, который уже занят. Для этого в yml-файле 
укажите секцию ports таким образом:
```
      ports:
      - "1234"
```

## Local installation

### Before you start. Prepare
You need configure inventory/local/group_vars/all/all.yml, e.g. you need to change
```
apps_root_path: /app # by default
```
To find out the path of your directory, you can exec following command
```
pwd
```
Git cloning this project and come to project directory and you can generate docker-compose locally

### Generate docker compose for mac os.
```
echo "$(whoami) ALL=(ALL) NOPASSWD: ALL"
# Now you need to add output of the last command
sudo vim /etc/sudoers.d/20_user
```
Now you can run ansible playbook
```
cd ${this_project_directory}/ansible
ansible-playbook -i inventory/local/hosts.ini --connection=local -v dev-role.yaml -e ansible_user=$(whoami)
```

