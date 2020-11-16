extern (C):

/*
    sokol_audio.h -- cross-platform audio-streaming API

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Optionally provide the following defines with your own implementations:

    SOKOL_DUMMY_BACKEND - use a dummy backend
    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_LOG(msg)      - your own logging function (default: puts(msg))
    SOKOL_MALLOC(s)     - your own malloc() implementation (default: malloc(s))
    SOKOL_FREE(p)       - your own free() implementation (default: free(p))
    SOKOL_API_DECL      - public function declaration prefix (default: extern)
    SOKOL_API_IMPL      - public function implementation prefix (default: -)

    SAUDIO_RING_MAX_SLOTS   - max number of slots in the push-audio ring buffer (default 1024)

    If sokol_audio.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    FEATURE OVERVIEW
    ================
    You provide a mono- or stereo-stream of 32-bit float samples, which
    Sokol Audio feeds into platform-specific audio backends:

    - Windows: WASAPI
    - Linux: ALSA (link with asound)
    - macOS/iOS: CoreAudio (link with AudioToolbox)
    - emscripten: WebAudio with ScriptProcessorNode
    - Android: OpenSLES (link with OpenSLES)

    Sokol Audio will not do any buffer mixing or volume control, if you have
    multiple independent input streams of sample data you need to perform the
    mixing yourself before forwarding the data to Sokol Audio.

    There are two mutually exclusive ways to provide the sample data:

    1. Callback model: You provide a callback function, which will be called
       when Sokol Audio needs new samples. On all platforms except emscripten,
       this function is called from a separate thread.
    2. Push model: Your code pushes small blocks of sample data from your
       main loop or a thread you created. The pushed data is stored in
       a ring buffer where it is pulled by the backend code when
       needed.

    The callback model is preferred because it is the most direct way to
    feed sample data into the audio backends and also has less moving parts
    (there is no ring buffer between your code and the audio backend).

    Sometimes it is not possible to generate the audio stream directly in a
    callback function running in a separate thread, for such cases Sokol Audio
    provides the push-model as a convenience.

    SOKOL AUDIO, SOLOUD AND MINIAUDIO
    =================================
    The WASAPI, ALSA, OpenSLES and CoreAudio backend code has been taken from the
    SoLoud library (with some modifications, so any bugs in there are most
    likely my fault). If you need a more fully-featured audio solution, check
    out SoLoud, it's excellent:

        https://github.com/jarikomppa/soloud

    Another alternative which feature-wise is somewhere inbetween SoLoud and
    sokol-audio might be MiniAudio:

        https://github.com/mackron/miniaudio

    GLOSSARY
    ========
    - stream buffer:
        The internal audio data buffer, usually provided by the backend API. The
        size of the stream buffer defines the base latency, smaller buffers have
        lower latency but may cause audio glitches. Bigger buffers reduce or
        eliminate glitches, but have a higher base latency.

    - stream callback:
        Optional callback function which is called by Sokol Audio when it
        needs new samples. On Windows, macOS/iOS and Linux, this is called in
        a separate thread, on WebAudio, this is called per-frame in the
        browser thread.

    - channel:
        A discrete track of audio data, currently 1-channel (mono) and
        2-channel (stereo) is supported and tested.

    - sample:
        The magnitude of an audio signal on one channel at a given time. In
        Sokol Audio, samples are 32-bit float numbers in the range -1.0 to
        +1.0.

    - frame:
        The tightly packed set of samples for all channels at a given time.
        For mono 1 frame is 1 sample. For stereo, 1 frame is 2 samples.

    - packet:
        In Sokol Audio, a small chunk of audio data that is moved from the
        main thread to the audio streaming thread in order to decouple the
        rate at which the main thread provides new audio data, and the
        streaming thread consuming audio data.

    WORKING WITH SOKOL AUDIO
    ========================
    First call saudio_setup() with your preferred audio playback options.
    In most cases you can stick with the default values, these provide
    a good balance between low-latency and glitch-free playback
    on all audio backends.

    If you want to use the callback-model, you need to provide a stream
    callback function either in saudio_desc.stream_cb or saudio_desc.stream_userdata_cb,
    otherwise keep both function pointers zero-initialized.

    Use push model and default playback parameters:

        saudio_setup(&(saudio_desc){0});

    Use stream callback model and default playback parameters:

        saudio_setup(&(saudio_desc){
            .stream_cb = my_stream_callback
        });

    The standard stream callback doesn't have a user data argument, if you want
    that, use the alternative stream_userdata_cb and also set the user_data pointer:

        saudio_setup(&(saudio_desc){
            .stream_userdata_cb = my_stream_callback,
            .user_data = &my_data
        });

    The following playback parameters can be provided through the
    saudio_desc struct:

    General parameters (both for stream-callback and push-model):

        int sample_rate     -- the sample rate in Hz, default: 44100
        int num_channels    -- number of channels, default: 1 (mono)
        int buffer_frames   -- number of frames in streaming buffer, default: 2048

    The stream callback prototype (either with or without userdata):

        void (*stream_cb)(float* buffer, int num_frames, int num_channels)
        void (*stream_userdata_cb)(float* buffer, int num_frames, int num_channels, void* user_data)
            Function pointer to the user-provide stream callback.

    Push-model parameters:

        int packet_frames   -- number of frames in a packet, default: 128
        int num_packets     -- number of packets in ring buffer, default: 64

    The sample_rate and num_channels parameters are only hints for the audio
    backend, it isn't guaranteed that those are the values used for actual
    playback.

    To get the actual parameters, call the following functions after
    saudio_setup():

        int saudio_sample_rate(void)
        int saudio_channels(void);

    It's unlikely that the number of channels will be different than requested,
    but a different sample rate isn't uncommon.

    (NOTE: there's an yet unsolved issue when an audio backend might switch
    to a different sample rate when switching output devices, for instance
    plugging in a bluetooth headset, this case is currently not handled in
    Sokol Audio).

    You can check if audio initialization was successful with
    saudio_isvalid(). If backend initialization failed for some reason
    (for instance when there's no audio device in the machine), this
    will return false. Not checking for success won't do any harm, all
    Sokol Audio function will silently fail when called after initialization
    has failed, so apart from missing audio output, nothing bad will happen.

    Before your application exits, you should call

        saudio_shutdown();

    This stops the audio thread (on Linux, Windows and macOS/iOS) and
    properly shuts down the audio backend.

    THE STREAM CALLBACK MODEL
    =========================
    To use Sokol Audio in stream-callback-mode, provide a callback function
    like this in the saudio_desc struct when calling saudio_setup():

    void stream_cb(float* buffer, int num_frames, int num_channels) {
        ...
    }

    Or the alternative version with a user-data argument:

    void stream_userdata_cb(float* buffer, int num_frames, int num_channels, void* user_data) {
        my_data_t* my_data = (my_data_t*) user_data;
        ...
    }

    The job of the callback function is to fill the *buffer* with 32-bit
    float sample values.

    To output silence, fill the buffer with zeros:

        void stream_cb(float* buffer, int num_frames, int num_channels) {
            const int num_samples = num_frames * num_channels;
            for (int i = 0; i < num_samples; i++) {
                buffer[i] = 0.0f;
            }
        }

    For stereo output (num_channels == 2), the samples for the left
    and right channel are interleaved:

        void stream_cb(float* buffer, int num_frames, int num_channels) {
            assert(2 == num_channels);
            for (int i = 0; i < num_frames; i++) {
                buffer[2*i + 0] = ...;  // left channel
                buffer[2*i + 1] = ...;  // right channel
            }
        }

    Please keep in mind that the stream callback function is running in a
    separate thread, if you need to share data with the main thread you need
    to take care yourself to make the access to the shared data thread-safe!

    THE PUSH MODEL
    ==============
    To use the push-model for providing audio data, simply don't set (keep
    zero-initialized) the stream_cb field in the saudio_desc struct when
    calling saudio_setup().

    To provide sample data with the push model, call the saudio_push()
    function at regular intervals (for instance once per frame). You can
    call the saudio_expect() function to ask Sokol Audio how much room is
    in the ring buffer, but if you provide a continuous stream of data
    at the right sample rate, saudio_expect() isn't required (it's a simple
    way to sync/throttle your sample generation code with the playback
    rate though).

    With saudio_push() you may need to maintain your own intermediate sample
    buffer, since pushing individual sample values isn't very efficient.
    The following example is from the MOD player sample in
    sokol-samples (https://github.com/floooh/sokol-samples):

        const int num_frames = saudio_expect();
        if (num_frames > 0) {
            const int num_samples = num_frames * saudio_channels();
            read_samples(flt_buf, num_samples);
            saudio_push(flt_buf, num_frames);
        }

    Another option is to ignore saudio_expect(), and just push samples as they
    are generated in small batches. In this case you *need* to generate the
    samples at the right sample rate:

    The following example is taken from the Tiny Emulators project
    (https://github.com/floooh/chips-test), this is for mono playback,
    so (num_samples == num_frames):

        // tick the sound generator
        if (ay38910_tick(&sys->psg)) {
            // new sample is ready
            sys->sample_buffer[sys->sample_pos++] = sys->psg.sample;
            if (sys->sample_pos == sys->num_samples) {
                // new sample packet is ready
                saudio_push(sys->sample_buffer, sys->num_samples);
                sys->sample_pos = 0;
            }
        }

    THE WEBAUDIO BACKEND
    ====================
    The WebAudio backend is currently using a ScriptProcessorNode callback to
    feed the sample data into WebAudio. ScriptProcessorNode has been
    deprecated for a while because it is running from the main thread, with
    the default initialization parameters it works 'pretty well' though.
    Ultimately Sokol Audio will use Audio Worklets, but this requires a few
    more things to fall into place (Audio Worklets implemented everywhere,
    SharedArrayBuffers enabled again, and I need to figure out a 'low-cost'
    solution in terms of implementation effort, since Audio Worklets are
    a lot more complex than ScriptProcessorNode if the audio data needs to come
    from the main thread).

    The WebAudio backend is automatically selected when compiling for
    emscripten (__EMSCRIPTEN__ define exists).

    https://developers.google.com/web/updates/2017/12/audio-worklet
    https://developers.google.com/web/updates/2018/06/audio-worklet-design-pattern

    "Blob URLs": https://www.html5rocks.com/en/tutorials/workers/basics/

    THE COREAUDIO BACKEND
    =====================
    The CoreAudio backend is selected on macOS and iOS (__APPLE__ is defined).
    Since the CoreAudio API is implemented in C (not Objective-C) the
    implementation part of Sokol Audio can be included into a C source file.

    For thread synchronisation, the CoreAudio backend will use the
    pthread_mutex_* functions.

    The incoming floating point samples will be directly forwarded to
    CoreAudio without further conversion.

    macOS and iOS applications that use Sokol Audio need to link with
    the AudioToolbox framework.

    THE WASAPI BACKEND
    ==================
    The WASAPI backend is automatically selected when compiling on Windows
    (_WIN32 is defined).

    For thread synchronisation a Win32 critical section is used.

    WASAPI may use a different size for its own streaming buffer then requested,
    so the base latency may be slightly bigger. The current backend implementation
    converts the incoming floating point sample values to signed 16-bit
    integers.

    The required Windows system DLLs are linked with #pragma comment(lib, ...),
    so you shouldn't need to add additional linker libs in the build process
    (otherwise this is a bug which should be fixed in sokol_audio.h).

    THE ALSA BACKEND
    ================
    The ALSA backend is automatically selected when compiling on Linux
    ('linux' is defined).

    For thread synchronisation, the pthread_mutex_* functions are used.

    Samples are directly forwarded to ALSA in 32-bit float format, no
    further conversion is taking place.

    You need to link with the 'asound' library, and the <alsa/asoundlib.h>
    header must be present (usually both are installed with some sort
    of ALSA development package).

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
enum SOKOL_AUDIO_INCLUDED = 1;

struct saudio_desc
{
    int sample_rate; /* requested sample rate */
    int num_channels; /* number of channels, default: 1 (mono) */
    int buffer_frames; /* number of frames in streaming buffer */
    int packet_frames; /* number of frames in a packet */
    int num_packets; /* number of packets in packet queue */
    void function (float* buffer, int num_frames, int num_channels) stream_cb; /* optional streaming callback (no user data) */
    void function (float* buffer, int num_frames, int num_channels, void* user_data) stream_userdata_cb; /*... and with user data */
    void* user_data; /* optional user data argument for stream_userdata_cb */
}

