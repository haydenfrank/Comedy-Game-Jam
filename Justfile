# Converted Makefile -> justfile

# Variables
target := "game.love"
zip := "zip"
love := "love"


run: build
    {{love}} {{target}}

# Default target (first recipe is default)
build:
    rm -f {{target}}
    {{zip}} -9 -r {{target}} main.lua conf.lua src assets -x '*.git*' '*.DS_Store'
    echo Built {{target}}

# Keep an `all` target for compatibility with the Makefile
all: build

clean:
    rm -f {{target}}
    echo Removed {{target}}
