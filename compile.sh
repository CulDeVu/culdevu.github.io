#!/bin/bash

cd build
gcc -g ../generator.c -fno-strict-aliasing
cd ..