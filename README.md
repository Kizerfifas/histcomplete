# histcomplete

Репозиторий: [github.com/Kizerfifas/histcomplete](https://github.com/Kizerfifas/histcomplete)

```bash
git clone https://github.com/Kizerfifas/histcomplete.git
cd histcomplete
./install.sh
source ~/.bashrc
```

Утилита для **bash** в Ubuntu/Linux: ищет в истории уже введённые команды и подставляет полную строку. Например, после ввода `ls` по **Alt+h** можно получить `ls -la ~/projects`, если такая команда уже выполнялась ранее.

**Tab не перехватывается** — стандартное дополнение путей и имён файлов работает как обычно.

---

## Содержание

1. [Требования](#требования)
2. [Установка](#установка)
3. [Настройка истории bash](#настройка-истории-bash)
4. [Использование в терминале](#использование-в-терминале)
5. [Команда `histcomplete` (CLI)](#команда-histcomplete-cli)
6. [Команда `hc`](#команда-hc)
7. [Примеры](#примеры)
8. [Как это работает](#как-это-работает)
9. [Устранение неполадок](#устранение-неполадок)
10. [Удаление](#удаление)
11. [Ограничения и альтернативы](#ограничения-и-альтернативы)

---

## Требования

| Компонент | Версия / примечание |
|-----------|---------------------|
| ОС | Ubuntu или другой Linux с bash |
| Shell | **bash** (интеграция через readline) |
| Python | **3.6+** (`python3` в PATH) |
| История | Файл `~/.bash_history` (создаётся автоматически при работе в bash) |

Для интерактивных горячих клавиш нужен обычный терминал (GNOME Terminal, Konsole, Cursor/VS Code integrated terminal и т.д.) в режиме **emacs** (режим по умолчанию в bash).

**zsh / fish:** CLI-утилита может читать `~/.zsh_history`, но горячие клавиши из `bash-integration.sh` действуют только в bash.

---

## Установка

### Автоматическая (рекомендуется)

```bash
cd /path/to/histcomplete
chmod +x install.sh
./install.sh
```

Скрипт:

1. Копирует `histcomplete` в `~/.local/bin/histcomplete`
2. Копирует `bash-integration.sh` в `~/.local/share/histcomplete/bash-integration.sh`
3. Добавляет в `~/.bashrc` строку `source` (если её ещё нет)

Активируйте настройки:

```bash
source ~/.bashrc
```

или откройте **новое** окно терминала.

Проверка:

```bash
command -v histcomplete
# ожидается: /home/ВАШ_ПОЛЬЗОВАТЕЛЬ/.local/bin/histcomplete

histcomplete --help 2>/dev/null || histcomplete -h 2>/dev/null || true
```

Убедитесь, что `~/.local/bin` в `PATH`. Если команда не находится, добавьте в `~/.bashrc`:

```bash
export PATH="${HOME}/.local/bin:${PATH}"
```

### Ручная установка

```bash
mkdir -p ~/.local/bin ~/.local/share/histcomplete

cp histcomplete ~/.local/bin/
chmod +x ~/.local/bin/histcomplete

cp bash-integration.sh ~/.local/share/histcomplete/

# В конец ~/.bashrc:
cat >> ~/.bashrc <<'EOF'

# histcomplete — автодополнение из истории команд
[[ -f "${HOME}/.local/share/histcomplete/bash-integration.sh" ]] && \
  source "${HOME}/.local/share/histcomplete/bash-integration.sh"
EOF

source ~/.bashrc
```

### Обновление (уже установлена)

Установка кладёт файлы только в `~/.local/bin` и `~/.local/share/histcomplete`.  
`~/.bashrc` меняется **один раз** при первой установке — при обновлении его трогать не нужно.

**Если репозиторий уже клонирован** (рекомендуется):

```bash
cd ~/projects/histcomplete   # или ваш путь к clone
git pull
./install.sh
source ~/.bashrc
```

**Если ставили без git** — скачайте свежую версию и снова запустите установку:

```bash
cd /tmp
git clone git@github.com:Kizerfifas/histcomplete.git
cd histcomplete
./install.sh
source ~/.bashrc
```

**Что обновляется:**

| Файл | Куда |
|------|------|
| `histcomplete` | `~/.local/bin/histcomplete` |
| `bash-integration.sh` | `~/.local/share/histcomplete/bash-integration.sh` |
| `README.md` | `~/.local/share/histcomplete/README.md` |

**Проверка версии после обновления** — в новом терминале или после `source ~/.bashrc`:

```bash
histcomplete --prefix ls | head -3
bind -X 2>/dev/null | grep histcomplete
```

Открытые терминалы, запущенные **до** `source ~/.bashrc`, продолжают работать со старыми привязками клавиш — перезапустите их или выполните `source ~/.bashrc` в каждом.

---

## Настройка истории bash

Утилита **не придумывает** команды — она только восстанавливает то, что уже было в истории. Чтобы подсказки появлялись сразу в текущей сессии и не терялись между сессиями, добавьте в `~/.bashrc` (если ещё нет):

```bash
# Размер буфера истории
export HISTSIZE=10000
export HISTFILESIZE=20000

# Без дубликатов подряд; опционально: ignorespace — не сохранять строки с ведущим пробелом
export HISTCONTROL=ignoredups

# Дописывать в файл, не перезаписывать при выходе
shopt -s histappend

# Сбрасывать команды текущей сессии в ~/.bash_history после каждой команды
PROMPT_COMMAND="history -a; ${PROMPT_COMMAND:-:}"
```

После правки:

```bash
source ~/.bashrc
```

**Первый запуск:** выполните нужную команду один раз вручную, например:

```bash
ls -la ~/projects
```

После этого `ls` + **Alt+h** сможет подставить полную строку.

---

## Использование в терминале

### Горячие клавиши

| Действие | Клавиши | Описание |
|----------|---------|----------|
| Список из истории | **Alt+h** (1-й раз) | Показать нумерованный список совпадений |
| Подстановка [1] | **Alt+h** на пустой строке | После списка строка очищена — сразу Alt+h = пункт 1 |
| Выбор по номеру | **2** + **Alt+h** | После списка ввести только номер (префикс стёрт автоматически) |
| Интерактивный выбор | **Ctrl+Alt+h** | Меню с номерами (как `histcomplete -i`) |
| Листание по префиксу | **↑** / **↓** | Только команды, **начинающиеся** с текущего текста |
| Пути и файлы | **Tab** | Стандартное дополнение bash (**не изменено**) |

> **Alt+h** — это клавиша **h** с зажатым **Alt** (Meta). В некоторых терминалах Alt+буква может вставлять символы — тогда настройте «Meta sends Escape» в настройках терминала или используйте **Ctrl+Alt+h** / команду `hc`.

### Типичный сценарий

1. В prompt набираете: `ls`
2. **Alt+h** — появляется список, например:  
   `1) ls -la ~/projects`  
   `2) ls -l`
3. Строка ввода **очищается** — введите **`2`** и **Alt+h** (пункт 2) или сразу **Alt+h** (пункт 1)
4. При необходимости правите и нажимаете **Enter**

**↑** / **↓** — листать команды с тем же префиксом без списка.

### Команда `hc`

Встроенная обёртка для интерактивного поиска по аргументу:

```bash
hc docker
hc git
```

Открывает тот же интерактивный выбор, что и **Ctrl+Alt+h**, и подставляет выбранную строку в текущую строку ввода (команда **не выполняется** автоматически).

---

## Команда `histcomplete` (CLI)

Запускается из любого каталога, если `~/.local/bin` в `PATH`.

### Синтаксис

```text
histcomplete [опции] [запрос]
```

### Опции

| Опция | Описание |
|-------|----------|
| `запрос` | Подстрока для поиска (необязательно) |
| `-n`, `--limit N` | Максимум результатов (по умолчанию 25) |
| `--prefix` | Только команды, **начинающиеся** с запроса (режим Alt+h) |
| `-i`, `--interactive` | Интерактивный выбор по номеру |
| `-p`, `--pick` | Вывести ровно одну выбранную команду (в stdout) |
| `-c`, `--complete` | Общий префикс всех совпадений |
| `--suffix` | С `-c`: только хвост после `запрос` (для скриптов) |

### Примеры CLI

```bash
# Список всех команд, содержащих "docker"
histcomplete docker

# Только команды, начинающиеся с "git"
histcomplete --prefix git

# Интерактивный выбор одной команды
histcomplete --prefix -i git

# Вывести одну команду в скрипт
cmd=$(histcomplete --prefix -p -i "rails s")
echo "Выбрано: $cmd"

# Общий префикс (для автоматизации)
histcomplete --prefix -c "git sta"
histcomplete --prefix -c --suffix "git sta"
```

### Переменная окружения `HISTCOMPLETE_EXTRA`

Для bash-интеграции в переменную передаются команды **текущей сессии** (последние 512 из `history`). Вручную можно использовать для отладки:

```bash
export HISTCOMPLETE_EXTRA=$'ls -la ~/projects\nls -l\nls'
histcomplete --prefix ls
```

---

## Примеры

### Просмотр каталога

```bash
# Один раз выполнить и сохранить в историю:
ls -la ~/projects

# Позже в новой строке:
ls               # набрать
# Alt+h, Alt+h   # список → подставить [1]
```

### Git

```bash
# После того как хотя бы раз вводили:
git status

git              # набрать
# Alt+h, Alt+h   # список → подставить [1]
```

### Git

```bash
histcomplete --prefix git pull
# → git pull origin main
# → git pull --rebase
# ...
```

### Docker

```bash
hc docker
# интерактивный выбор среди docker compose, docker ps -a, ...
```

### Использование в скрипте

```bash
#!/usr/bin/env bash
chosen=$(histcomplete --prefix -p -i "$1") || exit 1
echo "Будет выполнено: $chosen"
# read -p "Enter для запуска..." ...
# eval "$chosen"   # осторожно: только если доверяете истории
```

---

## Как это работает

```text
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│  Набор в bash   │────▶│ bash-integration.sh  │────▶│  histcomplete   │
│  (readline)     │     │ Alt+h, Ctrl+Alt+h, hc  │     │  (Python 3)     │
└─────────────────┘     └──────────────────────┘     └────────┬────────┘
                                                                │
                    ┌───────────────────────────────────────────┴──────────┐
                    │  Источники (от новых к старым, без дубликатов):       │
                    │  1. HISTCOMPLETE_EXTRA — команды текущей сессии       │
                    │  2. ~/.bash_history                                    │
                    │  3. ~/.zsh_history (если есть, для CLI)               │
                    └────────────────────────────────────────────────────────┘
```

1. **Поиск:** по умолчанию — подстрока в любом месте; с `--prefix` — только совпадения в **начале** строки.
2. **Сортировка:** сначала совпадения с префиксом, затем по длине.
3. **Интеграция:** функции bash через `bind -x` меняют `READLINE_LINE` / `READLINE_POINT`, не выполняя команду сами.

### Установленные файлы

| Путь | Назначение |
|------|------------|
| `~/.local/bin/histcomplete` | Исполняемый скрипт Python |
| `~/.local/share/histcomplete/bash-integration.sh` | Привязки клавиш и функции `hc` |
| `~/.bashrc` | Строка `source ... bash-integration.sh` |

---

## Устранение неполадок

### «Нет совпадений» / Alt+h ничего не делает

- Команда с нужными аргументами **никогда не выполнялась** — сначала введите её вручную один раз.
- История не пишется в файл — проверьте [настройку истории](#настройка-истории-bash).
- После установки не выполнен `source ~/.bashrc`.
- Запрос не совпадает с **началом** строки: используется режим `--prefix` (как при Alt+h). Для поиска по подстроке в CLI: `histcomplete docker` без `--prefix`.

### После списка ввёл номер (31), а снова «Нет совпадений»

Обновите до последней версии (`git pull && ./install.sh`). Раньше список терялся между нажатиями Alt+h (ограничение `bind -x` в bash). Сейчас список сохраняется в `~/.cache/histcomplete/pending` до выбора пункта.

Порядок: `cd` → **Alt+h** (список, строка пустая) → `31` → **Alt+h** (не искать команды, начинающиеся с «31»).

### `histcomplete: command not found`

```bash
export PATH="${HOME}/.local/bin:${PATH}"
source ~/.bashrc
which histcomplete
```

### Alt+h вставляет странные символы

Терминал не отправляет Meta. Решения:

- Включить в настройках терминала опцию вроде **«Alt как Meta»** / **«Meta key»**;
- Использовать **Ctrl+Alt+h** (интерактивный выбор);
- Использовать `hc запрос` в командной строке.

### Tab перестал дополнять пути

Старая версия могла перехватывать Tab. Обновите `bash-integration.sh` и выполните:

```bash
source ~/.bashrc
bind -p | grep '\\C-i'
# должно быть: "\C-i": complete
```

### Горячие клавиши не работают в Cursor / VS Code

Убедитесь, что integrated terminal использует **bash** (не sh/zsh без интеграции). Проверьте, что не перехватываются сочетания на уровне редактора.

### Дубликаты или старые команды в списке

Настройте `HISTCONTROL=ignoredups` или `erasedups`. Очистка файла истории — на ваш риск:

```bash
# только если понимаете последствия
: > ~/.bash_history
history -c
```

### Проверка без интерактива

```bash
histcomplete --prefix ls | head
bind -X 2>/dev/null | grep -E 'histcomplete|\\\\eh'
```

Ожидаемые привязки:

```text
"\eh": "_histcomplete_expand"
"\e\C-h": "_histcomplete_bind"
```

---

## Удаление

```bash
rm -f ~/.local/bin/histcomplete
rm -rf ~/.local/share/histcomplete

# Удалить блок из ~/.bashrc (вручную), например строки:
#   source ... histcomplete/bash-integration.sh

source ~/.bashrc
```

После удаления перезапустите терминал. Привязки readline сбросятся в новой сессии.

---

## Ограничения и альтернативы

| Ограничение | Пояснение |
|-------------|-----------|
| Только история | Не подсказывает синтаксис команд, которых вы не вводили |
| Нет «призрачного» текста | Во время набора серая подсказка как в fish не показывается — нужно **Alt+h** или **↑** |
| Только bash для hotkeys | zsh/fish требуют своих плагинов |
| Секреты в истории | Пароли и токены в истории попадут в подсказки — используйте `HISTCONTROL=ignorespace` и пробел перед командой |

**Встроенные возможности bash:**

- **Ctrl+r** — обратный поиск по истории
- **↑ / ↓** с `history-search-backward` (включается интеграцией)

**Похожие инструменты:**

- [hstr](https://github.com/dvorka/hstr) — `apt install hstr`
- [fzf](https://github.com/junegunn/fzf) + привязка к истории
- **fish** / **zsh** + autosuggestions — подсказка серым текстом при вводе

---

## Структура репозитория

```text
histcomplete/
├── histcomplete           # Python: поиск и CLI
├── bash-integration.sh    # привязки readline для bash
├── install.sh             # установка в ~/.local
└── README.md              # этот файл
```

---

## Лицензия

Утилита распространяется как есть, без гарантий. Используйте на свой страх и риск, особенно при подстановке команд из истории в production-окружении.