/* setup sokol-audio */
void saudio_setup (const(saudio_desc)* desc);
/* shutdown sokol-audio */
void saudio_shutdown ();
/* true after setup if audio backend was successfully initialized */
bool saudio_isvalid ();
/* return the saudio_desc.user_data pointer */
void* saudio_userdata ();
/* return a copy of the original saudio_desc struct */
saudio_desc saudio_query_desc ();
/* actual sample rate */
int saudio_sample_rate ();
/* return actual backend buffer size in number of frames */
int saudio_buffer_frames ();
/* actual number of channels */
int saudio_channels ();
/* get current number of frames to fill packet queue */
int saudio_expect ();
/* push sample frames from main thread, returns number of frames actually pushed */
int saudio_push (const(float)* frames, int num_frames);

/* extern "C" */

/* reference-based equivalents for c++ */

// SOKOL_AUDIO_INCLUDED

/*=== IMPLEMENTATION =========================================================*/

/* memset, memcpy */

// No threads needed for SOKOL_DUMMY_BACKEND

// No audio API needed for SOKOL_DUMMY_BACKEND

/* fix for Visual Studio 2015 SDKs */

/* unreferenced local function has been removed */

/*=== MUTEX WRAPPER DECLARATIONS =============================================*/

/*=== DUMMY BACKEND DECLARATIONS =============================================*/

