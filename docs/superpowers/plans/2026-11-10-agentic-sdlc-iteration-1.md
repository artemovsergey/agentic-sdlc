# Курс «Agentic SDLC» — итерация 1: каркас и недели 1–2

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Собрать каркас личного курса «Agentic SDLC» и готовые материалы недель 1–2, чтобы автор мог начать практику на CollegeLMS.

**Architecture:** Markdown-репозиторий с маршрутом из 17 навыков, источниками и папками недель. Каждая неделя — пять файлов: README, конспект, практикум, самопроверка, журнал. Итерация 1 закрывает недели 1–2; недели 3–8 пишутся после результатов автора.

**Tech Stack:** Markdown, bash, git, GitHub, OpenCode v2.2.6, CollegeLMS (.NET 10 + Next.js 14).

**Spec:** `docs/specs/2026-11-10-agentic-sdlc-course-design.md`

## Global Constraints

- Язык материалов — русский; личный формат, без ПК/ОК, баллов и критериев СПО.
- Нагрузка недели: 4–5 часов; конспект 1200–1800 слов, практикум 1–2 часа, самопроверка 5–7 вопросов с ответами.
- Файлы недели строго: `README.md`, `lecture.md`, `practice.md`, `self-check.md`, `results.md`.
- Команды проверки — только из `AGENTS.md` CollegeLMS; примеры выполняются в отдельном worktree. Если прогон невозможен, вывод помечается как ожидаемый, а в практикум добавляется шаг сверки.
- Сборщик не коммитит, не мержит и не пушит в CollegeLMS, не трогает прод, миграции, env, `docker-compose.yml` и workflow.
- Секретов в материалах нет; версии и дата актуальности — в `course/sources.md`.
- Коммиты только по файлам задачи, префикс `docs:` (материалы) или `chore:` (скрипты).

## Review Focus

- **Команда не совпадает с `AGENTS.md`.** Автор копирует её и получает ошибку. Проверка: сверка каждой команды с таблицей команд CollegeLMS в задаче своей недели.
- **Конспект выходит за 1200–1800 слов.** Проверка: `scripts/check-course.sh` считает слова в каждом `lecture.md`.
- **Практика требует прод, секретов или опасной операции.** Проверка: шаг «границы практики» в задаче недели — только worktree, низкий риск, без миграций/env/compose/workflow.
- **Битая или устаревшая ссылка на источник.** Проверка: `curl -fsI` по каждой ссылке из `sources.md` в финальной задаче.
- **`results.md` не позволяет зафиксировать артефакт.** Проверка: скрипт требует раздел `## Артефакт`, а практикум — конкретную запись в нём.

---

### Task 1: Каркас репозитория и скрипт проверки

**Files:**
- Create: `scripts/check-course.sh`
- Create: `README.md`

**Interfaces:**
- Consumes: дизайн-документ `docs/specs/2026-11-10-agentic-sdlc-course-design.md`.
- Produces: `scripts/check-course.sh` — исполняемый файл, код возврата 0 при согласованном курсе и 1 со списком ошибок; `README.md` — точка входа курса.

- [ ] **Step 1: Написать `scripts/check-course.sh`**

