# SELinux commands

# Установка инструментов для SELinux
yum install -y setroubleshoot-server selinux-policy-mls setools-console policycoreutils-newrole
dnf -y install setroubleshoot-server
yum install setools-console
# policycoreutils-python-utils вместо policycoreutils-python
yum install -y nginx mariadb-server

# Смотрим текущие настройки
sestatus

# Отключаем временно
setenforce 0

# Включаем временно (если в конфиге не disabled)
setenforce 1

# Политики
cd /etc/selinux/targeted/contexts/files/

semanage login -l

# Пример с passwd
sesearch -s passwd_t -A | grep shadow
sesearch -A -s shadow_t
sesearch -s passwd_t -t passwd_exec_t -c file -p execute -Ad

# Разрешающие правила для типа httpd_t
sesearch -A -s httpd_t | grep 'allow httpd_t'
# Ищем правила преобразования по типам
sesearch -s httpd_t -t httpd_exec_t -c file -p execute -Ad

# Режим работы SELinux
nano /etc/selinux/config

# Просмотр событий 
tail -n 100 /var/log/audit/audit.log 

# Ставим нестандартный порт для SSHD
nano /etc/ssh/sshd_config

# Просмотр сообщений по setroubleshoot
journalctl -t setroubleshoot --since=14:20
journalctl _SELINUX_CONTEXT=system_u:system_r:policykit_t:s0

# Permissive домен
semanage permissive -a httpd_t
# Отключить
semanage permissive -d httpd_t

# Анализ событий в логе
audit2why < /var/log/audit/audit.log

# Добавляем нестандартный порт для SSHD
semanage port -a -t ssh_port_t -p tcp 10022

# Удаляем порты
semanage port -d -t ssh_port_t -p tcp 6022

# Проверяем
semanage port -l | grep ssh

# Тестируем проблему на mysql
ls -Z /var/lib/mysql

# Создаём проблему (временно)
chcon -v -R -t samba_share_t /var/lib/mysql

# Анализ событий в логе
audit2why < /var/log/audit/audit.log

# Восстанавливаем контекст
restorecon -v -R /var/lib/mysql

# Сохраняем контекст навсегда в политике
mkdir /root/test
ls -Z /root/test
chcon -R -t samba_share_t /root/test
# Добавляем
semanage fcontext -a -t samba_share_t "/root/test(/.*)?"
# Удаляем
semanage fcontext -d "/root/test(/.*)?"
# Применяем контексты из конфигов
restorecon -v -R /root/test
ls -Z /root/test

# Меняем порт для Nginx

# Поиск решений проблем
sealert -a /var/log/audit/audit.log
# Разрешение через создание модуля
ausearch -c 'nginx' --raw | audit2allow -M my-nginx
semodule -i my-nginx.pp
semodule -l | grep nginx
seinfo --portcon=80

# Удяляем
semodule -r my-nginx

# Формирование модуля из ошибок в логе
audit2allow -M httpd_add --debug < /var/log/audit/audit.log

# Параметризованные политики
getsebool -a | grep samba
setsebool -P samba_share_fusefs on
semanage port -a -t http_port_t -p tcp 5080
