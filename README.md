# CBlit_cad

A simple CAD application. It also serves as a demonstration showing:
* How to use "Phoenix_gi" Graphics Interface Library in your C/C++ Program.

## Using CMake (Windows)
```
# Build
cmake -S . -B build
cmake --build build

# Launch the binary executable
build\bin\CBlit_cad.exe
```
  
Executable files should be in build/bin folder

## Build steps on Linux
- Inside the project root folder perform the following steps.
```
# Install Build essentials (required Libs - Versions may be different on your system)
sudo apt install -y libwebkit2gtk-4.1-dev libsoup-3.0-dev

# Compile and build
cmake -S . -B build
cmake --build build

# (To be fixed) Rename phoenix_gi.so to the Expected lib name
cp build/bin/phoenix_gi.so build/bin/libphoenix_gi.so.1

# Export LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/build/bin/

# Launch the Binary executable
build/bin/CBlit_cad
```
