#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1

GAMEDIR="/$directory/ports/petalcrash"
cd $GAMEDIR/gamedata

export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export BOX86_ALLOWMISSINGLIBS=1
export BOX86_DLSYM_ERROR=1
export BOX86_LOG=1
export SDL_DYNAMIC_API=libSDL2-2.0.so.0

whichos=$(grep "title=" "/usr/share/plymouth/themes/text.plymouth")
if [[ $whichos == *"RetroOZ"* ]]; then
    export LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib32:$GAMEDIR/box86/native"
    export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/lib:$GAMEDIR/box86/native:/usr/lib32/:./:lib/:lib32/:x86/"
else
    export LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib/arm-linux-gnueabihf/:/usr/lib32"
    export BOX86_LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib/arm-linux-gnueabihf/:./:lib/:libbin32/:x86/"
fi

export BOX86_DYNAREC=1
export BOX86_FORCE_ES=31

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "box86" -c "$GAMEDIR/petalcrash.gptk" &
echo "Loading, please wait... one moment please! :)" > /dev/tty0
$GAMEDIR/box86/box86 bin32/Chowdren 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0