```bash
#!/usr/bin/env bash
set -u
cd "$(dirname "$0")/.."

errors=0
fail() { echo "FAIL: $*"; errors=$((errors + 1)); }

[[ -f README.md ]] || fail "нет README.md"
[[ -f course/roadmap.md ]] || fail "нет course/roadmap.md"
[[ -f course/sources.md ]] || fail "нет course/sources.md"

if [[ -f README.md ]]; then
  grep -q 'course/roadmap.md' README.md || fail "README.md: нет ссылки на course/roadmap.md"
  grep -q 'course/sources.md' README.md || fail "README.md: нет ссылки на course/sources.md"
fi

if [[ -f course/roadmap.md ]]; then
  rows=$(grep -cE '^\| [0-9]+ \|' course/roadmap.md || true)
  [[ "$rows" -eq 17 ]] || fail "roadmap.md: ожидалось 17 навыков, найдено $rows"
fi

if [[ -f course/sources.md ]]; then
  grep -q '2026-11-10' course/sources.md || fail "sources.md: нет даты 2026-11-10"
  grep -q 'OpenCode' course/sources.md || fail "sources.md: нет версии OpenCode"
fi

for week in course/week-01 course/week-02; do
  [[ -d "$week" ]] || fail "нет $week"
done

shopt -s nullglob
for week in course/week-*; do
  [[ -d "$week" ]] || continue
  name=$(basename "$week")
  for f in README.md lecture.md practice.md self-check.md results.md; do
    [[ -f "$week/$f" ]] || fail "$name: нет $f"
  done
  if [[ -f "$week/lecture.md" ]]; then
    words=$(wc -w < "$week/lecture.md")
    (( words >= 1200 && words <= 1800 )) || fail "$name/lecture.md: $words слов, нужно 1200–1800"
  fi
  if [[ -f "$week/self-check.md" ]]; then
    q=$(grep -cE '^### [0-9]+\.' "$week/self-check.md" || true)
    (( q >= 5 && q <= 7 )) || fail "$name/self-check.md: $q вопросов, нужно 5–7"
  fi
  if [[ -f "$week/results.md" ]]; then
    grep -q '^## Артефакт' "$week/results.md" || fail "$name/results.md: нет раздела «Артефакт»"
  fi
done

if grep -rInE 'TBD|TODO|FIXME' course --include='*.md' | grep -v '_template'; then
  fail "в материалах остались TBD/TODO/FIXME"
fi

if (( errors > 0 )); then
  echo "Проверка не пройдена: $errors ошибок"
  exit 1
fi
echo "OK: каркас и материалы согласованы"
```

- [ ] **Step 2: Сделать скрипт исполняемым и запустить**

Run: `chmod +x scripts/check-course.sh && scripts/check-course.sh`
Expected: FAIL — нет `course/roadmap.md`, `course/sources.md`, `course/week-01`, `course/week-02`.

- [ ] **Step 3: Написать `README.md`**

Разделы: что это за курс и для кого; как проходить (8 недель по 4–5 часов, без дедлайнов); структура репозитория (`course/roadmap.md`, `course/sources.md`, `course/week-NN/`); порядок недели (`README` → `lecture` → `practice` → `self-check` → `results`); правила практики в CollegeLMS (ветка до изменения, проверки, merge и push по правилам проекта, запрет миграций/env/compose/workflow без согласования); итерационная сборка (недели 1–2 готовы, 3–8 — после результатов); как отмечать навык в `roadmap.md` (только с доказательством); ссылка на дизайн-документ. Объём — 600–900 слов, без воды.

- [ ] **Step 4: Запустить проверку**

Run: `scripts/check-course.sh`
Expected: FAIL — остались отсутствующие `roadmap.md`, `sources.md`, `week-01`, `week-02`; ошибок про README нет.

- [ ] **Step 5: Commit**

```bash
git add scripts/check-course.sh README.md
git commit -m "docs: каркас курса и скрипт проверки материалов"
```

---

### Task 2: Маршрут из 17 навыков

**Files:**
- Create: `course/roadmap.md`

**Interfaces:**
- Consumes: названия навыков и недели из дизайн-документа, раздел 6.2.
- Produces: таблица `course/roadmap.md`; ровно 17 строк вида `| N | Навык | Критерий «умею» | Неделя | Статус |`; статусы `не начат`, `в работе`, `умею`.

- [ ] **Step 1: Написать `course/roadmap.md`**

Структура: заголовок, легенда статусов, правило «`умею` ставится только с доказательством — ссылкой на артефакт или запись в `results.md`», блок самодиагностики недели 1, таблица.

Строки таблицы (номер, навык, неделя):
1. Инструмент и рабочее окружение — 1
2. Постановка задачи — 1
3. Контекст и инструкции — 2
4. Feedback loop — 2
5. Расширяемость агентов — 3
6. Безопасная работа — 3
7. Диагностика и отладка — 4
8. Знания о проекте — 4
9. Повторяемые процедуры — 5
10. Исследование изменения — 5
11. Выбор решения — 6
12. План и декомпозиция — 6
13. Имплементация с агентами — 7
14. Ревью изменений — 7
15. Параллельная работа — 7
16. Релиз с агентами — 8
17. Обслуживание репозитория — 8

Критерий «умею» — наблюдаемое действие с артефактом, например: «провёл аудит окружения и записал его в `results.md`», «сформулировал постановку с 3–5 проверяемыми критериями приёмки». Начальный статус всех навыков — `не начат`.

