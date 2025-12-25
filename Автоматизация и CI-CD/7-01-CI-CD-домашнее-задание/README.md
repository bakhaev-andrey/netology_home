# Домашнее задание к занятию «Ansible.Часть 2» - Бахаев Андрей


### Задание 1

**Выполните действия, приложите файлы с плейбуками и вывод выполнения.**

Напишите три плейбука. При написании рекомендуем использовать текстовый редактор с подсветкой синтаксиса YAML.

Плейбуки должны: 

1. Скачать какой-либо архив, создать папку для распаковки и распаковать скаченный архив. Например, можете использовать [официальный сайт](https://kafka.apache.org/downloads) и зеркало Apache Kafka. При этом можно скачать как исходный код, так и бинарные файлы, запакованные в архив — в нашем задании не принципиально.
2. Установить пакет tuned из стандартного репозитория вашей ОС. Запустить его, как демон — конфигурационный файл systemd появится автоматически при установке. Добавить tuned в автозагрузку.
3. Изменить приветствие системы (motd) при входе на любое другое. Пожалуйста, в этом задании используйте переменную для задания приветствия. Переменную можно задавать любым удобным способом.


Файлы для выполнения «Задание №1» (в папке `Task-1`):
- [ansible.cfg](./Task-1/ansible.cfg)
- [inventory.ini](./Task-1/inventory.ini)
- [01_download_and_unarchive.yml](./Task-1/01_download_and_unarchive.yml)
- [02_tuned_install_enable.yml](./Task-1/02_tuned_install_enable.yml)
- [03_motd.yml](./Task-1/03_motd.yml)
- [README.md](./Task-1/README.md)
- [Ansible.png](./Task-1/Ansible.png)
- [Playbook_1.png](./Task-1/Playbook_1.png)
- [Playbook_2.png](./Task-1/Playbook_2.png)
- [Playbook_3_1.png](./Task-1/Playbook_3_1.png)
- [Playbook_3_2.png](./Task-1/Playbook_3_2.png)
- [Test_Connection.png](./Task-1/Test_Connection.png)



### Задание 2

**Выполните действия, приложите файлы с модифицированным плейбуком и вывод выполнения.** 

Модифицируйте плейбук из пункта 3, задания 1. В качестве приветствия он должен установить IP-адрес и hostname управляемого хоста, пожелание хорошего дня системному администратору.

Файлы для выполнения «Задание №2» (в папке `Task-2`):
- [03_motd_facts.yml](./Task-2/03_motd_facts.yml)
- [README.md](./Task-2/README.md)
- [ansible.cfg](./Task-2/ansible.cfg)
- [inventory.ini](./Task-2/inventory.ini)
- [Playbook_2_1.png](./Task-2/Playbook_2_1.png)
- [Playbook_2_2.png](./Task-2/Playbook_2_2.png)



### Задание 3

**Выполните действия, приложите архив с ролью и вывод выполнения.**

Ознакомьтесь со статьёй [«Ansible - это вам не bash»](https://habr.com/ru/post/494738/), сделайте соответствующие выводы и не используйте модули **shell** или **command** при выполнении задания.

Создайте плейбук, который будет включать в себя одну, созданную вами роль. Роль должна:

1. Установить веб-сервер Apache на управляемые хосты.
2. Сконфигурировать файл index.html c выводом характеристик каждого компьютера как веб-страницу по умолчанию для Apache. Необходимо включить CPU, RAM, величину первого HDD, IP-адрес.
Используйте [Ansible facts](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html) и [jinja2-template](https://linuxways.net/centos/how-to-use-the-jinja2-template-in-ansible/). Необходимо реализовать handler: перезапуск Apache только в случае изменения файла конфигурации Apache.
4. Открыть порт 80, если необходимо, запустить сервер и добавить его в автозагрузку.
5. Сделать проверку доступности веб-сайта (ответ 200, модуль uri).

В качестве решения:
- предоставьте плейбук, использующий роль;
- разместите архив созданной роли у себя на Google диске и приложите ссылку на роль в своём решении;
- предоставьте скриншоты выполнения плейбука;
- предоставьте скриншот браузера, отображающего сконфигурированный index.html в качестве сайта.

Файлы для выполнения «Задание №3» (в папке `Task-3`):
- [site_web.yml](./Task-3/site_web.yml)
- [inventory.ini](./Task-3/inventory.ini)
- [ansible.cfg](./Task-3/ansible.cfg)
- [README.md](./Task-3/README.md)
- [web_apache_role.tar.gz](./Task-3/web_apache_role.tar.gz)
- [Playbook_3_1.png](./Task-3/Playbook_3_1.png)
- [Playbook_3_2.png](./Task-3/Playbook_3_2.png)
- [roles/web_apache/tasks/main.yml](./Task-3/roles/web_apache/tasks/main.yml)
- [roles/web_apache/templates/index.html.j2](./Task-3/roles/web_apache/templates/index.html.j2)
- [roles/web_apache/handlers/main.yml](./Task-3/roles/web_apache/handlers/main.yml)
- [roles/web_apache/defaults/main.yml](./Task-3/roles/web_apache/defaults/main.yml)
- [roles/web_apache/meta/main.yml](./Task-3/roles/web_apache/meta/main.yml)
