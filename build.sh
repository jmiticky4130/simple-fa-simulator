#!/usr/bin/env bash
# Production build: elm --optimize, then terser two-pass.
# Use plain `elm make src/Main.elm --output=elm.js` for dev builds.

elm make src/Main.elm --optimize --output=elm.opt.js

npx --yes terser elm.opt.js \
  --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' \
  --output elm.tmp.js

npx --yes terser elm.tmp.js --mangle --output elm.js

rm elm.opt.js elm.tmp.js
