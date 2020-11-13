#pragma once

#include "sokol_gfx.h"

typedef struct HexaGrid {
    sg_buffer vertex_buffer;
    sg_buffer index_buffer;
    int num_elements;
} HexaGrid;

HexaGrid build_hexagrid(float radius, int columns);
sg_pipeline build_hexagrid_pipeline();
