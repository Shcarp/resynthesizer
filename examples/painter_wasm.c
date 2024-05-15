#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include "emscripten.h"

#include "imageSynth.h"

static TImageSynthParameters params = {
    .matchContextType = 1,
    .mapWeight = 0.5f,
    .sensitivityToOutliers = 0.117f,
    .patchSize = 30,
    .maxProbeCount = 200,
};

// Progress callback function
void progressCallback(int percentDone, void *contextInfo)
{
    EM_ASM({ console.log('Progress: ' + $0 + '%'); }, percentDone);
}

EMSCRIPTEN_KEEPALIVE
int removeObject(unsigned char *imageData, unsigned char *maskData, int width, int height)
{
    ImageBuffer imageBuffer = {
        imageData, 
        width, 
        height, 
        rowBytes : width * height
    };
    ImageBuffer mask = {
        maskData, 
        width, 
        height, 
        rowBytes : width * height
    };

    int cancelFlag = 0;

    // Call the original imageSynth function
    return imageSynth(&imageBuffer, &mask, T_RGBA, &params, NULL, NULL, &cancelFlag);
}

int main(int argc, char **argv)
{
    return 0;
}
