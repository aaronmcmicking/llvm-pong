#!/bin/sh

RAYLIB="-lraylib"

clang -o pong pong.ll $RAYLIB

