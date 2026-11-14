# Protonomk Claude Code

Собрание конфигураций, агентов, скиллов и команд для Claude Code — под задачи
разработки с телефона и работы с кодом через агента.

Основа: [everything-claude-code](https://github.com/affaan-m/everything-claude-code)
(MIT). Расширено командой `/goal`, правилами дисциплины целей и разделом про
вайбкодинг на телефоне.

## Что внутри

| Тип | Количество | Что даёт |
| --- | --- | --- |
| **Команды** | 16 | `/goal`, `/plan`, `/tdd`, `/verify`, `/code-review`, `/checkpoint` и другие |
| **Агенты** | 9 | architect, planner, reviewer, security, tdd-guide, e2e, refactor |
| **Скиллы** | 11 | backend, frontend, FastAPI, TDD, security, eval, verification |
| **Правила** | 10 | стиль кода, git, тесты, безопасность, дисциплина целей, вайбкодинг |

## Установка

```bash
git clone https://github.com/Zibin2004/protonomk-claude-code
cd protonomk-claude-code
./scripts/install.sh
```

Или вручную — скопировать нужные папки в `~/.claude/`:

```bash
cp -r commands agents skills rules ~/.claude/
```

## Главное отличие: `/goal`

Команда, которой нет в оригинальном наборе.

Агент без цели отвечает на последний вопрос и забывает предыдущий. `/goal`
фиксирует результат, критерий готовности и ограничения — и агент возвращается
к ним, даже если разговор ушёл в сторону.

```
/goal Собрать форк библиотеки под Android и выложить на GitHub
```

Дальше `/goal` в любой момент показывает, что сделано и что осталось.
`/goal done` закрывает только по проверенному критерию, не по ощущению.

Полное описание: [`commands/goal.md`](commands/goal.md).
Правила работы с целью: [`rules/goal-discipline.md`](rules/goal-discipline.md).

## Набор команд

### Планирование и контроль

| Команда | Когда |
| --- | --- |
| `/goal` | Длинная задача, работа с перерывами |
| `/plan` | Перед началом: разбить на шаги, найти риски |
| `/checkpoint` | Сохранить состояние перед паузой |
| `/verify` | Проверить, что действительно работает |

### Разработка

| Команда | Когда |
| --- | --- |
| `/tdd` | Тесты первыми |
| `/test-coverage` | Посмотреть, что не покрыто |
| `/code-review` | Самопроверка перед PR |
| `/refactor-clean` | Убрать мёртвый код |
| `/build-fix` | Починить сборку |

### Исследование и документация

| Команда | Когда |
| --- | --- |
| `/learn` | Извлечь паттерн из сессии в скилл |
| `/update-docs` | Обновить документацию по изменениям |
| `/update-codemaps` | Перестроить карту кода |
| `/e2e` | Прогнать сквозной сценарий |
| `/eval` | Замерить качество агента |
| `/orchestrate` | Несколько агентов на одну задачу |
| `/setup-pm` | Настроить пакетный менеджер |

## Агенты

`architect` — решения по структуре до написания кода.
`planner` — план с фазами и зависимостями.
`code-reviewer` — свежий взгляд на изменения.
`security-reviewer` — уязвимости и утечки.
`tdd-guide` — тесты вперёд, красный-зелёный-рефакторинг.
`e2e-runner` — сквозные сценарии.
`build-error-resolver` — разбор ошибок сборки.
`refactor-cleaner` — упрощение без смены поведения.
`doc-updater` — документация вслед за кодом.

## Скиллы

`backend-patterns`, `frontend-patterns`, `fastapi-patterns`, `tdd-workflow`,
`tdd-guide`, `security-review`, `security-reviewer`, `eval-harness`,
`verification-loop`, `continuous-learning`, `strategic-compact`.

## Работа с телефона

Набор рассчитан на то, что терминал может быть на Android. Ключевые правила
в [`rules/vibe-coding.md`](rules/vibe-coding.md): маленькие шаги, проверка на
копии данных, промпт из четырёх блоков.

Для запуска агента в Termux:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Zibin2004/opencode-Androd-Termux-Protonomk/main/install.sh)
```

Модели и цены — в боте **[SBProviderbot](https://t.me/SBProviderbot)**.
Для правок кода, разбора ошибок и планирования достаточно `claude-haiku-5-5`:
на задачах такого класса она не ошибается, а стоит копейки.

## Реверс-инжиниринг приложений

Если задача — разобрать чужое приложение, рядом есть
[rea-android](https://github.com/Zibin2004/rea-android): MCP-сервер с 255
инструментами статического анализа, собранный под Android. Подключается к тому
же агенту одной командой.

## Структура

```
commands/   16 файлов — команды вида /goal, /plan
agents/      9 файлов — описания агентов
skills/     11 папок  — скиллы с инструкциями
rules/      10 файлов — правила поведения
hooks/               — хуки (заготовка)
scripts/
  install.sh         — установка в ~/.claude/
```

## Лицензия

MIT. Оригинал: © affaan-m.
Расширения (`/goal`, правила, раздел про телефон): © Zibin2004.