/*=== COREAUDIO BACKEND DECLARATIONS =========================================*/

/*=== ALSA BACKEND DECLARATIONS ==============================================*/

/*=== OpenSLES BACKEND DECLARATIONS ==============================================*/

/*=== WASAPI BACKEND DECLARATIONS ============================================*/

/*=== WEBAUDIO BACKEND DECLARATIONS ==========================================*/

/*=== DUMMY BACKEND DECLARATIONS =============================================*/

/*=== GENERAL DECLARATIONS ===================================================*/

/* a ringbuffer structure */

/* next slot to write to */
/* next slot to read from */
/* number of slots in queue */

/* a packet FIFO structure */

/* size of a single packets in bytes(!) */
/* number of packet in fifo */
/* packet memory chunk base pointer (dynamically allocated) */
/* current write-packet */
/* current byte-offset into current write packet */
/* mutex for thread-safe access */
/* buffers with data, ready to be streamed */
/* empty buffers, ready to be pushed to */

/* sokol-audio state */

/* sample rate */
/* number of frames in streaming buffer */
/* filled by backend */
/* number of frames in a packet */
/* number of packets in packet queue */
/* actual number of channels */

/*=== MUTEX IMPLEMENTATION ===================================================*/

/*=== RING-BUFFER QUEUE IMPLEMENTATION =======================================*/

