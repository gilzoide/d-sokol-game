#pragma once

#include "sokol_gfx.h"

typedef struct HexaGrid {
    sg_buffer buffer;
    int num_elements;
} HexaGrid;

HexaGrid build_hexagrid(float radius);
sg_pipeline build_hexagrid_pipeline();