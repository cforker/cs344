// Homework 1
// Color to Greyscale Conversion

//A common way to represent color images is known as RGBA - the color
//is specified by how much Red, Grean and Blue is in it.
//The 'A' stands for Alpha and is used for transparency, it will be
//ignored in this homework.

//Each channel Red, Blue, Green and Alpha is represented by one byte.
//Since we are using one byte for each color there are 256 different
//possible values for each color.  This means we use 4 bytes per pixel.

//Greyscale images are represented by a single intensity value per pixel
//which is one byte in size.

//To convert an image from color to grayscale one simple method is to
//set the intensity to the average of the RGB channels.  But we will
//use a more sophisticated method that takes into account how the eye 
//perceives color and weights the channels unequally.

//The eye responds most strongly to green followed by red and then blue.
//The NTSC (National Television System Committee) recommends the following
//formula for color to greyscale conversion:

//I = .299f * R + .587f * G + .114f * B

//Notice the trailing f's on the numbers which indicate that they are 
//single precision floating point constants and not double precision
//constants.

//You should fill in the kernel as well as set the block and grid sizes
//so that the entire image is processed.

#include "reference_calc.cpp"
#include "utils.h"
#include <stdio.h>

__global__
void rgba_to_greyscale(const uchar4* const rgbaImage,
                       unsigned char* const greyImage,
                       int numRows, int numCols)
{
  //TODO
  //Fill in the kernel to convert from color to greyscale
  //the mapping from components of a uchar4 to RGBA is:
  // .x -> R ; .y -> G ; .z -> B ; .w -> A
  //
  //The output (greyImage) at each pixel should be the result of
  //applying the formula: output = .299f * R + .587f * G + .114f * B;
  //Note: We will be ignoring the alpha channel for this conversion
  int xIdx = blockIdx.x * blockDim.x + threadIdx.x;
  int yIdx = blockIdx.y * blockDim.y + threadIdx.y;
  int idx = yIdx * numCols + xIdx;
  uchar4 pixel;
  float greyPixel;
  
  if ((xIdx < numCols) && (yIdx < numRows)) {
    pixel = rgbaImage[idx];
    greyPixel = 0.299f * pixel.x + 0.587f * pixel.y + 0.114f * pixel.z;
    greyImage[idx] = greyPixel;
  }
  

  //First create a mapping from the 2D block and grid locations
  //to an absolute 2D location in the image, then use that to
  //calculate a 1D offset
}

void your_rgba_to_greyscale(const uchar4 * const h_rgbaImage, uchar4 * const d_rgbaImage,
                            unsigned char* const d_greyImage, size_t numRows, size_t numCols)
{
  //You must fill in the correct sizes for the blockSize and gridSize
  //currently only one block with one thread is being launched
  int blockRows = numRows;
  int blockCols = numCols;
  int gridRows = 1;
  int gridCols = 1;
  while ((blockRows * blockCols) > 1024) {
    if (blockRows % 2==0) {
        blockRows /= 2;
        gridRows *= 2;
    } else {
        blockRows = (blockRows + 1)/2;
        gridRows *= 2;
    }
    if (blockCols%2==0) {
        blockCols /= 2;
        gridCols *= 2;
    } else {
        blockCols = (blockCols + 1)/2;
        gridCols *= 2;
    }
  }
  
  const dim3 blockSize(blockCols, blockRows, 1);  
  const dim3 gridSize(  gridCols,  gridRows, 1); 
  rgba_to_greyscale<<<gridSize, blockSize>>>(d_rgbaImage, d_greyImage, numRows, numCols);
  
  cudaDeviceSynchronize(); checkCudaErrors(cudaGetLastError());
}