/* one slot reserved to detect 'full' vs 'empty' */

/*---  a packet fifo for queueing audio data from main thread ----------------*/

/* this must be called before initializing both the backend and the fifo itself! */

/* NOTE: there's a chicken-egg situation during the init phase where the
    streaming thread must be started before the fifo is actually initialized,
    thus the fifo init must already be protected from access by the fifo_read() func.
*/

/* write new data to the write queue, this is called from main thread */

/* returns the number of bytes written, this will be smaller then requested
    if the write queue runs full
*/

/* need to grab a new packet? */

/* append data to current write packet */

/* early out if we're starving */

/* if write packet is full, push to read queue */

/* read queued data, this is called form the stream callback (maybe separate thread) */

/* NOTE: fifo_read might be called before the fifo is properly initialized */

/* either pull a full buffer worth of data, or nothing */

/*=== DUMMY BACKEND IMPLEMENTATION ===========================================*/

/*=== COREAUDIO BACKEND IMPLEMENTATION =======================================*/

/* NOTE: the buffer data callback is called on a separate thread! */

/* not enough read data available, fill the entire buffer with silence */

/* create an audio queue with fp32 samples */

/* create 2 audio buffers */

/* init or modify actual playback parameters */

/* ...and start playback */

/*=== ALSA BACKEND IMPLEMENTATION ============================================*/

