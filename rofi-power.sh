#!/bin/bash
# ↹ 🔒\n⌫\n🗘\n⏾\n⏼\n\n⏻
sel=$(echo -e '🔒\n⌫\n↹\n⏾\n⏼\n🗘\n⏻'|\
    rofi -dmenu -config powermenu.rasi -format i \
    -kb-select-1 "l" \
    -kb-select-2 "e" \
    -kb-select-3 "u" \
    -kb-select-4 "s" \
    -kb-select-5 "h" \
    -kb-select-6 "r" \
    -kb-select-7 "Alt+s")
case $sel in
    0) i3exit lock;;
    1) i3exit logout;;
    2) i3exit switch_user;;
    3) i3exit suspend;;
    4) i3exit hibernate;;
    5) i3exit reboot;;
    6) i3exit shutdown;;
esac

