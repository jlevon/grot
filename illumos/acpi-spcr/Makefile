
all: acpi-spcr.c
	gcc -g -I$(UTS)/intel -o acpi-spcr acpi-spcr.c
	ctfconvert acpi-spcr

run:
	acpidump -n SPCR -b ./spcr.dat
	./acpi-spcr ./spcr.dat
