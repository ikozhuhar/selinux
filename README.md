### SELinux

#### <a name='toc'>Содержание</a>
1. [Что такое SELinux?](#1)
2. [Основные понятия и термины](#2)
3. [Как работать с SELinux?](#3)
4. [Дополнительные источники](#recommended_sources)


#### [[⬆]](#toc) <a name='1'>Что такое SELinux?</a>

SELinux (SELinux) — это система принудительного контроля доступа (Mandatory access control, MAC — разграничение доступа субъектов к объектам), реализованная на уровне ядра. Впервые эта система появилась в четвертой версии CentOS, а в 5 и 6 версии реализация была существенно дополнена и улучшена. Эти улучшения позволили SELinux стать универсальной системой, способной эффективно решать массу актуальных задач. Стоит помнить, что классическая или избирательная система (англ. discretionary access control, DAC — управление доступом субъектов к объектам на основе списков управления доступом или матрицы доступа) прав Unix (rwx) применяется первой, и управление перейдет к SELinux только в том случае, если эта первичная проверка будет успешно пройдена.

SELinux по умолчанию, включена на Red Hat, CentOS, Fedora, Android и др. на большинство других систем ее можно установить командой `sudo apt install selinux-utils`. Использует дополнительные политики для предоставления доступа пользователям и процессам к каталогам и сетевым портам. **Основные особенности применения:** - это гибкое ограничение прав пользователей и процессов на уровне ядра.

Очень часто, администраторы находят данную систему избыточной, поэтому отключают ее. Одной из причин является не самый очевидный процесс ее настройки. Однако, SELinux может существенно увеличить уровень безопасности системы.

Проверить состояние SELinux можно командой `getenforce`. Возможны следующие варианты:

* `Enforcing` — включен.
* `Permissive` — включены только предупреждения.
* `Disabled` — отключен.

**Как отключить SELinux?**

_Просмотр текущего статуса_

```
getenforce
```
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
# ля Debian / Ubuntu
apt-get remove selinux*
```

#### [[⬆]](#toc) <a name='2'>Основные понятия и термины</a>

**Субъект** — пользователь или процесс, то есть то, что выполняет действия в
системе  
**Субъект** — то над чем выполняются действия, то есть файлы, порты, сокеты и
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
ФОТО


**RBAC — роли по умолчанию**  
* user_r — роль обычного пользователя, разрешает запуск пользовательских приложений и других непривилегированных доменов  
* staff_r — похожа на роль user_r, но позволяет получать больше системной информации, чем обычный пользователь, эта роль выдается пользователям, котором следует разрешить переключение на другие роли  
* sysadm_r — административная роль, разрешает использование большинства доменов, включая привилегированные  
* system_r — системная роль, не предназначенная для непосредственного переключения  

**SELinux — термины MAC** 
 
**TE** (Type Enforcement, принудительная типизация доступа)
**Контекст безопасности** (context) — метка, выглядит как строка переменной длины и хранится в расширенных атрибутах файловой системы. Объединяет в себе роли, типы и домены
**Домен** (domain) - список действий, которые может выполнять процесс по
отношению к различным объектам
**Тип** (type) - атрибут объекта, который определяет, кто может получить к нему доступ
**Роль** - атрибут, который определяет, в какие домены может входить пользователь, то есть какие домены пользователь имеет право запускать

**TE – Type Enforcement**  
ФОТО  
ФОТО  
ФОТО  

* Роль — набор правил
* Домен — то, что разрешено процессу (субъекту)
* Тип — набор правил для файла (объекта)
* Суть работы — сопоставление домена с типом через роль
















[[⬆]](#toc) <a name='recommended_sources'>Дополнительные источники</a>

1. [SELinux - Материал из Википедии](https://ru.wikipedia.org/wiki/SELinux)
2. [Мандатное управление доступом](https://ru.wikipedia.org/wiki/%D0%9C%D0%B0%D0%BD%D0%B4%D0%B0%D1%82%D0%BD%D0%BE%D0%B5_%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5_%D0%B4%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%BE%D0%BC)
3. [Избирательное управление доступом](https://ru.wikipedia.org/wiki/%D0%98%D0%B7%D0%B1%D0%B8%D1%80%D0%B0%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%BE%D0%B5_%D1%83%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5_%D0%B4%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%BE%D0%BC)
4. [SELinux – описание и особенности работы с системой. Часть 1](https://habr.com/ru/companies/kingservers/articles/209644/)
5. [SELinux — описание и особенности работы с системой. Часть 2](https://habr.com/ru/companies/kingservers/articles/209970/)
6. [SELinux - публикации](https://habr.com/ru/search/?q=SELinux&target_type=posts&order=relevance)
7. [Руководство для начинающих по SELinux](https://habr.com/ru/companies/otus/articles/460387/)
