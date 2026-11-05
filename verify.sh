#!/bin/bash
# Immunization 6-check for R2125608329 (heilbronn/snaky RUNBOOK pattern + corpus byte-exactness):
#  1. lake build green            2. zero sorry
#  3. axioms exactly 3            4. -DautoImplicit=false clean
#  5. statement byte-exact vs corpus (sha256 1caa563b...)
#  6. bare-import audit dry-run (import + axioms print, NO opens)
set -u
cd "$(dirname "$0")"
TARGET=target/QuantitativeVanDerWaerden.lean
STATEMENT=challenges/van-der-waerden/Statement.lean
ENTRY=BigOSpeedrun.VanDerWaerden.bound_baseline
CORPUS_SHA256=1caa563bbf7a5602adb8cdbbc06aaf1e3d4d5fe27ed4bebf2bf44cf2937a6593
FAIL=0

echo "== check 2: zero sorry (glue + vendored tree)"
if grep -rn 'sorry' Submission.lean AxiomCheck.lean Submission --include='*.lean' | grep -v -- '--' ; then echo "FAIL: sorry present"; FAIL=1; else echo "OK: no sorry"; fi

echo "== check 1: lake build"
lake build > logs_verify_build.txt 2>&1
rc=$?
echo "build exit=$rc"
[ $rc -eq 0 ] || { echo "FAIL: build"; tail -20 logs_verify_build.txt; FAIL=1; }

echo "== check 3+4+6: independent replay (axioms + autoImplicit=false + bare-import dry-run)"
lake env lean -DautoImplicit=false AxiomCheck.lean > logs_axioms.txt 2>&1
rc=$?
echo "replay exit=$rc"; cat logs_axioms.txt
got=$(tr '\n' ' ' < logs_axioms.txt | sed 's/.*depends on axioms: \[\([^]]*\)\].*/\1/' | tr ',' '\n' | tr -d ' ' | grep -v '^$' | LC_ALL=C sort | tr '\n' ',')
want="Classical.choice,Quot.sound,propext,"
if [ "$got" = "$want" ]; then echo "OK: axioms exactly {propext, Classical.choice, Quot.sound}"; else echo "FAIL: axiom set = [$got]"; FAIL=1; fi
[ $rc -eq 0 ] || FAIL=1
# bare-import audit: AxiomCheck must carry no `open` (import + axioms print only)
if grep -qE '^\s*open\b' AxiomCheck.lean; then echo "FAIL: AxiomCheck uses open (not a bare-import audit)"; FAIL=1; else echo "OK: bare-import audit (no opens)"; fi

echo "== check 5: statement byte-exact vs corpus (sha256)"
h1=$(shasum -a 256 "$STATEMENT" | awk '{print $1}')
h2=$(shasum -a 256 "$TARGET" | awk '{print $1}')
echo "statement sha: $h1"
echo "target    sha: $h2"
if [ "$h1" = "$CORPUS_SHA256" ] && [ "$h2" = "$CORPUS_SHA256" ]; then echo "OK: statement byte-exact to corpus ($CORPUS_SHA256)"; else echo "FAIL: statement differs from corpus"; FAIL=1; fi

echo "== verdict: $([ $FAIL -eq 0 ] && echo GREEN 6/6 || echo RED)"
exit $FAIL
