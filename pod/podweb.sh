#!/bin/sh

podwebserver &
sleep 1
open -a "/Applications/Google Chrome.app" http://localhost:8020/