- [ ] **Step 2: Запустить проверку**

Run: `scripts/check-course.sh`
Expected: FAIL — ошибка про `roadmap.md` исчезла; остались `sources.md`, `week-01`, `week-02`.

- [ ] **Step 3: Commit**

```bash
git add course/roadmap.md
git commit -m "docs: маршрут из 17 навыков Agentic SDLC"
```

---

### Task 3: Источники и версии

**Files:**
- Create: `course/sources.md`

**Interfaces:**
- Consumes: дизайн-документ, раздел 4; версии окружения.
- Produces: таблица источников и таблица версий с датой `2026-11-10`; правило обновления.

- [ ] **Step 1: Написать `course/sources.md`**

Разделы:
1. Источники: Advanced (`https://ai.khakhalev.com/course/`), Foundation, roadmap (`https://ai.khakhalev.com/roadmap/`), демо Gristmill (`https://github.com/timurkhakhalev/gristmill`), документация OpenCode, `AGENTS.md` CollegeLMS. Для каждого — что именно взято: темы модулей, 17 навыков, структура артефактов, команды проверки.
2. Версии на 2026-11-10: OpenCode v2.2.6, Node.js v24.21.0, .NET 10.0.402, git 2.43.0, модель `opencode-go/deepseek-v4.1-flash`, профиль `desktop`.
3. Правило: устаревшее не переписывается молча — рядом ставится дата проверки и пометка «устарело».

- [ ] **Step 2: Запустить проверку**

Run: `scripts/check-course.sh`
Expected: FAIL — ошибки про `sources.md` исчезли; остались только `week-01`, `week-02`.

- [ ] **Step 3: Commit**

```bash
git add course/sources.md
git commit -m "docs: источники и версии курса"
```

---

### Task 4: Шаблон недели

**Files:**
- Create: `course/_template/README.md`
- Create: `course/_template/lecture.md`
- Create: `course/_template/practice.md`
- Create: `course/_template/self-check.md`
- Create: `course/_template/results.md`

**Interfaces:**
- Consumes: формат недели из дизайн-документа, раздел 7.2.
- Produces: пять шаблонов с плейсхолдерами `{{N}}`, `{{Тема}}`, `{{Навыки}}`; скрипт проверки пропускает `_template`.

- [ ] **Step 1: Написать шаблоны**

- `README.md`: цель недели, навыки roadmap, чек-лист из 3–5 пунктов, артефакт, время.
- `lecture.md`: шесть разделов — зачем навык, термины, как работает в OpenCode, разобранный пример, типичные ошибки, что читать дальше.
- `practice.md`: предусловия, 4–6 шагов с проверяемым результатом, границы (worktree, без прода), критерий готовности.
- `self-check.md`: пять вопросов в формате `### 1. Вопрос` + `**Ответ.** …`.
- `results.md`: разделы `## Дата`, `## Что сделано`, `## Артефакт`, `## Что узнал`, `## Что дальше`.

- [ ] **Step 2: Проверить состав**

Run: `find course/_template -maxdepth 1 -type f | sort`
Expected: пять файлов: `README.md`, `lecture.md`, `practice.md`, `results.md`, `self-check.md`.

- [ ] **Step 3: Commit**

```bash
git add course/_template
git commit -m "docs: шаблон недели курса"
```

---

### Task 5: Неделя 1 — окружение и постановка задачи

**Files:**
- Create: `course/week-01/README.md`
- Create: `course/week-01/lecture.md`
- Create: `course/week-01/practice.md`
- Create: `course/week-01/self-check.md`
- Create: `course/week-01/results.md`

**Interfaces:**
- Consumes: `course/roadmap.md` (навыки 1–2), `course/_template`, команды из `AGENTS.md` CollegeLMS.
- Produces: комплект недели 1; артефакт — постановка задачи с критериями приёмки в `results.md`; отметки навыков 1–2 в `roadmap.md`.

- [ ] **Step 1: Написать `README.md` недели**

Цель: понять, как OpenCode собирает контекст, и научиться ставить задачу. Навыки 1–2. Чек-лист: аудит окружения; выбор низкорисковой задачи; постановка с критериями; самодиагностика. Артефакт: раздел «Постановка задачи» в `results.md`. Время: 4–5 часов.

