#!/usr/bin/env bash
# Report fragment symbols that did NOT survive olddefconfig (unmet deps / unknown symbol).
FRAG=${1:-arch/arm/configs/fragments/on5-debug.config}; CFG=${2:-out/.config}
miss=""
while IFS= read -r l; do
  case "$l" in CONFIG_*=y) s=${l%%=*}; grep -q "^$s=y" "$CFG" || miss="$miss ${s#CONFIG_}";; esac
done < "$FRAG"
echo "$miss"
