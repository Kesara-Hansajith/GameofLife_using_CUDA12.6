#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include <stdlib.h>
#include <time.h>
#include <SDL.h>

using namespace std;

const int CELL_SIZE = 10; // Size of each cell in pixels

// Kernel function for Game of Life logic
__global__ void gameKernel(int* Md, int* Nd, int Width, int Height)
{
    int current = blockIdx.x * blockDim.x + threadIdx.x;
    if (current >= Width * Height) return; // Prevent out-of-bounds access

    int row = current / Width;
    int col = current % Width;

    int alive_neighbors = 0;

    // Check all 8 neighbors
    for (int i = -1; i <= 1; ++i) {
        for (int j = -1; j <= 1; ++j) {
            if (i == 0 && j == 0) continue; // Skip the cell itself
            int neighbor_row = row + i;
            int neighbor_col = col + j;
            if (neighbor_row >= 0 && neighbor_row < Height && neighbor_col >= 0 && neighbor_col < Width) {
                alive_neighbors += Md[neighbor_row * Width + neighbor_col];
            }
        }
    }

    // Apply Game of Life rules
    Nd[current] = (Md[current] == 1 && (alive_neighbors == 2 || alive_neighbors == 3)) || (Md[current] == 0 && alive_neighbors == 3) ? 1 : 0;
}

// Function to create a random board
int* createBoard(int width, int height) {
    int* board = new int[width * height];
    srand(static_cast<unsigned int>(time(nullptr)));
    for (int i = 0; i < width * height; i++) {
        board[i] = rand() % 2; // Randomly assign cells as 1 (alive) or 0 (dead)
    }
    return board;
}


// Function to render the board using SDL
void renderBoard(SDL_Renderer* renderer, int* board, int width, int height) {
    SDL_SetRenderDrawColor(renderer, 0, 200, 200, 255); // Bbackground
    SDL_RenderClear(renderer);

    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255); // Alive cells
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            if (board[y * width + x] == 1) {
                SDL_Rect cell = { x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE };
                SDL_RenderFillRect(renderer, &cell); // Draw the cell
            }
        }
    }

    SDL_RenderPresent(renderer); // Update the screen
}

// Function to ask for and validate the width
int askWidth(int maxThreads) {
    int width;
    cout << "\nEnter the width of the board: ";
    cin >> width;
    while (cin.fail() || (width <= 0) || (width > maxThreads)) {
        cout << "\nERROR: Incorrect width,  Enter the numerical value. ";
        cin.clear();
        cin.ignore(256, '\n');
        cout << "\nEnter the width of the board: ";
        cin >> width;
    }
    return width;
}

// Function to ask for and validate the height
int askHeight(int maxThreads) {
    int height;
    cout << "\nEnter the height of the board: ";
    cin >> height;
    while (cin.fail() || (height <= 0) || (height > maxThreads)) {
        cout << "\nERROR: Incorrect height, Enter the numerical value. ";
        cin.clear();
        cin.ignore(256, '\n');
        cout << "\nEnter the height of the board: ";
        cin >> height;
    }
    return height;
}

int main(int argc, char* args[]) {
    // Initialize CUDA
    cudaDeviceProp properties;
    cudaGetDeviceProperties(&properties, 0);
    int threadsPerBlock = properties.maxThreadsPerBlock;

    // Ask user for board dimensions
    int width = askWidth(threadsPerBlock);
    int height = askHeight(threadsPerBlock);

    // Create and initialize the board
    int* board = createBoard(width, height);
    int* d_board, * d_nextBoard;
    cudaMalloc(&d_board, width * height * sizeof(int));
    cudaMalloc(&d_nextBoard, width * height * sizeof(int));
    cudaMemcpy(d_board, board, width * height * sizeof(int), cudaMemcpyHostToDevice);

    // Initialize SDL
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        cout << "SDL could not initialize! SDL_Error: " << SDL_GetError() << endl;
        return -1;
    }

    SDL_Window* window = SDL_CreateWindow("Game of Life", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width * CELL_SIZE, height * CELL_SIZE, SDL_WINDOW_SHOWN);
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    bool quit = false;
    SDL_Event e;

    while (!quit) {
        while (SDL_PollEvent(&e) != 0) {
            if (e.type == SDL_QUIT) {
                quit = true;
            }
        }

        // Launch kernel to compute next generation
        int blocks = (width * height + threadsPerBlock - 1) / threadsPerBlock;
        gameKernel << <blocks, threadsPerBlock >> > (d_board, d_nextBoard, width, height);

        // Copy next state back to host
        cudaMemcpy(board, d_nextBoard, width * height * sizeof(int), cudaMemcpyDeviceToHost);

        // Render the board using SDL
        renderBoard(renderer, board, width, height);

        // Swap pointers for next iteration
        int* temp = d_board;
        d_board = d_nextBoard;
        d_nextBoard = temp;

        SDL_Delay(120); // Delay for visual effect (120 ms per frame)
    }

    // Free resources
    cudaFree(d_board);
    cudaFree(d_nextBoard);
    delete[] board;

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
