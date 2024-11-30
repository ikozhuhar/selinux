Методическое пособие по выполнению домашнего задания по курсу «Администратор Linux. Professional»

**Стенд с Vagrant c SELinux**

**Цель домашнего задания**

Диагностировать проблемы и модифицировать политики SELinux для корректной работы приложений, если это требуется.

**Описание домашнего задания**

1\. Запустить nginx на нестандартном порту 3-мя разными способами:

* переключатели setsebool;  
* добавление нестандартного порта в имеющийся тип;  
* формирование и установка модуля SELinux.

К сдаче:

* README с описанием каждого решения (скриншоты и демонстрация приветствуются). 

2\. Обеспечить работоспособность приложения при включенном selinux.

* развернуть приложенный стенд [https://github.com/mbfx/otus-linux-adm/tree/master/selinux\_dns\_problems](https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems);   
* выяснить причину неработоспособности механизма обновления зоны (см. README);  
* предложить решение (или решения) для данной проблемы;  
* выбрать одно из решений для реализации, предварительно обосновав выбор;  
* реализовать выбранное решение и продемонстрировать его работоспособность

**Инструкция по выполнению домашнего задания**

Требуется предварительно установленный и работоспособный Hashicorp Vagrant ([https://www.vagrantup.com/downloads](https://www.vagrantup.com/downloads)) и Oracle VirtualBox ([https://www.virtualbox.org/wiki/Linux\_Downloads](https://www.virtualbox.org/wiki/Linux_Downloads)). 

Все дальнейшие действия были проверены при использовании Vagrant 2.2.18, VirtualBox v6.1.26 r145957 и образа CentOS 7 2004.01 из Vagrant cloud. Серьёзные отступления от этой конфигурации могут потребовать адаптации с вашей стороны. 

0. **Создаём виртуальную машину**

Создаём каталог, в котором будут храниться настройки виртуальной машины. В каталоге создаём файл с именем Vagrantfile, добавляем в него следующее содержимое: 

\# \-\*- mode: ruby \-\*-  
\# vim: set ft=ruby :

MACHINES **\=** **{**  
  :selinux **\=\>** **{**  
        :box\_name **\=\>** "centos/7"**,**  
        :box\_version **\=\>** "2004.01"**,**  
        \#:provision \=\> "test.sh",         
  **},**  
**}**

Vagrant**.**configure**(**"2"**)** **do** **|**config**|**

  MACHINES**.**each **do** **|**boxname**,** boxconfig**|**

      config**.**vm**.**define boxname **do** **|**box**|**

        box**.**vm**.**box **\=** boxconfig**\[**:box\_name**\]**  
        box**.**vm**.**box\_version **\=** boxconfig**\[**:box\_version**\]**

        box**.**vm**.**host\_name **\=** "selinux"  
        box**.**vm**.**network "forwarded\_port"**,** guest: 4881**,** host: 4881

        box**.**vm**.**provider :virtualbox **do** **|**vb**|**  
              vb**.**customize **\[**"modifyvm"**,** :id**,** "--memory"**,** "1024"**\]**  
              needsController **\=** **false**  
        **end**

        box**.**vm**.**provision "shell"**,** inline: **\<\<-**SHELL  
          \#install epel-release  
          yum install **\-**y epel**\-**release  
          \#install nginx  
          yum install **\-**y nginx  
          \#change nginx port  
          sed **\-**ie 's/:80/:4881/g' **/**etc**/**nginx**/**nginx**.**conf  
          sed **\-**i 's/listen       80;/listen       4881;/' **/**etc**/**nginx**/**nginx**.**conf  
          \#disable SELinux  
          \#setenforce 0  
          \#start nginx  
          systemctl start nginx  
          systemctl status nginx  
          \#check nginx port  
          ss **\-**tlpn **|** grep 4881  
        SHELL  
    **end**  
  **end**  
**end**

Результатом выполнения команды *vagrant up* станет созданная виртуальная машина с установленным nginx, который работает на порту TCP 4881\. Порт TCP 4881 уже проброшен до хоста. SELinux включен.

Во время развёртывания стенда попытка запустить nginx завершится с ошибкой:

selinux**:** ● nginx.service **\-** The nginx HTTP and reverse proxy server  
    selinux**:**    Loaded**:** loaded **(/**usr**/**lib**/**systemd**/**system**/**nginx.service**;** disabled**;** vendor preset**:** disabled**)**  
    **selinux:    Active: failed (Result: exit-code) since Sun 2021\-11\-07 02:19:25 UTC; 10ms ago**  
    selinux**:**   Process**:** 2811 ExecStartPre**\=/**usr**/**sbin**/**nginx \-t **(**code**\=**exited**,** status**\=**1**/**FAILURE**)**  
    selinux**:**   Process**:** 2810 ExecStartPre**\=/**usr**/**bin**/**rm \-f **/**run**/**nginx.pid **(**code**\=**exited**,** status**\=**0**/**SUCCESS**)**  
    selinux**:**  
    selinux**:** Nov 07 02**:**19**:**25 selinux systemd**\[**1**\]:** Starting The nginx HTTP and reverse proxy server...  
    selinux**:** Nov 07 02**:**19**:**25 selinux nginx**\[**2811**\]:** nginx**:** the configuration file **/**etc**/**nginx**/**nginx.conf syntax is ok  
    **selinux: Nov 07 02:19:25 selinux nginx\[2811\]: nginx: \[emerg\] bind() to 0.0.0.0:4881 failed (13: Permission denied)**  
    selinux**:** Nov 07 02**:**19**:**25 selinux nginx**\[**2811**\]:** nginx**:** configuration file **/**etc**/**nginx**/**nginx.conf test failed  
    selinux**:** Nov 07 02**:**19**:**25 selinux systemd**\[**1**\]:** nginx.service**:** control process exited**,** code**\=**exited status**\=**1  
    selinux**:** Nov 07 02**:**19**:**25 selinux systemd**\[**1**\]:** Failed to start The nginx HTTP and reverse proxy server.  
    selinux**:** Nov 07 02**:**19**:**25 selinux systemd**\[**1**\]:** Unit nginx.service entered failed state.  
    selinux**:** Nov 07 02**:**19**:**25 selinux systemd**\[**1**\]:** nginx.service failed.  
 

Данная ошибка появляется из\-за того, что SELinux блокирует работу nginx на нестандартном порту.

Заходим на сервер: *vagrant ssh*

Дальнейшие действия выполняются от пользователя root. Переходим в root пользователя: *sudo \-i*

1. **Запуск nginx на нестандартном порту 3-мя разными способами** 

Для начала проверим, что в ОС отключен файервол: *systemctl status firewalld*  
**\[**root**@**selinux **\~\]**\# systemctl status firewalld  
● firewalld.service **\-** firewalld **\-** dynamic firewall daemon  
   Loaded**:** loaded **(/**usr**/**lib**/**systemd**/**system**/**firewalld.service**;** disabled**;** vendor preset**:** enabled**)**  
   Active**:** inactive **(**dead**)**  
     Docs**:** man**:**firewalld**(**1**)**  
**\[**root**@**selinux **\~\]**\#

Также можно проверить, что конфигурация nginx настроена без ошибок: *nginx \-t*

**\[**root**@**selinux **\~\]**\# nginx \-t  
nginx**:** the configuration file **/**etc**/**nginx**/**nginx.conf syntax is ok  
nginx**:** configuration file **/**etc**/**nginx**/**nginx.conf test is successful  
**\[**root**@**selinux **\~\]**\#

Далее проверим режим работы SELinux: getenforce 

**\[**root**@**selinux **\~\]**\# getenforce  
 Enforcing  
**\[**root**@**selinux **\~\]**\#

Должен отображаться режим Enforcing. Данный режим означает, что SELinux будет блокировать запрещенную активность.

**Разрешим в SELinux работу nginx на порту TCP 4881 c помощью переключателей setsebool**

Находим в логах (/var/log/audit/audit.log) информацию о блокировании порта

**d**

Копируем время, в которое был записан этот лог, и, с помощью утилиты audit2why смотрим 	 *grep 1636489992.273:967 /var/log/audit/audit.log | audit2why*

**\[**root**@**selinux **\~\]**\# grep 1636489992**.**273**:**967 **/**var**/**log**/**audit**/**audit.log **|** audit2why  
type**\=**AVC msg**\=**audit**(**1636489992**.**273**:**967**):** avc**:**  denied  **{** name\_bind **}** **for**  pid**\=**22278 comm**\=**"nginx" src**\=**4881 scontext**\=**system\_u**:**system\_r**:**httpd\_t**:**s0 tcontext**\=**system\_u**:**object\_r**:**unreserved\_port\_t**:**s0 tclass**\=**tcp\_socket permissive**\=**0

        Was caused by**:**  
        The boolean nis\_enabled was set incorrectly.  
        Description**:**  
        Allow nis to enabled

        Allow access by executing**:**  
        \# setsebool \-P nis\_enabled 1  
**\[**root**@**selinux **\~\]**\#

Утилита audit2why покажет почему трафик блокируется. Исходя из вывода утилиты, мы видим, что нам нужно поменять параметр nis\_enabled. 

Включим параметр nis\_enabled и перезапустим nginx: *setsebool **\-**P nis\_enabled on*

**\[**root**@**selinux **\~\]**\# setsebool **\-**P nis\_enabled on  
**\[**root**@**selinux **\~\]**\# systemctl restart nginx  
**\[**root**@**selinux **\~\]**\# systemctl status nginx  
● nginx.service **\-** The nginx HTTP and reverse proxy server  
   Loaded**:** loaded **(/**usr**/**lib**/**systemd**/**system**/**nginx.service**;** disabled**;** vendor preset**:** disabled**)**  
   Active**:** active **(**running**)** since Tue 2021**\-**11**\-**09 20**:**45**:**41 UTC**;** 6s ago  
  Process**:** 22327 ExecStart**\=/**usr**/**sbin**/**nginx **(**code**\=**exited**,** status**\=**0**/**SUCCESS**)**  
  Process**:** 22324 ExecStartPre**\=/**usr**/**sbin**/**nginx \-t **(**code**\=**exited**,** status**\=**0**/**SUCCESS**)**  
  Process**:** 22323 ExecStartPre**\=/**usr**/**bin**/**rm \-f **/**run**/**nginx.pid **(**code**\=**exited**,** status**\=**0**/**SUCCESS**)**  
 Main PID**:** 22329 **(**nginx**)**  
   CGroup**:** **/**system.slice**/**nginx.service  
           ├─22329 nginx**:** master process **/**usr**/**sbin**/**nginx  
           └─22331 nginx**:** worker process

Nov 09 20**:**45**:**41 selinux systemd**\[**1**\]:** Starting The nginx HTTP and reverse proxy server...  
Nov 09 20**:**45**:**41 selinux nginx**\[**22324**\]:** nginx**:** the configuration file **/**etc**/**nginx**/**nginx.conf syntax is ok  
Nov 09 20**:**45**:**41 selinux nginx**\[**22324**\]:** nginx**:** configuration file **/**etc**/**nginx**/**nginx.conf test is successful  
Nov 09 20**:**45**:**41 selinux systemd**\[**1**\]:** Started The nginx HTTP and reverse proxy server.  
**\[**root**@**selinux **\~\]**\#  
 

Также можно проверить работу nginx из браузера. Заходим в любой браузер на хосте и переходим по адресу [http://127.0.0.1:4881](http://127.0.0.1:4881)

![][image1]

Проверить статус параметра можно с помощью команды: *getsebool \-a | grep nis\_enabled*

**\[**root**@**selinux **\~\]**\# getsebool \-a **|** **grep** nis\_enabled  
nis\_enabled **\--\>** on  
**\[**root**@**selinux **\~\]**\#

Вернём запрет работы nginx на порту 4881 обратно. Для этого отключим nis\_enabled: *setsebool \-P nis\_enabled off*

После отключения nis\_enabled служба nginx снова не запустится.

**Теперь разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип:**

Поиск имеющегося типа, для http трафика: *semanage port \-l | grep http*

**\[**root**@**selinux **\~\]**\# semanage port \-l **|** **grep** http  
http\_cache\_port\_t              tcp      8080**,** 8118**,** 8123**,** 10001**\-**10010  
http\_cache\_port\_t              udp      3130  
http\_port\_t                    tcp      80**,** 81**,** 443**,** 488**,** 8008**,** 8009**,** 8443**,** 9000  
pegasus\_http\_port\_t            tcp      5988  
pegasus\_https\_port\_t           tcp      5989  
**\[**root**@**selinux **\~\]**\#  
*s*

Добавим порт в тип http\_port\_t: *emanage port \-a \-t http\_port\_t \-p tcp 4881*

**\[**root**@**selinux **\~\]**\# semanage port \-a \-t http\_port\_t \-p tcp 4881  
**\[**root**@**selinux **\~\]**\# semanage port \-l **|** **grep**  http\_port\_t  
**http\_port\_t                    tcp      4881,** 80**,** 81**,** 443**,** 488**,** 8008**,** 8009**,** 8443**,** 9000  
pegasus\_http\_port\_t            tcp      5988  
**\[**root**@**selinux **\~\]**\#

Теперь перезапустим службу nginx и проверим её работу: *systemctl restart nginx*

**\[**root**@**selinux **\~\]**\# systemctl restart nginx  
**\[**root**@**selinux **\~\]**\# systemctl status nginx  
● nginx.service **\-** The nginx HTTP and reverse proxy server  
   Loaded**:** loaded **(/**usr**/**lib**/**systemd**/**system**/**nginx.service**;** disabled**;** vendor preset**:** disabled**)**  
   **Active: active** **(running) since Sun 2021\-11\-07 02:52:59 UTC; 5s ago**  
  Process**:** 2981 ExecStart**\=/**usr**/**sbin**/**nginx **(**code**\=**exited**,** status**\=**0**/**SUCCESS**)**  
  Process**:** 2979 ExecStartPre**\=/**usr**/**sbin**/**nginx \-t **(**code**\=**exited**,** status**\=**0**/**SUCCESS**)**  
  Process**:** 2978 ExecStartPre**\=/**usr**/**bin**/**rm \-f **/**run**/**nginx.pid **(**code**\=**exited**,** status**\=**0**/**SUCCESS**)**  
 Main PID**:** 2983 **(**nginx**)**  
   CGroup**:** **/**system.slice**/**nginx.service  
           ├─2983 nginx**:** master process **/**usr**/**sbin**/**nginx  
           └─2985 nginx**:** worker process

Nov 07 02**:**52**:**59 selinux systemd**\[**1**\]:** Starting The nginx HTTP and reverse proxy server...  
Nov 07 02**:**52**:**59 selinux nginx**\[**2979**\]:** nginx**:** the configuration file **/**etc**/**nginx**/**nginx.conf syntax is ok  
Nov 07 02**:**52**:**59 selinux nginx**\[**2979**\]:** nginx**:** configuration file **/**etc**/**nginx**/**nginx.conf test is successful  
Nov 07 02**:**52**:**59 selinux systemd**\[**1**\]:** Started The nginx HTTP and reverse proxy server.  
**\[**root**@**selinux **\~\]**\#

Также можно проверить работу nginx из браузера. Заходим в любой браузер на хосте и переходим по адресу [http://127.0.0.1:4881](http://127.0.0.1:4881)

![][image1]

Удалить нестандартный порт из имеющегося типа можно с помощью команды: *semanage port \-d \-t http\_port\_t \-p tcp 4881*

**\[**root**@**selinux **\~\]**\# semanage port \-d \-t http\_port\_t \-p tcp 4881  
**\[**root**@**selinux **\~\]**\# semanage port \-l **|** **grep**  http\_port\_t  
http\_port\_t                    tcp      80**,** 81**,** 443**,** 488**,** 8008**,** 8009**,** 8443**,** 9000  
pegasus\_http\_port\_t            tcp      5988  
**\[**root**@**selinux **\~\]**\# systemctl restart nginx  
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl \-xe" for details.

**\[**root**@**selinux **\~\]**\# systemctl status nginx  
● nginx.service **\-** The nginx HTTP and reverse proxy server  
   Loaded**:** loaded **(/**usr**/**lib**/**systemd**/**system**/**nginx.service**;** disabled**;** vendor preset**:** disabled**)**  
   **Active: failed** **(**Result**:** exit-code**)** since Sun 2021**\-**11**\-**07 03**:**00**:**42 UTC**;** 3s ago  
**...**  
Nov 07 03**:**00**:**42 selinux nginx**\[**3008**\]:** nginx**:** the configuration file **/**etc**/**nginx**/**nginx.conf syntax is ok  
**Nov 07 03:00:42 selinux nginx\[3008\]: nginx: \[emerg\] bind() to 0.0.0.0:4881 failed (13: Permission denied)**  
**...**  
Nov 07 03**:**00**:**42 selinux systemd**\[**1**\]:** nginx.service failed.  
**\[**root**@**selinux **\~\]**\#

