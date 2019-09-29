# lc3animals
An animal guessing game for the LC3

# How to use
First, make sure that you have the CLI assembler and simulator for the LC3 installed and in your path. The
  simulator can be downloaded [here](https://github.com/haplesshero13/lc3tools). After installing and setting
  up the simulator, run `make` in the project directory to assemble the code. After the assembly is done, 
  run `make run` to run the program.

If you want to use some other LC3 simulator, you will need to load the `lc3os.obj` and `animals.obj` files and
  set the program counter to x3000. The `animals.obj` file can be created by assembling the `animals.asm` file, eg
  by running `lc3as animals.asm`.
