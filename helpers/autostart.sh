#!/bin/bash

AUTOSTART_PROP="autostart.hasrun"
HASPROP=$(xrdb -query |grep $AUTOSTART_PROP)


if [ "$HASPROP" != "" ]
then
    echo "autostart prop found"
    exit 0;
fi

echo "$AUTOSTART_PROP:on" |  xrdb -merge
echo "autostart not found"
dex -a -e awesome
