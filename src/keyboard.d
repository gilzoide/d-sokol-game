import sokol_app;
import mathtypes;

enum unboundKeyCode = Vec2i(-1, -1);

/// 
Vec2i keyIndexFromKeycode(sapp_keycode keycode)
{
    // TODO: support QWERTZ
    switch (keycode)
    {
        // First row: numbers
        case SAPP_KEYCODE_1: return Vec2i(0, 0);
        case SAPP_KEYCODE_2: return Vec2i(1, 0);
        case SAPP_KEYCODE_3: return Vec2i(2, 0);
        case SAPP_KEYCODE_4: return Vec2i(3, 0);
        case SAPP_KEYCODE_5: return Vec2i(4, 0);
        case SAPP_KEYCODE_6: return Vec2i(5, 0);
        case SAPP_KEYCODE_7: return Vec2i(6, 0);
        case SAPP_KEYCODE_8: return Vec2i(7, 0);
        case SAPP_KEYCODE_9: return Vec2i(8, 0);
        // Second row: qwert...
        case SAPP_KEYCODE_Q: return Vec2i(0, 1);
        case SAPP_KEYCODE_W: return Vec2i(1, 1);
        case SAPP_KEYCODE_E: return Vec2i(2, 1);
        case SAPP_KEYCODE_R: return Vec2i(3, 1);
        case SAPP_KEYCODE_T: return Vec2i(4, 1);
        case SAPP_KEYCODE_Y: return Vec2i(5, 1);
        case SAPP_KEYCODE_U: return Vec2i(6, 1);
        case SAPP_KEYCODE_I: return Vec2i(7, 1);
        case SAPP_KEYCODE_O: return Vec2i(8, 1);
        // Third row: asdf...
        case SAPP_KEYCODE_A: return Vec2i(0, 2);
        case SAPP_KEYCODE_S: return Vec2i(1, 2);
        case SAPP_KEYCODE_D: return Vec2i(2, 2);
        case SAPP_KEYCODE_F: return Vec2i(3, 2);
        case SAPP_KEYCODE_G: return Vec2i(4, 2);
        case SAPP_KEYCODE_H: return Vec2i(5, 2);
        case SAPP_KEYCODE_J: return Vec2i(6, 2);
        case SAPP_KEYCODE_K: return Vec2i(7, 2);
        case SAPP_KEYCODE_L: return Vec2i(8, 2);
        // Fourth/last row: zxcv...
        case SAPP_KEYCODE_Z: return Vec2i(0, 3);
        case SAPP_KEYCODE_X: return Vec2i(1, 3);
        case SAPP_KEYCODE_C: return Vec2i(2, 3);
        case SAPP_KEYCODE_V: return Vec2i(3, 3);
        case SAPP_KEYCODE_B: return Vec2i(4, 3);
        case SAPP_KEYCODE_N: return Vec2i(5, 3);
        case SAPP_KEYCODE_M: return Vec2i(6, 3);
        case SAPP_KEYCODE_COMMA: return Vec2i(7, 3);
        case SAPP_KEYCODE_PERIOD: return Vec2i(8, 3);
        default: return unboundKeyCode;
    }
}

