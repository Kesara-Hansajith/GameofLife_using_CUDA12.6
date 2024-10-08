# Game of Life with CUDA and SDL

This repository contains an implementation of Conway's Game of Life using CUDA for parallel processing and SDL for graphical rendering. The Game of Life is a cellular automaton devised by the British mathematician John Horton Conway in 1970. It simulates the evolution of a grid of cells based on simple rules, resulting in complex behaviors.

## Game Rules
1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
2. Any live cell with two or three live neighbours lives on to the next generation.
3. Any live cell with more than three live neighbours dies, as if by overpopulation.
4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

## Features
- **Parallel Processing**: Utilizes CUDA to efficiently compute the next generation of the grid, taking advantage of GPU capabilities.
- **Graphical Rendering**: Uses SDL for rendering the game board, providing a visual representation of cell states (alive or dead).
- **Dynamic Input**: Allows users to define the dimensions of the game board and generates an initial random state.

## Getting Started

### Prerequisites
- CUDA Toolkit
- SDL2 library
- Visual Studio 2022
- Nvidia GeForce GTX 1650 Ti

### Installation
1. **Set up SDL2**:
   - Download the SDL2 development libraries from the [SDL website]([https://www.libsdl.org/download-2.0.php](https://github.com/libsdl-org/SDL/releases/tag/release-2.30.8)).
   - Extract the files and add the `include` and `lib` folders to your project.

2. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/game-of-life.git
   cd game-of-life
   ```

3. Compile the program:
   ```bash
   nvcc -o game_of_life game_of_life.cu -lSDL2
   ```

4. Run the executable:
   ```bash
   ./game_of_life
   ```

### How to Play
- Enter the width and height of the game board when prompted.
- Choose the game mode (automatic or manual).
- Observe the evolution of the grid based on the rules of the Game of Life.



## License
This project is licensed under the MIT License.

---

Feel free to adjust any sections as needed!
