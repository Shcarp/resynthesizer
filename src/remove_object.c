#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include "emscripten.h"

#include "imageSynth.h"


EMSCRIPTEN_KEEPALIVE
unsigned char *remove_object_func(unsigned char *image, unsigned char *mask, int height, int width)
{
    static int cancel = 0;
    static TImageSynthParameters params = {
        .matchContextType = 1,
        .mapWeight = 0.5f,
        .sensitivityToOutliers = 0.117f,
        .patchSize = 30,
        .maxProbeCount = 200,
    };

    ImageBuffer source_buffer = {.data = image};
    ImageBuffer mask_buffer = {.data = mask};

    source_buffer.width = width;
    source_buffer.height = height;
    source_buffer.rowBytes = width * 4;

    // apha channel
    mask_buffer.width = width;
    mask_buffer.height = height;
    mask_buffer.rowBytes = width * 1;

    // remove object

    imageSynth(&source_buffer, &mask_buffer, T_RGBA, &params, NULL, NULL, &cancel);

    return source_buffer.data;
}