- [ ] **Step 2: Написать `lecture.md` (1200–1800 слов)**

Разделы:
1. Модель, агент и harness: чем отличаются, что именно настраивается в OpenCode.
2. Как собирается контекст: системная инструкция, `AGENTS.md`, инструменты, история сессии, компакция. Почему лишний контекст мешает.
3. Модель и reasoning effort: где смотреть список моделей (`opencode models`), где задаётся модель, почему цена и качество зависят от выбора.
4. Команды проверки CollegeLMS: таблица из `AGENTS.md` — build, targeted test, csharpier, frontend build, design-system, Playwright.
5. Постановка задачи: ожидаемое поведение, ограничения, неизвестности, критерии приёмки; пример слабой и сильной постановки.
6. Самодиагностика: как честно оценить навыки 1–2 и что считать доказательством.

- [ ] **Step 3: Написать `practice.md`**

Шаги:
1. Аудит окружения: `opencode --version`, `opencode models`, `opencode mcp list`, `opencode plugin list`, `opencode auth list`, конфиг `~/.config/opencode/opencode.jsonc`, проектные `.opencode/skills` и `AGENTS.md`. Заполнить таблицу «компонент — что установлено — версия/путь — замечание».
2. Выбрать низкорисковую задачу из `docs/spec/userstories.md` или текущей работы. Запрещено: миграции, env, `docker-compose.yml`, workflow.
3. Записать постановку в `results.md`: поведение, ограничения, неизвестности, 3–5 проверяемых критериев приёмки, что вне рамок.
4. Провести самодиагностику навыков 1–2 и обновить `roadmap.md` только при наличии доказательства.
5. Критерий готовности: постановку можно отдать агенту без дополнительных вопросов; каждый критерий проверяем; секретов в записи нет.

- [ ] **Step 4: Написать `self-check.md`**

Шесть вопросов с ответами: модель vs harness; зачем `AGENTS.md`; зачем фиксировать reasoning effort; обязательные блоки постановки; критерий приёмки vs шаг плана; почему нельзя запускать `opencode auth export` в учебной сессии.

- [ ] **Step 5: Написать `results.md`**

Разделы: `## Дата`, `## Аудит окружения`, `## Постановка задачи`, `## Самодиагностика`, `## Артефакт`, `## Что узнал`, `## Что дальше`. В `## Артефакт` — ссылка на постановку и обновлённые строки `roadmap.md`.

- [ ] **Step 6: Запустить проверку**

Run: `scripts/check-course.sh`
Expected: FAIL — ошибки по `week-01` исчезли; осталась только `week-02`.

- [ ] **Step 7: Commit**

```bash
git add course/week-01
git commit -m "docs: неделя 1 — окружение и постановка задачи"
```

---

### Task 6: Неделя 2 — контекст и feedback loop

**Files:**
- Create: `course/week-02/README.md`
- Create: `course/week-02/lecture.md`
- Create: `course/week-02/practice.md`
- Create: `course/week-02/self-check.md`
- Create: `course/week-02/results.md`

**Interfaces:**
- Consumes: постановку задачи из недели 1; команды `AGENTS.md`; `course/roadmap.md` (навыки 3–4).
- Produces: комплект недели 2; артефакты — контекст-пакет и журнал проверок в `results.md`, предложения по дополнению `AGENTS.md`; отметки навыков 3–4.

- [ ] **Step 1: Написать `README.md` недели**

Цель: собрать релевантный контекст и замкнуть цикл проверок. Навыки 3–4. Чек-лист: контекст-пакет; прогон проверок; разбор вывода; пробелы `AGENTS.md`. Артефакт: журнал проверок и дополнения `AGENTS.md`. Время: 4–5 часов.

- [ ] **Step 2: Написать `lecture.md` (1200–1800 слов)**

Разделы:
1. Контекст: релевантность важнее объёма; что попадает в окно; почему «прочитай весь репозиторий» не работает.
2. `AGENTS.md` и знания проекта: правила, команды, границы; чем инструкция отличается от документации.
3. Состояние между сессиями: история, компакция, `results.md` как журнал; перспектива `.memory-bank/` на неделе 4.
4. Feedback loop: порядок быстрых проверок — build → csharpier → targeted tests → frontend build → design-system → Playwright; почему сначала дешёвые.
5. Как читать вывод: exit code, первая ошибка, полный лог; что значит «зелёно» и чем ложное зелёное опасно.
6. Типичные ошибки: проверять не то, игнорировать формат, чинить тест вместо кода, запускать тяжёлое без необходимости.

