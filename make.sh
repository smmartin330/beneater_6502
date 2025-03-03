if [ ! -d tmp ]; then
	mkdir tmp
fi

echo eater
ca65 -D eater msbasic.s -o tmp/eater.o &&
ld65 -C eater.cfg tmp/eater.o -o tmp/eater.bin -Ln tmp/eater.lbl