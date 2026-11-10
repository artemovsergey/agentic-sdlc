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
