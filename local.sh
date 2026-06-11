#!/usr/bin/env bash
# Helper to set local FORCE environment (source this file)
# Usage: . ./local.sh

ROOTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Preserve original PYTHONPATH
if [ -n "$PYTHONPATH" ]; then
  export FORCE_ORIG_PYTHONPATH="$PYTHONPATH"
else
  export FORCE_ORIG_PYTHONPATH="False"
fi

PATHS=(
  "3rd_party/py"
  "utils"
  "utils/builder"
  "utils/builder/test_builder"
  "utils/builder/shared"
  "utils/regression"
)

PYTHONPATH=""
for p in "${PATHS[@]}"; do
  if [ -n "$PYTHONPATH" ]; then
    PYTHONPATH="$ROOTPATH/$p:$PYTHONPATH"
  else
    PYTHONPATH="$ROOTPATH/$p"
  fi
done
export PYTHONPATH
export FORCE_SOURCED=True

echo "New PYTHONPATH = ${PYTHONPATH}"

# Try to detect Python include and lib dirs and export them
if command -v python3 >/dev/null 2>&1; then
  PY_INC="$(python3 -c 'import sysconfig; print(sysconfig.get_paths().get("include",""))')"
  PY_LIB="$(python3 -c 'import sysconfig; print(sysconfig.get_config_var("LIBDIR") or "" )')"
  [ -n "$PY_INC" ] && export FORCE_PYTHON_INC="$PY_INC"
  [ -n "$PY_LIB" ] && export FORCE_PYTHON_LIB="$PY_LIB"
  echo "Detected python include: ${FORCE_PYTHON_INC}"
  echo "Detected python lib: ${FORCE_PYTHON_LIB}"
fi
