CFLAGS_SANIT = -fsanitize=address

all: asm build link run

asm:
	@nasm -f elf64 -l printf.lst printf.asm -o obj/printf.o

build:
	@g++ $(CFLAGS_SANIT) -o obj/main.o -c main.cpp

link:
	@g++ $(CFLAGS_SANIT) -no-pie -o printf obj/printf.o obj/main.o

run:
	@./printf

clean:
	rm -rf obj/*