# Источники и версии

Материалы курса — переработка, а не копия. Ниже указано, что именно взято из каждого источника и что проверено на дату.

## Источники

| Источник | Ссылка | Что взято |
|---|---|---|
| Курс «AI Coding для Разрабов», Advanced | https://ai.khakhalev.com/course/ | Темы модулей: AI-native repository, Agentic SDLC, обслуживание репозитория; структура артефактов `AGENTS.md` и `.memory-bank/`; идея «чинить процесс, а не результат». |
| Курс Foundation | https://ai.khakhalev.com/course/foundation/ | Порядок освоения инструментов, первая задача, контекст, feedback loop, расширяемость, безопасность, отладка. |
| Roadmap Agentic SDLC | https://ai.khakhalev.com/roadmap/ | 17 навыков и их результаты — основа таблицы `course/roadmap.md`. |
| Демо-проект Gristmill | https://github.com/timurkhakhalev/gristmill | Пример AI-native repository: инструкции, память проекта, skills, рабочий процесс с агентами. |
| Документация OpenCode | https://opencode.ai/docs/ | Команды `opencode models`, `opencode mcp list`, `opencode plugin list`, `opencode auth list`; настройка модели, skills, MCP и plugins. |
| `AGENTS.md` CollegeLMS | локально: `/home/user1/CollegeLMS/AGENTS.md` | Правила веток, коммитов, merge и push; команды проверки; границы согласования. |

Дизайн курса и принятые решения — в `docs/specs/2026-11-10-agentic-sdlc-course-design.md`.

## Версии на 2026-11-10

| Компонент | Версия / значение |
|---|---|
| OpenCode | v2.2.6 |
| Node.js | v24.21.0 |
| .NET SDK | 10.0.402 |
| git | 2.43.0 |
| Модель | `opencode-go/deepseek-v4.1-flash` |
| Профиль OpenCode | `desktop` |
| CollegeLMS | .NET 10 + Next.js 14, PostgreSQL |

Версии проверяются командами `opencode --version`, `node --version`, `dotnet --version`, `git --version`. Версия модели видна в `opencode models` и в конфиге `~/.config/opencode/opencode.jsonc`.

## Правило обновления

Устаревший материал не переписывается молча. Рядом с изменившимся фрагментом ставится дата проверки и пометка «устарело» с кратким объяснением, что изменилось. Новая версия пишется отдельным абзацем или отдельной строкой таблицы, чтобы было видно, на чём основан текущий текст.

Если команда из `AGENTS.md` CollegeLMS изменилась, приоритет у `AGENTS.md`: материалы курса приводятся к нему, а не наоборот. Ссылки проверяются перед каждой итерацией сборки; недоступная ссылка помечается датой проверки, а не удаляется.