/* the streaming callback runs in a separate thread */

/* snd_pcm_writei() will be blocking until it needs data */

/* underrun occurred */

/* fill the streaming buffer with new data */

/* not enough read data available, fill the entire buffer with silence */

/* configuration works by restricting the 'configuration space' step
   by step, we require all parameters except the sample rate to
   match perfectly
*/

/* let ALSA pick a nearby sampling rate */

/* read back actual sample rate and channels */

/* allocate the streaming buffer */

/* create the buffer-streaming start thread */

/*=== WASAPI BACKEND IMPLEMENTATION ==========================================*/

/* Minimal implementation of an IActivateAudioInterfaceCompletionHandler COM object in plain C.
   Meant to be a static singleton (always one reference when add/remove reference)
   and implements IUnknown and IActivateAudioInterfaceCompletionHandler when queryinterface'd

   Do not know why but IActivateAudioInterfaceCompletionHandler's GUID is not the one system queries for,
   so I'm advertising the one actually requested.
*/

/* fill intermediate buffer with new data and reset buffer_pos */

/* not enough read data available, fill the entire buffer with silence */

/* convert float samples to int16_t, refill float buffer if needed */

/* UWP Threads are CoInitialized by default with a different threading model, and this call fails
See https://github.com/Microsoft/cppwinrt/issues/6#issuecomment-253930637 */

/* CoInitializeEx could have been called elsewhere already, in which
    case the function returns with S_FALSE (thus it doesn't make much
    sense to check the result)
*/

/* static instance of the fake COM object */

/* allocate an intermediate buffer for sample format conversion */

/* create streaming thread */

/*=== EMSCRIPTEN BACKEND IMPLEMENTATION ======================================*/

/* not enough read data available, fill the entire buffer with silence */

/* extern "C" */

/* setup the WebAudio context and attach a ScriptProcessorNode */

// in some browsers, WebAudio needs to be activated on a user action

/* shutdown the WebAudioContext and ScriptProcessorNode */

/* get the actual sample rate back from the WebAudio context */

/* get the actual buffer size in number of frames */

/*=== ANDROID BACKEND IMPLEMENTATION ======================================*/

/* fill intermediate buffer with new data and reset buffer_pos */

/* not enough read data available, fill the entire buffer with silence */

/* get next output buffer, advance, next buffer. */

/* queue this buffer */

/* fill the next buffer */

/* Create engine */

/* Create output mix. */

/* android buffer queue */

/* data format */

/* Output mix. */

/* setup player */

/* begin */

/* create the buffer-streaming start thread */

/* extern "C" */

/* dummy backend */

/*=== PUBLIC API FUNCTIONS ===================================================*/

/* the backend might not support the requested exact buffer size,
   make sure the actual buffer size is still a multiple of
   the requested packet size
*/

/* SOKOL_IMPL */
