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
    grep -q '^## .*Разобранный пример' "$week/lecture.md" || fail "$name/lecture.md: нет разобранного примера с ожидаемым выводом"
  fi
  if [[ -f "$week/practice.md" ]]; then
    if grep -qE '^[[:space:]]*cd CollegeLMS\.Next &&' "$week/practice.md"; then
      fail "$name/practice.md: cd CollegeLMS.Next без подоболочки — блок не скопируется целиком"
    fi
  fi
  if [[ -f "$week/self-check.md" ]]; then
    q=$(grep -cE '^### [0-9]+\.' "$week/self-check.md" || true)
    (( q >= 5 && q <= 7 )) || fail "$name/self-check.md: $q вопросов, нужно 5–7"
  fi
  if [[ -f "$week/results.md" ]]; then
    grep -q '^## Артефакт' "$week/results.md" || fail "$name/results.md: нет раздела «Артефакт»"
    grep -q 'Фактическая команда' "$week/results.md" || fail "$name/results.md: в журнале нет фактической команды"
    grep -q 'cwd' "$week/results.md" || fail "$name/results.md: в журнале нет рабочего каталога"
  fi
done

if [[ -f course/week-01/practice.md ]]; then
  grep -q 'Резервный сценарий' course/week-01/practice.md || fail "week-01/practice.md: нет готового резервного сценария"
fi

if [[ -f course/week-02/practice.md ]]; then
  grep -q 'повторн' course/week-02/practice.md || fail "week-02/practice.md: нет обязательного повторного прогона"
  grep -q 'зелён' course/week-02/practice.md || fail "week-02/practice.md: нет критерия зелёного прогона"
  grep -q 'изолированн' course/week-02/practice.md || fail "week-02/practice.md: нет требования изолированного стенда для E2E"
  grep -q 'не запускался' course/week-02/practice.md || fail "week-02/practice.md: нет допустимой записи «не запускался»"
fi

if grep -rInE 'TBD|TODO|FIXME' course --include='*.md' | grep -v '_template'; then
  fail "в материалах остались TBD/TODO/FIXME"
fi

if (( errors > 0 )); then
  echo "Проверка не пройдена: $errors ошибок"
  exit 1
fi
echo "OK: каркас и материалы согласованы"
