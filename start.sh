#!/bin/bash

export PORT=5150

cd ~/www/othello
./bin/othello stop || true
./bin/othello start
