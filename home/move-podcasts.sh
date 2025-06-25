#!/bin/bash

cd ~/shared/podcasts/incoming

move()
{
	dir=$1
	shift
	if [ -n "$*" ]; then
		for f in "$@"; do
			echo "$f"
			mv "$f" "$dir"
		done
	fi
}

#set -x
shopt -s nullglob

move ../home/Milk\ Street\ Radio/Christopher\ Kimball’s\ Milk\ Street\ Radio/ Milk*/*/*
move ../home/Milk\ Street\ Radio/Christopher\ Kimball’s\ Milk\ Street\ Radio/ Christopher*/*/*
move ../home/Serious\ Eats/Serious\ Eats/ Serious*/*/*

move ../home/BBC\ Radio\ 4/The\ Food\ Programme/ The\ Food\ Programme/*/*
move ../home/BBC\ Radio\ 4/The\ Food\ Programme/ The\ Food\ Programme/*
move ../home/BBC\ Radio\ 4/The\ Kitchen\ Cabinet/ The\ Kitchen\ Cabinet/* 

move ../ra/ RA*odcast*/*/*
move ../ra/ RA/*/*

move ../home/No\ Such\ Thing\ As\ A\ Fish/No\ Such\ Thing\ As\ A\ Fish/ No\ Such\ Thing\ As\ A\ Fish/*/*

move ../home/The\ Bugle/The\ Bugle/ The\ Bugle/The\ Bugle/*

