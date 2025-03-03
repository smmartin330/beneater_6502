# Microsoft BASIC for the Ben Eater 6502 project

This code was forked from [beneater/msbasic](https://github.com/beneater/msbasic) which is forked from [mist64/msbasic](https://github.com/mist64/msbasic). I stripped out everything that isn't for the ben eater 6502. Refer to the original repos for more info.

* All code for other builds removed, only code needed for the eater build removed.
* All definitions moved to defines.s, as build-specific defines file no longer needed.
* bios.s modified to use CB2 pin for RTS instead of VIA A0.
* eater_iscntc.s was folded into flow1.s
* inline.s folded into program.s
* iscntc.s was folded into flow1.s
* loadsave.s and misc3.s no longer needed, removed.
