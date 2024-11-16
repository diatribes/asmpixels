main: 
	nasm -g -felf64 src/main.asm -o src/main.o
	ld src/main.o -o main.out -dynamic-linker /lib64/ld-linux-x86-64.so.* -lc -lSDL2

clean:
	rm -fv main.out *.o
