### SELinux

#### <a name='toc'>Содержание</a>
1. [Что такое SELinux?](#1)
2. [Основные понятия и термины](#2)
3. [Как работать с SELinux?](#3)
4. [Лабораторная работа](#4)
5. [Дополнительные источники](#recommended_sources)

![SElinux](https://github.com/user-attachments/assets/8ef4731d-870f-4048-845f-476e356fcf82)


#### [[⬆]](#toc) <a name='1'>Что такое SELinux?</a>

SELinux (SELinux) — это система принудительного контроля доступа (Mandatory access control, MAC — разграничение доступа субъектов к объектам), реализованная на уровне ядра. Впервые эта система появилась в четвертой версии CentOS, а в 5 и 6 версии реализация была существенно дополнена и улучшена. Эти улучшения позволили SELinux стать универсальной системой, способной эффективно решать массу актуальных задач. Стоит помнить, что классическая или избирательная система (англ. discretionary access control, DAC — управление доступом субъектов к объектам на основе списков управления доступом или матрицы доступа) прав Unix (rwx) применяется первой, и управление перейдет к SELinux только в том случае, если эта первичная проверка будет успешно пройдена.

SELinux по умолчанию, включена на Red Hat, CentOS, Fedora, Android и др. на большинство других систем ее можно установить командой `sudo apt install selinux-utils`. Использует дополнительные политики для предоставления доступа пользователям и процессам к каталогам и сетевым портам. **Основные особенности применения:** - это гибкое ограничение прав пользователей и процессов на уровне ядра.

Очень часто, администраторы находят данную систему избыточной, поэтому отключают ее. Одной из причин является не самый очевидный процесс ее настройки. Однако, SELinux может существенно увеличить уровень безопасности системы.

Проверить состояние SELinux можно командой `getenforce` или `sestatus`. Для `sestatus` возможно нужно будет установить программу `policycoreutils` командой `sudo apt install policycoreutils` Возможны следующие варианты:

* `Enforcing` — включен.
* `Permissive` — включены только предупреждения.
* `Disabled` — отключен.

**Включить SELinux**

Чтобы включить SELinux в вашей системе, убедитесь, что у вас установлены необходимые пакеты:

* `policycoreutils`
* `selinux-utils`
* `selinux-basics`

Также убедитесь, что вы активировали SELinux в своей системе.

_Чтобы настроить SELinux в Ubuntu_

1. Используйте команду `apt` для установки следующих пакетов:
```
sudo apt install policycoreutils selinux-utils selinux-basics auditd
```
2. Активируйте SELinux:
```
sudo selinux-activate
```
* Вы должны увидеть:
`SE Linux is activated. You may need to reboot now.`
3. Установите SELinux в принудительный режим:
```
sudo selinux-config-enforcing
```
4. Перезагрузите вашу систему. Перемаркировка SELinux будет запущена после перезагрузки системы. По завершении система автоматически перезагрузится ещё раз.
5. Проверьте статус SELinux:
```
sestatus
getenforce
```

**Отключить SELinux**

_Способ 1. Разово без перезагрузки. После перезагрузки системы все вернется как было._
```
setenforce 0
``` 

_Способ 2. Отключить навсегда. Чтобы SELinux не запускался после перезагрузки, открываем на редактирование следующий файл: `vi /etc/selinux/config`_
```
SELINUX=disabled
```

_Способ 3. Удалить пакеты Selinux_

```
# Для CentOS / Red Hat / Fedora
yum remove selinux*
```

```
# Для Debian / Ubuntu
apt-get remove selinux*
```

_Просмотр текущего статуса_

```
sestatus
getenforce
```

Перезагрузите вашу систему.

#### [[⬆]](#toc) <a name='2'>Основные понятия и термины</a>

**Субъект** — пользователь или процесс, то есть то, что выполняет действия в
системе  
**Объект** — то над чем выполняются действия, то есть файлы, порты, сокеты и
процессы  
**Режимы** (policy) SELinux  
* targeted – набор политик по умолчанию (вклычает MCS)
* minimum — вариант targeted, минимальный набор политик
* mls – MLS (уровни секретности)

**Механизмы мандатного доступа**

**MLS** (Multi-Level Security, многоуровневая система безопасности)  
* Модель Белла-Лападулы  
* Уровни доступа (секретности)  
* Объекты маркируются уровнями доступа  

**MCS** (Multi-Category Security, мулþтикатегорийнаā система безопасности)  
* Данные разбиты на категории  
* Объектам назначаются метки категорий  

**RBAC (Roles Based Access Control)** — управление доступом на основе ролей

**TE (Type Enforcement)** — принудительная типизация доступа


**MLS – уровни секретности**  
* Все субъекты и объекты имеют свой уровень допуска
* Субъект с определенным уровнем допуска имеет право читать и создавать (писать/обновлять) объекты с тем же уровнем допуска
* Кроме того, он имеет право читать менее секретные объекты и создавать объекты с более высоким уровнем
* Субъект никогда не сможет создавать объекты с уровнем допуска ниже, чем он сам имеет, а также прочесть объект более высокого уровня допуска
* Краткая формулировка: «write up, read down» и «no write down, no read up»
* Применяется при повышенных требованиях к безопасности (гос. и военные)
* Работает в режиме mls

**MCS – категории объектов**  
* Все субъекты и объекты имеют свои категории  
* Субъект получает доступ к своим разрешенным категориям  
* Метки категорий расставляются по объектам и субъектам  
* Работает в режиме targeted  

**RBAC — управление по ролям**  
* Контроль доступа к объектам файловой системы через роли, созданные на основании требований бизнеса или других критериев  
* Роли могут быть разных типов и уровней доступа к объектам  
* Пользователи по умолчанию:
○ system_u - системные проøессы
○ root - системный администратор
○ user_u - все логины пользователей

**RBAC — управление по ролям**  

![image](https://github.com/user-attachments/assets/603a1833-a594-4b48-a3c1-0b18e4f3c79a)


**RBAC — роли по умолчанию**  
* **user_r** — роль обычного пользователя, разрешает запуск пользовательских приложений и других непривилегированных доменов  
* **staff_r** — похожа на роль user_r, но позволяет получать больше системной информации, чем обычный пользователь, эта роль выдается пользователям, котором следует разрешить переключение на другие роли  
* **sysadm_r** — административная роль, разрешает использование большинства доменов, включая привилегированные  
* **system_r** — системная роль, не предназначенная для непосредственного переключения  

**SELinux — термины MAC** 
 
**TE** (Type Enforcement, принудительная типизация доступа)
**Контекст безопасности** (context) — метка, выглядит как строка переменной длины и хранится в расширенных атрибутах файловой системы. Объединяет в себе роли, типы и домены
**Домен** (domain) - список действий, которые может выполнять процесс по
отношению к различным объектам
**Тип** (type) - атрибут объекта, который определяет, кто может получить к нему доступ
**Роль** - атрибут, который определяет, в какие домены может входить пользователь, то есть какие домены пользователь имеет право запускать

**TE – Type Enforcement**  

![image](https://github.com/user-attachments/assets/2482aa48-0e38-4660-9ace-44f2ec0db282)  

![image](https://github.com/user-attachments/assets/3fa286b3-3cc3-4e09-a488-8fa5d51da1c5)  

* **Роль** — набор правил
* **Домен** — то, что разрешено процессу (субъекту)
* **Тип** — набор правил для файла (объекта)
* **Суть работы** — сопоставление домена с типом через роль


**Совместная работа DAC и MAC (LSM)**

![image](https://github.com/user-attachments/assets/bddff82a-b2b4-4ed2-897c-8c2c67d922ad)  


#### [[⬆]](#toc) <a name='3'>Как работать с SELinux?</a>

**Основные инструменты для работы с SELinux**

_Пакет setools-console_
    * sesearch
    * seinfo
    * findcon
    * getsebool
    * setsebool
    * semanage

_Пакет policycoreutils-python_
    * audit2allow
    * audit2why

_Пакет policycoreutils-newrole_
    * newrole

 _Пакет selinux-policy-mls_
    * selinux-policy-mls

**Примеры**
```
id -Z | ps -Z | ls -Z

# смотрим юзеров
semanege user -l

# смотрим какие домены входят в роль
seinfo ruser_r -x | less

# смотрим что имеет отношение к порту 80
seinfo --portcon=80 

# смотрим что разрешено для ssh и http
semanage port -l | grep ssh
semanage port -l | grep http_port_t

# разрешаем подключение по нестандартному порту 5022
semanage port -a -t ssh_port_t -p tcp 5022

# тоже разрешает порты
setsebool -P nis_enable 1
getsebool -a | less

# удалить порт из разрешенных
semanage port -d -t ssh_port_t -p tcp 5022

# смотрим логи SELinux в отформатированном формате
audit2why < /var/log/audit/audit.log
```



#### [[⬆]](#toc) <a name='4'>Лабораторная работа</a>

Смотрим статус SElinux

![image](https://github.com/user-attachments/assets/7f198085-1d7a-4200-8d89-faebb28bd2a0)

Смотрим статус Nginx

![image](https://github.com/user-attachments/assets/d818a6e0-dfcf-422d-9ae8-73192483d3d7)

![image](https://github.com/user-attachments/assets/5a7525dd-563f-4367-bf32-2a470a7e9ffb)

Меняем порт Nginx на нестандартный

![image](https://github.com/user-attachments/assets/b9054e4b-949e-4247-929e-59e2c46c6279)

Получаем ошибку после рестарта сервера

![image](https://github.com/user-attachments/assets/a966092a-dcb6-4164-9be8-264d094eedf8)

Видно, что нужного нам порта не в разрешенных для http

![image](https://github.com/user-attachments/assets/0ddaab90-5393-4a74-9816-b6c402366ff3)

Из лога видно, что SElinux ругается на порт 8081

![image](https://github.com/user-attachments/assets/3dda85da-a915-4743-a560-3d1c2362aadf)

Добавляем порт в разрешенные

![image](https://github.com/user-attachments/assets/5dc42f50-5142-4428-b58c-bbad4bf64388)

Смотрим стутус и делаем рестарт

![image](https://github.com/user-attachments/assets/ce4b8768-95ec-4688-a069-16055b8e1545)

После рестарта еще раз проверяем статус

![image](https://github.com/user-attachments/assets/e75ea0ae-751c-47c0-ae91-94d9ed1b5a6e)

![image](https://github.com/user-attachments/assets/811d7feb-9211-495f-98cf-4ae9db9d05c3)

![image](https://github.com/user-attachments/assets/9c596f47-417d-4f28-85e0-a48c54888508)


## Обеспечение работы приложения при включенном SELinux

![image](https://github.com/user-attachments/assets/c9ce064e-4c18-4fbf-9f0d-0c6f00021588)

Заходим на клиента

![image](https://github.com/user-attachments/assets/f2c3454c-017f-435c-8bb6-a5f180950a15)

При попытке обновления зоны получаем ошибку

![image](https://github.com/user-attachments/assets/3ee08632-a573-47dd-8e4e-b6cdf2666988)

Смотрим логи утилитой audit2why и видно что на клиенте ошибок нет

![image](https://github.com/user-attachments/assets/a0974cfe-1c7a-4c6c-b05e-3dbc413f7ede)

Идем на сервер, смотрим логи и получаем ошбку

![image](https://github.com/user-attachments/assets/7fb3f81c-5a0e-42db-94c7-325c12ab8078)

Изменим тип контекста безопасности для каталога /etc/named:
```
chcon -R -t named_zone_t /etc/named
```
Видно, что команда применилась и ошибки нет

![image](https://github.com/user-attachments/assets/c004842e-19cd-4691-87ff-0b4cd015c714)

Проверяем

![image](https://github.com/user-attachments/assets/3432dc1a-07ee-4b83-8c17-d15881c13431)
![image](https://github.com/user-attachments/assets/b2b394df-343d-49e1-87a4-16d94e0222c2)




#### [[⬆]](#toc) <a name='recommended_sources'>Дополнительные источники</a>

1. [SELinux - Материал из Википедии](https://ru.wikipedia.org/wiki/SELinux)
2. [Мандатное управление доступом](https://ru.wikipedia.org/wiki/%D0%9C%D0%B0%D0%BD%D0%B4%D0%B0%D1%82%D0%BD%D0%BE%D0%B5_%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5_%D0%B4%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%BE%D0%BC)
3. [Избирательное управление доступом](https://ru.wikipedia.org/wiki/%D0%98%D0%B7%D0%B1%D0%B8%D1%80%D0%B0%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%BE%D0%B5_%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5_%D0%B4%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%BE%D0%BC)
4. [SELinux – описание и особенности работы с системой. Часть 1](https://habr.com/ru/companies/kingservers/articles/209644/)
5. [SELinux — описание и особенности работы с системой. Часть 2](https://habr.com/ru/companies/kingservers/articles/209970/)
6. [SELinux - публикации](https://habr.com/ru/search/?q=SELinux&target_type=posts&order=relevance)
7. [Руководство для начинающих по SELinux](https://habr.com/ru/companies/otus/articles/460387/)
8. [Введение в SELinux под Ubuntu 20.04](https://ruvds.com/ru/helpcenter/vvedenie-v-selinux-pod-ubuntu-20-04/)