**Разрешим в SELinux работу nginx на порту TCP 4881 c помощью формирования и установки модуля SELinux:**

Попробуем снова запустить nginx: *systemctl start nginx*

**\[**root**@**selinux **\~\]**\# systemctl start nginx  
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl \-xe" for details.  
**\[**root**@**selinux **\~\]**\#

Nginx не запуститься, так как SELinux продолжает его блокировать. Посмотрим логи SELinux, которые относятся к nginx: 

**\[**root**@**selinux **\~\]**\# grep nginx **/**var**/**log**/**audit**/**audit.log  
**...**  
type**\=**SYSCALL msg**\=**audit**(**1637045467**.**417**:**510**):** arch**\=**c000003e syscall**\=**49 success**\=**no exit**\=-**13 a0**\=**6 a1**\=**558922a5a7b8 a2**\=**10 a3**\=**7ffe62da3900 items**\=**0 ppid**\=**1 pid**\=**2133 auid**\=**4294967295 uid**\=**0 gid**\=**0 euid**\=**0 suid**\=**0 fsuid**\=**0 egid**\=**0 sgid**\=**0 fsgid**\=**0 tty**\=(**none**)** ses**\=**4294967295 comm**\=**"nginx" exe**\=**"/usr/sbin/nginx" subj**\=**system\_u**:**system\_r**:**httpd\_t**:**s0 key**\=(**null**)**  
type**\=**SERVICE\_START msg**\=**audit**(**1637045467**.**419**:**511**):** pid**\=**1 uid**\=**0 auid**\=**4294967295 ses**\=**4294967295 subj**\=**system\_u**:**system\_r**:**init\_t**:**s0 msg**\=**'unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'  
**\[**root**@**selinux **\~\]**\#

