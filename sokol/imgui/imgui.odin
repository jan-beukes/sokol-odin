// machine generated, do not edit

package sokol_imgui

/*

    sokol_imgui.h -- drop-in Dear ImGui renderer/event-handler for sokol_gfx.h

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_IMGUI_IMPL

    before you include this file in *one* C or C++ file to create the
    implementation.

    NOTE that the implementation can be compiled either as C++ or as C.
    When compiled as C++, sokol_imgui.h will directly call into the
    Dear ImGui C++ API. When compiled as C, sokol_imgui.h will call
    cimgui.h functions instead.

    NOTE that the formerly separate header sokol_cimgui.h has been
    merged into sokol_imgui.h

    The following defines are used by the implementation to select the
    platform-specific embedded shader code (these are the same defines as
    used by sokol_gfx.h and sokol_app.h):

    SOKOL_GLCORE
    SOKOL_GLES3
    SOKOL_D3D11
    SOKOL_METAL
    SOKOL_WGPU

    Optionally provide the following configuration define both before including the
    the declaration and implementation:

    SOKOL_IMGUI_NO_SOKOL_APP    - don't depend on sokol_app.h (see below for details)

    Optionally provide the following macros before including the implementation
    to override defaults:

    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_IMGUI_API_DECL- public function declaration prefix (default: extern)
    SOKOL_API_DECL      - same as SOKOL_IMGUI_API_DECL
    SOKOL_API_IMPL      - public function implementation prefix (default: -)

    If sokol_imgui.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_IMGUI_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    Include the following headers before sokol_imgui.h (both before including
    the declaration and implementation):

        sokol_gfx.h
        sokol_app.h     (except SOKOL_IMGUI_NO_SOKOL_APP)

    Additionally, include the following headers before including the
    implementation:

    If the implementation is compiled as C++:
        imgui.h

    If the implementation is compiled as C:
        cimgui.h

    When compiling as C, you can override the Dear ImGui C bindings prefix
    via the define SOKOL_IMGUI_CPREFIX before including the sokol_imgui.h
    implementation:

        #define SOKOL_IMGUI_IMPL
        #define SOKOL_IMGUI_CPREFIX ImGui_
        #include "sokol_imgui.h"

    Note that the default prefix is 'ig'.


    FEATURE OVERVIEW:
    =================
    sokol_imgui.h implements the initialization, rendering and event-handling
    code for Dear ImGui (https://github.com/ocornut/imgui) on top of
    sokol_gfx.h and (optionally) sokol_app.h.

    The sokol_app.h dependency is optional and used for input event handling.
    If you only use sokol_gfx.h but not sokol_app.h in your application,
    define SOKOL_IMGUI_NO_SOKOL_APP before including the implementation
    of sokol_imgui.h, this will remove any dependency to sokol_app.h, but
    you must feed input events into Dear ImGui yourself.

    sokol_imgui.h is not thread-safe, all calls must be made from the
    same thread where sokol_gfx.h is running.

    HOWTO:
    ======

    --- To initialize sokol-imgui, call:

        simgui_setup(const simgui_desc_t* desc)

        This will initialize Dear ImGui and create sokol-gfx resources
        (two buffers for vertices and indices, a font texture and a pipeline-
        state-object).

        Use the following simgui_desc_t members to configure behaviour:

            int max_vertices
                The maximum number of vertices used for UI rendering, default is 65536.
                sokol-imgui will use this to compute the size of the vertex-
                and index-buffers allocated via sokol_gfx.h

            sg_pixel_format color_format
                The color pixel format of the render pass where the UI
                will be rendered. The default (0) matches sokol_gfx.h's
                default pass.

            sg_pixel_format depth_format
                The depth-buffer pixel format of the render pass where
                the UI will be rendered. The default (0) matches
                sokol_gfx.h's default pass depth format.

            int sample_count
                The MSAA sample-count of the render pass where the UI
                will be rendered. The default (0) matches sokol_gfx.h's
                default pass sample count.

            const char* ini_filename
                Sets this path as ImGui::GetIO().IniFilename where ImGui will store
                and load UI persistency data. By default this is 0, so that Dear ImGui
                will not preserve state between sessions (and also won't do
                any filesystem calls). Also see the ImGui functions:
                    - LoadIniSettingsFromMemory()
                    - SaveIniSettingsFromMemory()
                These functions give you explicit control over loading and saving
                UI state while using your own filesystem wrapper functions (in this
                case keep simgui_desc.ini_filename zero)

            bool no_default_font
                Set this to true if you don't want to use ImGui's default
                font. In this case you need to initialize the font
                yourself after simgui_setup() is called.

            bool disable_paste_override
                If set to true, sokol_imgui.h will not 'emulate' a Dear Imgui
                clipboard paste action on SAPP_EVENTTYPE_CLIPBOARD_PASTED event.
                This is mainly a hack/workaround to allow external workarounds
                for making copy/paste work on the web platform. In general,
                copy/paste support isn't properly fleshed out in sokol_imgui.h yet.

            bool disable_set_mouse_cursor
                If true, sokol_imgui.h will not control the mouse cursor type
                by calling sapp_set_mouse_cursor().

            bool disable_windows_resize_from_edges
                If true, windows can only be resized from the bottom right corner.
                The default is false, meaning windows can be resized from edges.

            bool write_alpha_channel
                Set this to true if you want alpha values written to the
                framebuffer. By default this behavior is disabled to prevent
                undesired behavior on platforms like the web where the canvas is
                always alpha-blended with the background.

            simgui_allocator_t allocator
                Used to override memory allocation functions. See further below
                for details.

            simgui_logger_t logger
                A user-provided logging callback. Note that without logging
                callback, sokol-imgui will be completely silent!
                See the section about ERROR REPORTING AND LOGGING below
                for more details.

    --- At the start of a frame, call:

        simgui_new_frame(&(simgui_frame_desc_t){
            .width = ...,
            .height = ...,
            .delta_time = ...,
            .dpi_scale = ...
        });

        'width' and 'height' are the dimensions of the rendering surface,
        passed to ImGui::GetIO().DisplaySize.

        'delta_time' is the frame duration passed to ImGui::GetIO().DeltaTime.

        'dpi_scale' is the current DPI scale factor, if this is left zero-initialized,
        1.0f will be used instead. Typical values for dpi_scale are >= 1.0f.

        For example, if you're using sokol_app.h and render to the default framebuffer:

        simgui_new_frame(&(simgui_frame_desc_t){
            .width = sapp_width(),
            .height = sapp_height(),
            .delta_time = sapp_frame_duration(),
            .dpi_scale = sapp_dpi_scale()
        });

    --- at the end of the frame, before the sg_end_pass() where you
        want to render the UI, call:

        simgui_render()

        This will first call ImGui::Render(), and then render ImGui's draw list
        through sokol_gfx.h

    --- if you're using sokol_app.h, from inside the sokol_app.h event callback,
        call:

        bool simgui_handle_event(const sapp_event* ev);

        The return value is the value of ImGui::GetIO().WantCaptureKeyboard,
        if this is true, you might want to skip keyboard input handling
        in your own event handler.

        If you want to use the ImGui functions for checking if a key is pressed
        (e.g. ImGui::IsKeyPressed()) the following helper function to map
        an sapp_keycode to an ImGuiKey value may be useful:

        int simgui_map_keycode(sapp_keycode c);

        Note that simgui_map_keycode() can be called outside simgui_setup()/simgui_shutdown().

    --- finally, on application shutdown, call

        simgui_shutdown()


    ON USER-PROVIDED IMAGES AND SAMPLERS
    ====================================
    To render your own images via ImGui::Image() you need to create a Dear ImGui
    compatible texture handle (ImTextureID) from a sokol-gfx image handle
    or optionally an image handle and a compatible sampler handle.

    To create a ImTextureID from a sokol-gfx image handle, call:

        sg_image img= ...;
        ImTextureID imtex_id = simgui_imtextureid(img);

    Since no sampler is provided, such a texture handle will use a default
    sampler with nearest filtering and clamp-to-edge.

    If you need to render with a different sampler, do this instead:

        sg_image img = ...;
        sg_sampler smp = ...;
        ImTextureID imtex_id = simgui_imtextureid_with_sampler(img, smp);

    You don't need to 'release' the ImTextureID handle, the ImTextureID
    bits is simply a combination of the sg_image and sg_sampler bits.

    Once you have constructed an ImTextureID handle via simgui_imtextureid()
    or simgui_imtextureid_with_sampler(), it used in the ImGui::Image()
    call like this:

        ImGui::Image(imtex_id, ...);

    To extract the sg_image and sg_sampler handle from an ImTextureID:

        sg_image img = simgui_image_from_imtextureid(imtex_id);
        sg_sampler smp = simgui_sampler_from_imtextureid(imtex_id);


    MEMORY ALLOCATION OVERRIDE
    ==========================
    You can override the memory allocation functions at initialization time
    like this:

        void* my_alloc(size_t size, void* user_data) {
            return malloc(size);
        }

        void my_free(void* ptr, void* user_data) {
            free(ptr);
        }

        ...
            simgui_setup(&(simgui_desc_t){
                // ...
                .allocator = {
                    .alloc_fn = my_alloc,
                    .free_fn = my_free,
                    .user_data = ...;
                }
            });
        ...

    If no overrides are provided, malloc and free will be used.

    This only affects memory allocation calls done by sokol_imgui.h
    itself though, not any allocations in Dear ImGui.


    ERROR REPORTING AND LOGGING
    ===========================
    To get any logging information at all you need to provide a logging callback in the setup call
    the easiest way is to use sokol_log.h:

        #include "sokol_log.h"

        simgui_setup(&(simgui_desc_t){
            .logger.func = slog_func
        });

    To override logging with your own callback, first write a logging function like this:

        void my_log(const char* tag,                // e.g. 'simgui'
                    uint32_t log_level,             // 0=panic, 1=error, 2=warn, 3=info
                    uint32_t log_item_id,           // SIMGUI_LOGITEM_*
                    const char* message_or_null,    // a message string, may be nullptr in release mode
                    uint32_t line_nr,               // line number in sokol_imgui.h
                    const char* filename_or_null,   // source filename, may be nullptr in release mode
                    void* user_data)
        {
            ...
        }

    ...and then setup sokol-imgui like this:

        simgui_setup(&(simgui_desc_t){
            .logger = {
                .func = my_log,
                .user_data = my_user_data,
            }
        });

    The provided logging function must be reentrant (e.g. be callable from
    different threads).

    If you don't want to provide your own custom logger it is highly recommended to use
    the standard logger in sokol_log.h instead, otherwise you won't see any warnings or
    errors.


    IMGUI EVENT HANDLING
    ====================
    You can call these functions from your platform's events to handle ImGui events
    when SOKOL_IMGUI_NO_SOKOL_APP is defined.

    E.g. mouse position events can be dispatched like this:

        simgui_add_mouse_pos_event(100, 200);

    For adding key events, you're responsible to map your own key codes to ImGuiKey
    values and pass those as int:

        simgui_add_key_event(imgui_key, true);

    Take note that modifiers (shift, ctrl, etc.) must be updated manually.

    If sokol_app is being used, ImGui events are handled for you.


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
import sg "../gfx"
import sapp "../app"

import "core:c"

_ :: c

SOKOL_DEBUG :: #config(SOKOL_DEBUG, ODIN_DEBUG)

DEBUG :: #config(SOKOL_IMGUI_DEBUG, SOKOL_DEBUG)
USE_GL :: #config(SOKOL_USE_GL, false)
USE_DLL :: #config(SOKOL_DLL, false)

when ODIN_OS == .Windows {
    when USE_DLL {
        when USE_GL {
            when DEBUG { foreign import sokol_imgui_clib { "../sokol_dll_windows_x64_gl_debug.lib" } }
            else       { foreign import sokol_imgui_clib { "../sokol_dll_windows_x64_gl_release.lib" } }
        } else {
            when DEBUG { foreign import sokol_imgui_clib { "../sokol_dll_windows_x64_d3d11_debug.lib" } }
            else       { foreign import sokol_imgui_clib { "../sokol_dll_windows_x64_d3d11_release.lib" } }
        }
    } else {
        when USE_GL {
            when DEBUG { foreign import sokol_imgui_clib { "sokol_imgui_windows_x64_gl_debug.lib" } }
            else       { foreign import sokol_imgui_clib { "sokol_imgui_windows_x64_gl_release.lib" } }
        } else {
            when DEBUG { foreign import sokol_imgui_clib { "sokol_imgui_windows_x64_d3d11_debug.lib" } }
            else       { foreign import sokol_imgui_clib { "sokol_imgui_windows_x64_d3d11_release.lib" } }
        }
    }
} else when ODIN_OS == .Darwin {
    when USE_DLL {
             when  USE_GL && ODIN_ARCH == .arm64 &&  DEBUG { foreign import sokol_imgui_clib { "../dylib/sokol_dylib_macos_arm64_gl_debug.dylib" } }
        else when  USE_GL && ODIN_ARCH == .arm64 && !DEBUG { foreign import sokol_imgui_clib { "../dylib/sokol_dylib_macos_arm64_gl_release.dylib" } }
        else when  USE_GL && ODIN_ARCH == .amd64 &&  DEBUG { foreign import sokol_imgui_clib { "../dylib/sokol_dylib_macos_x64_gl_debug.dylib" } }
        else when  USE_GL && ODIN_ARCH == .amd64 && !DEBUG { foreign import sokol_imgui_clib { "../dylib/sokol_dylib_macos_x64_gl_release.dylib" } }
        else when !USE_GL && ODIN_ARCH == .arm64 &&  DEBUG { foreign import sokol_imgui_clib { "../dylib/sokol_dylib_macos_arm64_metal_debug.dylib" } }
        else when !USE_GL && ODIN_ARCH == .arm64 && !DEBUG { foreign import sokol_imgui_clib { "../dylib/sokol_dylib_macos_arm64_metal_release.dylib" } }
        else when !USE_GL && ODIN_ARCH == .amd64 &&  DEBUG { foreign import sokol_imgui_clib { "../dylib/sokol_dylib_macos_x64_metal_debug.dylib" } }
        else when !USE_GL && ODIN_ARCH == .amd64 && !DEBUG { foreign import sokol_imgui_clib { "../dylib/sokol_dylib_macos_x64_metal_release.dylib" } }
    } else {
        when USE_GL {
            when ODIN_ARCH == .arm64 {
                when DEBUG { foreign import sokol_imgui_clib { "sokol_imgui_macos_arm64_gl_debug.a" } }
                else       { foreign import sokol_imgui_clib { "sokol_imgui_macos_arm64_gl_release.a" } }
            } else {
                when DEBUG { foreign import sokol_imgui_clib { "sokol_imgui_macos_x64_gl_debug.a" } }
                else       { foreign import sokol_imgui_clib { "sokol_imgui_macos_x64_gl_release.a" } }
            }
        } else {
            when ODIN_ARCH == .arm64 {
                when DEBUG { foreign import sokol_imgui_clib { "sokol_imgui_macos_arm64_metal_debug.a" } }
                else       { foreign import sokol_imgui_clib { "sokol_imgui_macos_arm64_metal_release.a" } }
            } else {
                when DEBUG { foreign import sokol_imgui_clib { "sokol_imgui_macos_x64_metal_debug.a" } }
                else       { foreign import sokol_imgui_clib { "sokol_imgui_macos_x64_metal_release.a" } }
            }
        }
    }
} else when ODIN_OS == .Linux {
    when USE_DLL {
        when DEBUG { foreign import sokol_imgui_clib { "sokol_imgui_linux_x64_gl_debug.so" } }
        else       { foreign import sokol_imgui_clib { "sokol_imgui_linux_x64_gl_release.so" } }
    } else {
        when DEBUG { foreign import sokol_imgui_clib { "sokol_imgui_linux_x64_gl_debug.a" } }
        else       { foreign import sokol_imgui_clib { "sokol_imgui_linux_x64_gl_release.a" } }
    }
} else when ODIN_ARCH == .wasm32 || ODIN_ARCH == .wasm64p32 {
    // Feed sokol_imgui_wasm_gl_debug.a or sokol_imgui_wasm_gl_release.a into emscripten compiler.
    foreign import sokol_imgui_clib { "env.o" }
} else {
    #panic("This OS is currently not supported")
}

@(default_calling_convention="c", link_prefix="simgui_")
foreign sokol_imgui_clib {
    setup :: proc(#by_ptr desc: Desc)  ---
    new_frame :: proc(#by_ptr desc: Frame_Desc)  ---
    render :: proc()  ---
    imtextureid :: proc(img: sg.Image) -> u64 ---
    imtextureid_with_sampler :: proc(img: sg.Image, smp: sg.Sampler) -> u64 ---
    image_from_imtextureid :: proc(imtex_id: u64) -> sg.Image ---
    sampler_from_imtextureid :: proc(imtex_id: u64) -> sg.Sampler ---
    add_focus_event :: proc(focus: bool)  ---
    add_mouse_pos_event :: proc(x: f32, y: f32)  ---
    add_touch_pos_event :: proc(x: f32, y: f32)  ---
    add_mouse_button_event :: proc(#any_int mouse_button: c.int, down: bool)  ---
    add_mouse_wheel_event :: proc(wheel_x: f32, wheel_y: f32)  ---
    add_key_event :: proc(#any_int imgui_key: c.int, down: bool)  ---
    add_input_character :: proc(c: u32)  ---
    add_input_characters_utf8 :: proc(c: cstring)  ---
    add_touch_button_event :: proc(#any_int mouse_button: c.int, down: bool)  ---
    handle_event :: proc(#by_ptr ev: sapp.Event) -> bool ---
    map_keycode :: proc(keycode: sapp.Keycode) -> c.int ---
    shutdown :: proc()  ---
    create_fonts_texture :: proc(#by_ptr desc: Font_Tex_Desc)  ---
    destroy_fonts_texture :: proc()  ---
}

Log_Item :: enum i32 {
    OK,
    MALLOC_FAILED,
}

/*
    simgui_allocator_t

    Used in simgui_desc_t to provide custom memory-alloc and -free functions
    to sokol_imgui.h. If memory management should be overridden, both the
    alloc_fn and free_fn function must be provided (e.g. it's not valid to
    override one function but not the other).
*/
Allocator :: struct {
    alloc_fn : proc "c" (a0: c.size_t, a1: rawptr) -> rawptr,
    free_fn : proc "c" (a0: rawptr, a1: rawptr),
    user_data : rawptr,
}

/*
    simgui_logger

    Used in simgui_desc_t to provide a logging function. Please be aware
    that without logging function, sokol-imgui will be completely
    silent, e.g. it will not report errors, warnings and
    validation layer messages. For maximum error verbosity,
    compile in debug mode (e.g. NDEBUG *not* defined) and install
    a logger (for instance the standard logging function from sokol_log.h).
*/
Logger :: struct {
    func : proc "c" (a0: cstring, a1: u32, a2: u32, a3: cstring, a4: u32, a5: cstring, a6: rawptr),
    user_data : rawptr,
}

Desc :: struct {
    max_vertices : c.int,
    color_format : sg.Pixel_Format,
    depth_format : sg.Pixel_Format,
    sample_count : c.int,
    ini_filename : cstring,
    no_default_font : bool,
    disable_paste_override : bool,
    disable_set_mouse_cursor : bool,
    disable_windows_resize_from_edges : bool,
    write_alpha_channel : bool,
    allocator : Allocator,
    logger : Logger,
}

Frame_Desc :: struct {
    width : c.int,
    height : c.int,
    delta_time : f64,
    dpi_scale : f32,
}

Font_Tex_Desc :: struct {
    min_filter : sg.Filter,
    mag_filter : sg.Filter,
}

