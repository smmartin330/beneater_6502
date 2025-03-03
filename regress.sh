if [ ! -d orig ]; then
	echo Please first run make.sh on the original .s files, create
	echo the directory \"orig\", and copy all .bin files from \"tmp\"
	echo into \"orig\".
	exit;
fi

echo eater
ca65 -D eater msbasic.s -o tmp/eater.o &&
ld65 -C eater.cfg tmp/eater.o -o tmp/eater-new.bin -Ln tmp/eater.lbl && 
xxd -g 1 orig/eater.bin > tmp/eater.bin.txt
xxd -g 1 tmp/eater-new.bin > tmp/eater-new.bin.txt
diff -u tmp/eater.bin.txt tmp/eater-new.bin.txt | head
