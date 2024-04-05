#!/usr/bin/env bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CARD="$(light -L | grep 'backlight' | head -n1 | cut -d'/' -f3)"
INTERFACE="$(ip link | awk '/state UP/ {print $2}' | tr -d :)"
BAT="$(acpi -b)"
RFILE="$DIR/.module"

# Fix backlight and network modules
fix_modules() {
	if [[ -z "$CARD" ]]; then
		sed -i -e 's/backlight/bna/g' "$DIR"/config.ini
	elif [[ "$CARD" != *"intel_"* ]]; then
		sed -i -e 's/backlight/brightness/g' "$DIR"/config.ini
	fi

	if [[ -z "$BAT" ]]; then
		sed -i -e 's/battery/btna/g' "$DIR"/config.ini
	fi

	if [[ "$INTERFACE" == e* ]]; then
		sed -i -e 's/network/ethernet/g' "$DIR"/config.ini
	fi
}

# Launch the bar
launch_bar() {
	# Terminate already running bar instances
	killall -q polybar

	# Wait until the processes have been shut down
	while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
    # Get the primary monitor
    PRIMARY_MONITOR=$(xrandr --listmonitors | awk '$2 == "+*"{print $4}')
    # Launch Polybar only on the primary monitor
    MONITOR=$PRIMARY_MONITOR polybar -q main -c "$DIR"/config.ini &
}

# Execute functions
if [[ ! -f "$RFILE" ]]; then
	fix_modules
	touch "$RFILE"
fi	
launch_bar