Воспользуемся утилитой audit2allow для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу nginx на нестандартном порту: 

*grep nginx /var/log/audit/audit.log | audit2allow \-M nginx*

**\[**root**@**selinux **\~\]**\# grep nginx **/**var**/**log**/**audit**/**audit.log **|** audit2allow \-M nginx  
**\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*** IMPORTANT **\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\***  
To make this policy package active**,** execute**:**

semodule **\-**i nginx.pp

**\[**root**@**selinux **\~\]**\#

Audit2allow сформировал модуль, и сообщил нам команду, с помощью которой можно применить данный модуль: *semodule **\-**i nginx.pp*

**\[**root**@**selinux **\~\]**\# semodule **\-**i nginx.pp  
**\[**root**@**selinux **\~\]**\#

Попробуем снова запустить nginx: *systemctl start nginx*

**\[**root**@**selinux **\~\]**\# systemctl start nginx  
**\[**root**@**selinux **\~\]**\# systemctl status nginx  
● nginx.service **\-** The nginx HTTP and reverse proxy server  
   Loaded**:** loaded **(/**usr**/**lib**/**systemd**/**system**/**nginx.service**;** disabled**;** vendor preset**:** disabled**)**  
   Active**:** **active** **(**running**)** since Tue 2021**\-**11**\-**16 06**:**59**:**56 UTC**;** 16s ago  
  Process**:** 2163 ExecStart**\=/**usr**/**sbin**/**nginx **(**code**\=**exited**,** status**\=**0**/**SUCCESS**)**  
  Process**:** 2161 ExecStartPre**\=/**usr**/**sbin**/**nginx \-t **(**code**\=**exited**,** status**\=**0**/**SUCCESS**)**  
  Process**:** 2160 ExecStartPre**\=/**usr**/**bin**/**rm \-f **/**run**/**nginx.pid **(**code**\=**exited**,** status**\=**0**/**SUCCESS**)**  
 Main PID**:** 2165 **(**nginx**)**  
   CGroup**:** **/**system.slice**/**nginx.service  
           ├─2165 nginx**:** master process **/**usr**/**sbin**/**nginx  
           └─2167 nginx**:** worker process

Nov 16 06**:**59**:**55 selinux systemd**\[**1**\]:** Starting The nginx HTTP and reverse proxy server...  
Nov 16 06**:**59**:**56 selinux nginx**\[**2161**\]:** nginx**:** the configuration file **/**etc**/**nginx**/**nginx.conf syntax is ok  
Nov 16 06**:**59**:**56 selinux nginx**\[**2161**\]:** nginx**:** configuration file **/**etc**/**nginx**/**nginx.conf test is successful  
Nov 16 06**:**59**:**56 selinux systemd**\[**1**\]:** Started The nginx HTTP and reverse proxy server.  
**\[**root**@**selinux **\~\]**\#

После добавления модуля nginx запустился без ошибок. При использовании модуля изменения сохранятся после перезагрузки. 

Просмотр всех установленных модулей: *semodule \-l*

Для удаления модуля воспользуемся командой: *semodule \-r nginx*

**\[**root**@**selinux **\~\]**\# semodule \-r nginx  
libsemanage.semanage\_direct\_remove\_key**:** Removing last nginx module **(**no other nginx module exists at another priority**).**  
**\[**root**@**selinux **\~\]**\#

Результатом выполнения данного задания будет подготовленная документация. 

**Документация**  
Создайте файл README.md и снабдите его следующей информацией:  
\- название выполняемого задания;  
\- текст задания;  
\- полное описание всех команд;  
\- скриншоты (если потребуется);  
\- заметки, если считаете, что имеет смысл их зафиксировать в репозитории.

2. **Обеспечение работоспособности приложения при включенном SELinux**

Для того, чтобы развернуть стенд потребуется хост, с установленным git и ansible.

Инструкция по установке Ansible \- [https://docs.ansible.com/ansible/latest/installation\_guide/intro\_installation.html](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

Инструкция по установке Git \- https://git-scm.com/book/ru/v2/%D0%92%D0%B2%D0%B5%D0%B4%D0%B5%D0%BD%D0%B8%D0%B5-%D0%A3%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-Git

Выполним клонирование репозитория: *git clone [https://github.com/mbfx/otus-linux-adm.git](https://github.com/mbfx/otus-linux-adm.git)*

➜ **\~** с  
Cloning into 'otus-linux-adm'**...**  
remote**:** Enumerating objects**:** 542**,** done.  
remote**:** Counting objects**:** 100**%** **(**440**/**440**),** done.  
remote**:** Compressing objects**:** 100**%** **(**295**/**295**),** done.  
remote**:** Total 542 **(**delta 118**),** reused 381 **(**delta 69**),** pack-reused 102  
Receiving objects**:** 100**%** **(**542**/**542**),** 1**.**38 MiB **|** 3**.**65 MiB**/**s**,** done.  
Resolving deltas**:** 100**%** **(**133**/**133**),** done.

