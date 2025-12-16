#!/bin/bash

LOG_FILE="/tmp/monitor_setup.log"
exec >"$LOG_FILE" 2>&1

echo "Monitor setup initiated at $(date)"

# Detect connected displays
LAPTOP_SCREEN=$(xrandr --query | grep " connected" | grep "eDP" | awk '{ print $1 }')
EXTERNAL_MONITORS=$(xrandr --query | grep " connected" | grep -v "eDP" | awk '{ print $1 }')
PRIMARY_MONITOR=$(echo "$EXTERNAL_MONITORS" | head -n 1)

echo "Detected laptop screen: $LAPTOP_SCREEN"
echo "Detected external monitors: $EXTERNAL_MONITORS"

# Retry mechanism in case external monitors take time to initialize
for i in {1..5}; do
  if [ -n "$EXTERNAL_MONITORS" ]; then
    break
  fi
  echo "No external monitor detected, retrying ($i/5)..."
  sleep 1
  EXTERNAL_MONITORS=$(xrandr --query | grep " connected" | grep -v "eDP" | awk '{ print $1 }')
  PRIMARY_MONITOR=$(echo "$EXTERNAL_MONITORS" | head -n 1)
done

# Configure monitors
if [ -n "$EXTERNAL_MONITORS" ]; then
  echo "Configuring external monitors..."
  for monitor in $EXTERNAL_MONITORS; do
    xrandr --output "$monitor" --auto
  done
  echo "Setting primary monitor: $PRIMARY_MONITOR"
  xrandr --output "$PRIMARY_MONITOR" --primary

  if [ -n "$LAPTOP_SCREEN" ]; then
    echo "Turning off laptop screen: $LAPTOP_SCREEN"
    xrandr --output "$LAPTOP_SCREEN" --off
  fi
else
  echo "No external monitor detected. Enabling laptop screen..."
  if [ -n "$LAPTOP_SCREEN" ]; then
    xrandr --output "$LAPTOP_SCREEN" --auto --primary
  fi
fi

echo "Monitor setup completed at $(date)"
