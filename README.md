# Дисклеймер
Простите за столь скомканный README, так как пишу его в сжатые сроки и я когда-нибудь к нему вернусь и опишу подробнее.
Сейчас же для полноценного запуска инфраструктуры с помощью моего проекта, нужно более глубокое погружение в код после прочтения README.
Также обращаю ваше внимание, что README описано по возможности на простом языке о том, как пользоваться репозиторием, который
уже настроен. Для настройки и использования вам необходимо понимать основы Ansible.

# Ansible


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
Пример такого YML-файла вы можете увидеть в директории [server](https://github.com/mxgreen29/ansible-docker-compose/blob/96a16804ac062e7f1b2421668c039b89b88ca884/server) или же в [compose.yml](https://github.com/mxgreen29/ansible-docker-compose/blob/96a16804ac062e7f1b2421668c039b89b88ca884/ansible/inventory/local/group_vars/all/compose.yml) для local installation.

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
   Для сервера необходимо создать одноименный файл с расширением yml в ЛОКАЛЬНОМ запуске [compose.yml](https://github.com/mxgreen29/ansible-docker-compose/blob/96a16804ac062e7f1b2421668c039b89b88ca884/ansible/inventory/local/group_vars/all/compose.yml)
   или в remote запуске в директории например [server](https://github.com/mxgreen29/ansible-docker-compose/blob/96a16804ac062e7f1b2421668c039b89b88ca884/server) если вы собираетесь запускать CI/CD.
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
Например, если ваш докер запускает веб-приложение на 80 порту, вам необходимо указать
`proxy_port: 80` тогда nginx будет знать о том, какой upstream и proxy_pass создать в [template nginx site](https://github.com/mxgreen29/ansible-docker-compose/blob/96a16804ac062e7f1b2421668c039b89b88ca884/ansible/roles/dev_app/templates/nginx/sites/site.conf.conf.j2)

## Ansible vault
```
ansible-vault create secrets.yml
New Vault password: testpassword
Confirm New Vault password: testpassword
```

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

## For Remote installation
Для запуска тебе потребуется создать или воспользоваться уже имеющейся директории server. Там тебе предстоит создать или 
изменить YMl файл, который создаст docker-compose. 
Обрати внимание на то, что для запуска Ansible playbook, тебе необходимо создать inventory. 
Для этого в моем проекте есть inventory_builder.py. Подробнее описанно в ansible/inventory/README.md.

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

### Problems with running on Mac OS
```
echo "$(whoami) ALL=(ALL) NOPASSWD: ALL"
# Now you need to add output of the last command
sudo vim /etc/sudoers.d/20_user
```
Now you can run ansible playbook

### Running Ansible Playbook on local machine
```
cd ${this_project_directory}/ansible
```
Далее вы можете запустить Base Role, если на вашем сервере/виртуальной машине ничего не установленно. Не работает для MacOS
```
   ansible-playbook -i inventory/local/hosts.ini --connection=local -v main.yml -e ansible_user=$(whoami) --vault-password-file password.txt
```
Следующей командой вы можете запустить Dev role с созданием автоматического docker-compose файла.
```
ansible-playbook -i inventory/local/hosts.ini --connection=local -v dev-role.yaml -e ansible_user=$(whoami) --vault-password-file password.txt
```

### Advanced level and Gitlab config
В моем проекте есть так example.gitlab-ci.yml в которым описаны ci/cd jobs для запуска ansible.
Также оттуда вы можете подчеркнуть что-то важное для запуска, что я забыл указать в этом README.
