import glfw;
import sokol_gfx;

import constants;
import game;

/// Game objects holder
__gshared Game!(maxObjects) GAME = {};

/// Pass action to clear with color
__gshared sg_pass_action default_pass_action = {
    colors: [{
        action: SG_ACTION_CLEAR,
        val: clearColor,
    }],
};

/// GLFW Window handler
__gshared GLFWwindow *window;
