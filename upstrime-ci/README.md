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

Есть две CI job'ы. 
### gathering-yml
Выполняет скрипт parse_docker.py, который проверяет написание yml файла сервера и возвращает вам какие приложения будут 
созданы:
`{'example.domain.com.yml': ['example-backend', 'example-frontend'], 'domain.com.yml': ['backend', 'frontend']}`
После чего директории проектов сохраняются как Job artifacts. А также сохраняет нужные переменные для следующих job.
Например, сохраняется переменная, которая говорит, на каком именно сервере необходимо выполнить изменения исходя из
изменений в серверных yml-файлах.

### trigger-ansible
Здесь же все просто, выполняется триггер CI/CD Pipeline в проекте c Ansible и передаются необходимые переменные, созданные ранее.

### Что происходит далее??
Далее в проекте с Ansible запускается CI/CD Pipeline который запускает Ansible Playbook.

На нужном сервере происходит деплой из двух ролей Ansible. Одна устанавливает базовые вещи, такие как Docker, SSL,
пользователей в ОС.
Вторая роль, берёт серверный yml и на основе его создает docker-compose в директории /app(такая директория выбрана по умолчанию).
А также, если необходимо, то создает нужные конфиги для nginx, mongodb. 


## Ограничения
Одновременно можно запустить Ansible только с одного проекта. Нельзя провести изменения в двух разных директориях с yml файлами.