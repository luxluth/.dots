#!/usr/bin/fish

ls ~/Pictures/walls/ >>.ref && cat .ref | awk '!seen[$0]++' | sort >.ref.tmp && mv .ref.tmp .ref
