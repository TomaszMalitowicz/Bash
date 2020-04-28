#!/bin/bash
x=5
y=3

wynik=$(bc <<< "scale=2;$x/$y")
echo "float $x / $y = $wynik"