extern (C):

/*
    sokol_glue.h -- glue helper functions for sokol headers

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    ...optionally provide the following macros to override defaults:

    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_API_DECL      - public function declaration prefix (default: extern)
    SOKOL_API_IMPL      - public function implementation prefix (default: -)

    If sokol_glue.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    OVERVIEW
    ========
    The sokol core headers should not depend on each other, but sometimes
    it's useful to have a set of helper functions as "glue" between
    two or more sokol headers.

    This is what sokol_glue.h is for. Simply include the header after other
    sokol headers (both for the implementation and declaration), and
    depending on what headers have been included before, sokol_glue.h
    will make available "glue functions".

    PROVIDED FUNCTIONS
    ==================

    - if sokol_app.h and sokol_gfx.h is included:

        sg_context_desc sapp_sgcontext(void):

            Returns an initialized sg_context_desc function initialized
            by calling sokol_app.h functions.

    LICENSE
    =======
    zlib/libpng license

    Copyright (c) 2018 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
*/

/* extern "C" */

/* SOKOL_GLUE_INCLUDED */

/*-- IMPLEMENTATION ----------------------------------------------------------*/

/* memset */

/* SOKOL_IMPL */