- [ ] **Step 3: Написать `practice.md`**

Шаги:
1. Создать отдельный worktree CollegeLMS вне прод-каталога; работать только в нём.
2. Собрать контекст-пакет под задачу недели 1: файлы, спеки, ограничения, команды, неизвестности. Записать в `results.md`.
3. Прогнать проверки агентом: `dotnet build CollegeLMS.slnx`, `dotnet csharpier check .`, таргетные тесты, `cd CollegeLMS.Next && npm run build`, `npm run check:design-system`, при необходимости `npx playwright test {spec}`. Записать команду, код возврата и краткий итог.
4. Найти 1–3 пробела в `AGENTS.md` по итогам прогона; записать формулировки и обоснование. Не коммитить — дополнения применяет автор.
5. Обновить навыки 3–4 в `roadmap.md` при наличии доказательства.
6. Критерий готовности: журнал проверок воспроизводим; у каждой команды есть результат; предложения по `AGENTS.md` конкретны.

- [ ] **Step 4: Написать `self-check.md`**

Шесть вопросов с ответами: что такое релевантный контекст; зачем `AGENTS.md`; почему компакция может терять важное; порядок проверок и почему; что значит «зелёный» прогон; как отличить ошибку кода от ошибки проверки.

- [ ] **Step 5: Написать `results.md`**

Разделы: `## Дата`, `## Контекст-пакет`, `## Журнал проверок` (таблица «команда — код возврата — итог»), `## Пробелы AGENTS.md`, `## Артефакт`, `## Что узнал`, `## Что дальше`.

- [ ] **Step 6: Запустить проверку**

Run: `scripts/check-course.sh`
Expected: `OK: каркас и материалы согласованы`.

- [ ] **Step 7: Commit**

```bash
git add course/week-02
git commit -m "docs: неделя 2 — контекст и feedback loop"
```

---

### Task 7: Финальная проверка итерации

**Files:**
- Modify: `README.md` (статус итерации)
- Modify: `course/roadmap.md` (если проверка выявила расхождения)

**Interfaces:**
- Consumes: все файлы итерации 1.
- Produces: зелёная проверка, тег `iter-1`, отчёт автору.

- [ ] **Step 1: Прогнать скрипт**

Run: `scripts/check-course.sh`
Expected: `OK: каркас и материалы согласованы`.

- [ ] **Step 2: Сверить команды с `AGENTS.md`**

Run: `grep -nE 'dotnet (build|test)|csharpier|npm run|playwright' course/week-0*/lecture.md course/week-0*/practice.md`
Expected: каждая команда дословно совпадает с таблицей команд `AGENTS.md`; расхождений нет.

- [ ] **Step 3: Проверить ссылки**

Run: `grep -oE 'https://[^ )]+' course/sources.md | sort -u | while read -r u; do printf '%s ' "$u"; curl -fsI -o /dev/null -w '%{http_code}\n' "$u" || echo FAIL; done`
Expected: у каждой ссылки код 200–399 или явная пометка о недоступности с датой.

- [ ] **Step 4: Проверить отсутствие секретов и опасных операций**

Run: `grep -rInE 'ghp_|github_pat_|sk-[A-Za-z0-9]|password|secret' course README.md`
Expected: совпадений нет, кроме слова «секрет» в правилах безопасности.

- [ ] **Step 5: Обновить `README.md`**

Добавить строку статуса: «Итерация 1: недели 1–2 готовы, 2026-11-10. Недели 3–8 — после результатов недель 1–2». Ссылка на этот план.

- [ ] **Step 6: Commit и тег**

```bash
git add README.md course/roadmap.md
git commit -m "docs: завершена итерация 1 курса"
git tag iter-1
git push origin main --tags
```

- [ ] **Step 7: Отчёт автору**

Коротко: что готово, что делать (пройти недели 1–2, заполнить `results.md`, обновить `roadmap.md`), что придёт в итерации 2 (недели 3–4), какие решения приняты без него.
