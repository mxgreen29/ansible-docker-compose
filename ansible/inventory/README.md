# Ansible Inventory

This is the place where all server-related environment variables are stored.

## Common things

Существует две директории:
- **local** - для локального запуска Ansible;
- **default** - для remote запуска.


## Remote usage
Запуск скрипта по сборке inventory:
```
$ python3 inventory_builder.py ../server 
['example.domain.com.yml']
```
Его примерный вид следующий:

---

```yml
all:
  children:
    aws:
      hosts:
        example.domain.com: {}
    server:
      hosts:
        example.domain.com: {}
  hosts:
    example.domain.com: {}
```

> ***Наличие пустых фигурных скобок обусловлено особенностями Python***

---

4. Далее на основании файла **hosts.yml** происходит деплой докера и, если это необходимо, конфигурация сервера.

## Manage env variables

Добавление переменных среды происходит по следующему алгоритму:

1. В директории "*ansible/inventory/default/group_vars*" создается папка согласно доменному имени сайта проекта, если её ещё нет;
   > Например: *nexusmentis*
2. Внутри создается файл **main.yml**;
3. Переменные указываются по следующему типу:

   **Например**:

   ---

   ```yml
    slack_notification: true
    ssl: true
    aws_config: true
    ansible_user: ec2-user
    mongo_backup: false
    s3_backup_path: ""
   ```
   **Принцип**:

   > Имя_переменной: значение
   ---
