#!/bin/bash

for i in index.html $(ls -1 html/*.html); do echo https://robang74.github.io/${PWD##*/}/$i; done
