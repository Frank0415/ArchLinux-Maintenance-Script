#!/bin/sh

function usage() {
    echo "Monitor and Wacom Configuration Script"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo " -ext-on|off       Turn on/off the external display."
    echo " -wa-lap|ext       Map Wacom tablet to the laptop display or external display."
    echo " -d                DO NOT Download the canvas files, download is the default."
    echo " -h, --help        Show this help message."
    exit 1
}

wacom_button() {
    xsetwacom set "$WACOM_DEVICE_NAME" MapToOutput "$MAP_TO_OUTPUT"
    xsetwacom set "$WACOM_DEVICE_NAME" Button 2 "key +ctrl z -ctrl"
    xsetwacom set "$WACOM_DEVICE_NAME" Button 3 "key +Shift +ctrl p -ctrl -Shift"
    xsetwacom set "$WACOM_DEVICE_NAME" PressureCurve 0 0 0 100
    xsetwacom set "$WACOM_DEVICE_NAME" PressureCurve 0 100 100 100
}

EXTERNAL_STATE="" # on, off
WACOM_TARGET=""   # laptop, extern
DOWNLOAD="true"

if [[ $# -eq 0 ]]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -ext-on)
            EXTERNAL_STATE="on"
            ;;
        -ext-off)
            EXTERNAL_STATE="off"
            ;;
        -wa-lap)
            WACOM_TARGET="laptop"
            ;;
        -wa-ext)
            WACOM_TARGET="extern"
            ;;
        -d)
            DOWNLOAD="false"
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
    shift
done

# 检查GPU模式
OM_STATUS=$(optimus-manager --status 2>/dev/null)
if echo "$OM_STATUS" | grep -q "Current mode: hybrid"; then
    GPU_MODE="hybrid"
    LAPTOP_DISPLAY="eDP-1"
    EXTERNAL_DISPLAY="HDMI-1-0"
elif echo "$OM_STATUS" | grep -q "Current mode: integrated"; then
    GPU_MODE="integrated"
    LAPTOP_DISPLAY="eDP-1"
    EXTERNAL_DISPLAY="DP-3"
else
    GPU_MODE="nvidia"
    LAPTOP_DISPLAY="DP-2"
    EXTERNAL_DISPLAY="HDMI-0"
fi

# 启动5秒自动终止
(sleep 5 && kill -0 $$ 2>/dev/null && kill $$) &

asusctl profile -p

# 外接屏幕管理
if [[ "$EXTERNAL_STATE" == "on" ]]; then
    echo "$GPU_MODE"
    xrandr --output "$LAPTOP_DISPLAY" --auto --scale 1.25
    xrandr --output "$EXTERNAL_DISPLAY" --auto --pos 3200x-151
    pkill polybar; pkill polybar; pkill polybar
    sleep 2
    sh "$HOME/.config/polybar/launch.sh" &>/dev/null &
    nitrogen --restore &>/dev/null &
    wacom-button &>/dev/null &
elif [[ "$EXTERNAL_STATE" == "off" ]]; then
    echo "$GPU_MODE"
    xrandr --output "$LAPTOP_DISPLAY" --auto --scale 1.25
    xrandr --output "$EXTERNAL_DISPLAY" --off
    nitrogen --restore &>/dev/null &
    wacom-button &>/dev/null &
fi

# Wacom 映射逻辑
WACOM_DEVICE_NAME="Wacom One by Wacom M Pen stylus" # 这里按实际调整
MAP_TO_OUTPUT=""

if [[ "$GPU_MODE" == "integrated" ]]; then
    # 原有逻辑
    if [[ "$WACOM_TARGET" == "laptop" ]]; then
        MAP_TO_OUTPUT="$LAPTOP_DISPLAY"
        echo "Mapping Wacom to Laptop Display: $MAP_TO_OUTPUT"
    elif [[ "$WACOM_TARGET" == "extern" ]]; then
        # 检查外接是否激活
        if xrandr | grep "$EXTERNAL_DISPLAY connected" | grep -q ' [0-9]\+x[0-9]\+'; then
            MAP_TO_OUTPUT="$EXTERNAL_DISPLAY"
            echo "Mapping Wacom to External Display: $MAP_TO_OUTPUT"
        else
            echo "Wacom mapping to external display ($EXTERNAL_DISPLAY) skipped: Display is not active or not connected."
        fi
    fi
else
    # 非integrated GPU，使用HEAD-0/HEAD-1
    if [[ "$WACOM_TARGET" == "laptop" ]]; then
        MAP_TO_OUTPUT="HEAD-0"
        echo "Mapping Wacom to Laptop Display (HEAD-0)"
    elif [[ "$WACOM_TARGET" == "extern" ]]; then
        MAP_TO_OUTPUT="HEAD-1"
        echo "Mapping Wacom to External Display (HEAD-1)"
    fi
fi

if [[ -n "$MAP_TO_OUTPUT" ]]; then
    xsetwacom set "$WACOM_DEVICE_NAME" MapToOutput "$MAP_TO_OUTPUT"
    xsetwacom set "$WACOM_DEVICE_NAME" Button 2 "key +ctrl z -ctrl"
    xsetwacom set "$WACOM_DEVICE_NAME" Button 3 "key +Shift +ctrl p -ctrl -Shift"
    xsetwacom set "$WACOM_DEVICE_NAME" PressureCurve 0 0 0 100
    xsetwacom set "$WACOM_DEVICE_NAME" PressureCurve 0 100 100 100
    echo "Wacom tablet '$WACOM_DEVICE_NAME' mapped to $MAP_TO_OUTPUT."
elif [[ -n "$WACOM_TARGET" ]]; then
    echo "Wacom mapping skipped for target '$WACOM_TARGET' due to issues mentioned above."
fi

if [[ "$DOWNLOAD" == "true" ]]; then
    /home/frank/Documents/sjtu_canvas_downloader/main.sh &>/dev/null &
else
    echo "Download option is disabled."
fi

fastfetch -c $HOME/.config/fastfetch/myconfig.jsonc &

wait
