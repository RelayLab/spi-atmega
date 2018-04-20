SRC=$(wildcard *.c)	#this command adds all .c files to SRC variable
OBJ=$(SRC:.c=.o)	#this copies SRC variable and replaces .c with .o, resulting in list of object files
ELF=$(SRC:.c=.elf)	#same for executable binary file
LST=$(SRC:.c=.lst)	#same for listing file for analysis purpouses
HEX=$(SRC:.c=.hex)	#same for hex executable for mcu
MMCU=atmega328p		#type of mmcu
CFLAGS=-Os -mmcu=$(MMCU) -g # -0s means no optimisation, -g compiles with debug information
LDFLAGS=			#put libraries path here, here we use none

all: $(OBJ) $(ELF) $(LST) $(HEX) gdbinit		#this compiles all files in project in one comand

#this translates source code to separate object files
%.o: %.c
	avr-gcc -c $< -o $@ $(CFLAGS) $(LDFLAGS)

#this compiles object files to single binary
%.elf: %.o 
	avr-gcc $< -o $@ -mmcu=$(MMCU)

#this organizes binary file into new binary file for writing in mcu
%.hex:%.elf
	avr-objcopy -j .text -j .data -O ihex main.elf main.hex

#this disassembles binary file for analysis purpouses
%.lst: %.elf
	avr-objdump $< -S > $@

#this creates initial file for avr-gdb
gdbinit:
	@echo target remote localhost:1212>gdbinit
	@echo
	@echo load>>gdbinit
	@echo
	@echo b main>>gdbinit
	@echo
	@echo c>>gdbinit

#use this to run avr-gdb and it's server with preconfiguried file
debug: $(OBJ) gdbinit
	start "simulavr" cmd /c simulavr -g -d atmega48
	avr-gdb -x gdbinit main.elf

#this for cleaning project
clean:
	#REMOVING BUILD INFO ...
	rm *.o *.elf *.lst *.hex
	rm gdbinit

rebuild:
	make clean
	make all

prog:main.hex main.lst
	#for dirty windows peasants, where COM number should be found with devmgmt.msc
	#avrdude -p atmega328p -b 57600 -P COM3 -c arduino  -e -U flash:w:main.hex
	#
	#for noble gnu citizens find /dev/serial/... can be different
	#for some boards, you need specify -b 57600 flag, for others not (WHY?)
	#
	#sudo avrdude -p atmega328p -b 57600 -P /dev/serial/by-id/usb-1a86_USB2.0-Serial-if00-port0 -c arduino  -e -U flash:w:main.hex
	sudo avrdude -p atmega328p -P /dev/serial/by-path/pci-0000:00:14.0-usb-0:4.1:1.0-port0 -c arduino  -e -U flash:w:main.hex