Перейдём в каталог со стендом: *cd otus-linux-adm/selinux\_dns\_problems*

Развернём 2 ВМ с помощью vagrant: *vagrant up*

После того, как стенд развернется, проверим ВМ с помощью команды: *vagrant status*

➜ selinux\_dns\_problems **(**master**)** ✔ vagrant status   
Current machine states**:**

ns01                      running **(**virtualbox**)**  
client                    running **(**virtualbox**)**

This environment represents multiple VMs. The VMs are all listed  
above with their current state. For more information about a specific  
VM**,** run **\`vagrant status NAME\`.**  
➜ selinux\_dns\_problems **(**master**)** ✔ 

Подключимся к клиенту: *vagrant ssh client*

Попробуем внести изменения в зону: *nsupdate \-k /etc/named.zonetransfer.key*  
**\[**vagrant**@**client **\~\]$ nsupdate** \-k **/**etc**/**named.zonetransfer.key  
**\>** server 192**.**168**.**50**.**10  
**\>** zone ddns.lab  
**\>** update add www.ddns.lab. 60 A 192**.**168**.**50**.**15  
**\>** send  
**update failed: SERVFAIL**  
**\>** quit  
**\[**vagrant**@**client **\~\]$**  
Изменения внести не получилось. Давайте посмотрим логи SELinux, чтобы понять в чём может быть проблема.

Для этого воспользуемся утилитой audit2why: 	

**\[**vagrant**@**client **\~\]$ sudo** **\-**i  
**\[**root**@**client **\~\]**\# cat **/**var**/**log**/**audit**/**audit.log **|** audit2why  
**\[**root**@**client **\~\]**\#   
Тут мы видим, что на клиенте отсутствуют ошибки. 

Не закрывая сессию на клиенте, подключимся к серверу ns01 и проверим логи SELinux:

➜ selinux\_dns\_problems **(**master**)** ✔ vagrant ssh ns01   
Last login**:** Tue Nov 16 09**:**58**:**37 2021 from 10**.**0**.**2**.**2  
**\[**vagrant**@**ns01 **\~\]$ sudo** **\-**i   
**\[**root**@**ns01 **\~\]**\#   
**\[**root**@**ns01 **\~\]**\#   
**\[**root**@**ns01 **\~\]**\# cat **/**var**/**log**/**audit**/**audit.log **|** audit2why  
type**\=**AVC msg**\=**audit**(**1637070345**.**890**:**1972**):** avc**:**  denied  **{** create **}** **for**  pid**\=**5192 comm**\=**"isc-worker0000" name**\=**"named.ddns.lab.view1.jnl" **scontext\=system\_u:system\_r:named\_t:s0 tcontext\=system\_u:object\_r:etc\_t:s0** tclass**\=**file permissive**\=**0

    Was caused by**:**  
        Missing type enforcement **(**TE**)** allow rule.

        You can use audit2allow to generate a loadable module to allow this access.

**\[**root**@**ns01 **\~\]**\#   
\`\`\`

В логах мы видим, что ошибка в контексте безопасности. Вместо типа **named\_t** используется тип **etc\_t**.

Проверим данную проблему в каталоге /etc/named:

**\`\`\`**  
**\[**root**@**ns01 **\~\]**\# ls **\-**laZ **/**etc**/**named  
drw-rwx---. root named system\_u**:**object\_r**:etc\_t:**s0       **.**  
drwxr-xr-x. root root  system\_u**:**object\_r**:etc\_t:**s0       **..**  
drw-rwx---. root named unconfined\_u**:**object\_r**:etc\_t:**s0   dynamic  
**\-**rw-rw----. root named system\_u**:**object\_r**:etc\_t:**s0       named.50.168.192.rev  
**\-**rw-rw----. root named system\_u**:**object\_r**:etc\_t:**s0       named.dns.lab  
**\-**rw-rw----. root named system\_u**:**object\_r**:etc\_t:**s0       named.dns.lab.view1  
**\-**rw-rw----. root named system\_u**:**object\_r**:etc\_t:**s0       named.newdns.lab  
**\[**root**@**ns01 **\~\]**\#   
\`\`\`

Тут мы также видим, что контекст безопасности неправильный. Проблема заключается в том, что конфигурационные файлы лежат в другом каталоге. Посмотреть в каком каталоги должны лежать, файлы, чтобы на них распространялись правильные политики SELinux можно с помощью команды: *sudo semanage fcontext \-l **|** grep named*

\[root@ns01 \~\]\# sudo semanage fcontext \-l **|** grep named  
/etc/rndc.**\***              regular file       system\_u:object\_r:named\_conf\_t:s0   
/var/named(/.**\***)**?**         all files          system\_u:object\_r:named\_zone\_t:s0   
...  
\[root@ns01 \~\]\#

Изменим тип контекста безопасности для каталога /etc/named: *sudo chcon \-R \-t named\_zone\_t /etc/named*

**\[**root**@**ns01 **\~\]**\# sudo chcon \-R \-t named\_zone\_t **/**etc**/**named  
**\[**root**@**ns01 **\~\]**\#   
\[root@ns01 \~\]\# ls \-laZ /etc/named  
drw-rwx---. root named system\_u:object\_r:**named\_zone\_t**:s0 .  
drwxr-xr-x. root root  system\_u:object\_r:etc\_t:s0       ..  
drw-rwx---. root named unconfined\_u:object\_r:**named\_zone\_t**:s0 dynamic  
\-rw-rw----. root named system\_u:object\_r:**named\_zone\_t**:s0 named.50.168.192.rev  
\-rw-rw----. root named system\_u:object\_r:**named\_zone\_t**:s0 named.dns.lab  
\-rw-rw----. root named system\_u:object\_r:**named\_zone\_t**:s0 named.dns.lab.view1  
\-rw-rw----. root named system\_u:object\_r:**named\_zone\_t**:s0 named.newdns.lab  
\[root@ns01 \~\]\# 

Попробуем снова внести изменения с клиента: 

\[vagrant@client \~\]$ nsupdate \-k /etc/named.zonetransfer.key  
**\>** server 192.168.50.10  
**\>** zone ddns.lab  
**\>** update add www.ddns.lab. 60 A 192.168.50.15  
**\>** send  
**\>** quit   
\[vagrant@client \~\]$   
\[vagrant@client \~\]$ dig www.ddns.lab

; **\<\<\>\>** DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7\_9.7 **\<\<\>\>** www.ddns.lab  
;; global options: **\+**cmd  
;; Got answer:  
;; \-**\>\>**HEADER**\<\<**\- opcode: QUERY, status: NOERROR, id: 52762  
;; flags: qr aa **rd** ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:  
; EDNS: version: 0, flags:; udp: 4096  
;; QUESTION SECTION:  
;www.ddns.lab.          **IN**  A

;; ANSWER SECTION:  
www.ddns.lab.       60  **IN**  A   192.168.50.15

;; AUTHORITY SECTION:  
ddns.lab.       3600    **IN**  NS  ns01.dns.lab.

;; ADDITIONAL SECTION:  
ns01.dns.lab.       3600    **IN**  A   192.168.50.10

;; Query time: 1 msec  
;; SERVER: 192.168.50.10\#53(192.168.50.10)  
;; WHEN: Thu Nov 18 10:34:41 UTC 2021  
;; MSG SIZE  rcvd: 96

\[vagrant@client \~\]$ 

Видим, что изменения применились. Попробуем перезагрузить хосты и ещё раз сделать запрос с помощью dig: 

\[vagrant@client \~\]$ dig @192.168.50.10 www.ddns.lab

; **\<\<\>\>** DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7\_9.7 **\<\<\>\>** @192.168.50.10 www.ddns.lab  
; (1 server found)  
;; global options: **\+**cmd  
;; Got answer:  
;; \-**\>\>**HEADER**\<\<**\- opcode: QUERY, status: NOERROR, id: 52392  
;; flags: qr aa **rd** ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:  
; EDNS: version: 0, flags:; udp: 4096  
;; QUESTION SECTION:  
;www.ddns.lab.          **IN**  A

;; ANSWER SECTION:  
www.ddns.lab.       60  **IN**  A   192.168.50.15

;; AUTHORITY SECTION:  
ddns.lab.       3600    **IN**  NS  ns01.dns.lab.

;; ADDITIONAL SECTION:  
ns01.dns.lab.       3600    **IN**  A   192.168.50.10

;; Query time: 2 msec  
;; SERVER: 192.168.50.10\#53(192.168.50.10)  
;; WHEN: Thu Nov 18 15:49:07 UTC 2021  
;; MSG SIZE  rcvd: 96

\[vagrant@client \~\]$ 

Всё правильно. После перезагрузки настройки сохранились. 

Для того, чтобы вернуть правила обратно, можно ввести команду: *restorecon \-v \-R /etc/named*

\[root@ns01 \~\]\# 23232323232323232323232323232323232323232323232323232323  
restorecon reset /etc/named context system\_u:object\_r:named\_zone\_t:s0-**\>**system\_u:object\_r:etc\_t:s0  
restorecon reset /etc/named/named.dns.lab.view1 context system\_u:object\_r:named\_zone\_t:s0-**\>**system\_u:object\_r:etc\_t:s0  
restorecon reset /etc/named/named.dns.lab context system\_u:object\_r:named\_zone\_t:s0-**\>**system\_u:object\_r:etc\_t:s0  
restorecon reset /etc/named/dynamic context unconfined\_u:object\_r:named\_zone\_t:s0-**\>**unconfined\_u:object\_r:etc\_t:s0  
restorecon reset /etc/named/dynamic/named.ddns.lab context system\_u:object\_r:named\_zone\_t:s0-**\>**system\_u:object\_r:etc\_t:s0  
restorecon reset /etc/named/dynamic/named.ddns.lab.view1 context system\_u:object\_r:named\_zone\_t:s0-**\>**system\_u:object\_r:etc\_t:s0  
restorecon reset /etc/named/dynamic/named.ddns.lab.view1.jnl context system\_u:object\_r:named\_zone\_t:s0-**\>**system\_u:object\_r:etc\_t:s0  
restorecon reset /etc/named/named.newdns.lab context system\_u:object\_r:named\_zone\_t:s0-**\>**system\_u:object\_r:etc\_t:s0  
restorecon reset /etc/named/named.50.168.192.rev context system\_u:object\_r:named\_zone\_t:s0-**\>**system\_u:object\_r:etc\_t:s0  
\[root@ns01 \~\]\#

Результатом выполнения данного задания будет:

* README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них;  
* исправленный стенд или демонстрация работоспособной системы скриншотами и описанием.

[image1]: <data:image/png;base64,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>