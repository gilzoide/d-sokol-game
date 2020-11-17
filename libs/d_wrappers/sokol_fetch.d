extern (C):

/*
    sokol_fetch.h -- asynchronous data loading/streaming

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Optionally provide the following defines with your own implementations:

    SOKOL_ASSERT(c)             - your own assert macro (default: assert(c))
    SOKOL_MALLOC(s)             - your own malloc function (default: malloc(s))
    SOKOL_FREE(p)               - your own free function (default: free(p))
    SOKOL_LOG(msg)              - your own logging function (default: puts(msg))
    SOKOL_UNREACHABLE()         - a guard macro for unreachable code (default: assert(false))
    SOKOL_API_DECL              - public function declaration prefix (default: extern)
    SOKOL_API_IMPL              - public function implementation prefix (default: -)
    SFETCH_MAX_PATH             - max length of UTF-8 filesystem path / URL (default: 1024 bytes)
    SFETCH_MAX_USERDATA_UINT64  - max size of embedded userdata in number of uint64_t, userdata
                                  will be copied into an 8-byte aligned memory region associated
                                  with each in-flight request, default value is 16 (== 128 bytes)
    SFETCH_MAX_CHANNELS         - max number of IO channels (default is 16, also see sfetch_desc_t.num_channels)

    If sokol_fetch.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    NOTE: The following documentation talks a lot about "IO threads". Actual
    threads are only used on platforms where threads are available. The web
    version (emscripten/wasm) doesn't use POSIX-style threads, but instead
    asynchronous Javascript calls chained together by callbacks. The actual
    source code differences between the two approaches have been kept to
    a minimum though.

    FEATURE OVERVIEW
    ================

    - Asynchronously load complete files, or stream files incrementally via
      HTTP (on web platform), or the local file system (on native platforms)

    - Request / response-callback model, user code sends a request
      to initiate a file-load, sokol_fetch.h calls the response callback
      on the same thread when data is ready or user-code needs
      to respond otherwise

    - Not limited to the main-thread or a single thread: A sokol-fetch
      "context" can live on any thread, and multiple contexts
      can operate side-by-side on different threads.

    - Memory management for data buffers is under full control of user code.
      sokol_fetch.h won't allocate memory after it has been setup.

    - Automatic rate-limiting guarantees that only a maximum number of
      requests is processed at any one time, allowing a zero-allocation
      model, where all data is streamed into fixed-size, pre-allocated
      buffers.

    - Active Requests can be paused, continued and cancelled from anywhere
      in the user-thread which sent this request.


    TL;DR EXAMPLE CODE
    ==================
    This is the most-simple example code to load a single data file with a
    known maximum size:

    (1) initialize sokol-fetch with default parameters (but NOTE that the
        default setup parameters provide a safe-but-slow "serialized"
        operation):

        sfetch_setup(&(sfetch_desc_t){ 0 });

    (2) send a fetch-request to load a file from the current directory
        into a buffer big enough to hold the entire file content:

        static uint8_t buf[MAX_FILE_SIZE];

        sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = response_callback,
            .buffer_ptr = buf,
            .buffer_size = sizeof(buf)
        });

    (3) write a 'response-callback' function, this will be called whenever
        the user-code must respond to state changes of the request
        (most importantly when data has been loaded):

        void response_callback(const sfetch_response_t* response) {
            if (response->fetched) {
                // data has been loaded, and is available via
                // 'buffer_ptr' and 'fetched_size':
                const void* data = response->buffer_ptr;
                uint64_t num_bytes = response->fetched_size;
            }
            if (response->finished) {
                // the 'finished'-flag is the catch-all flag for when the request
                // is finished, no matter if loading was successful or failed,
                // so any cleanup-work should happen here...
                ...
                if (response->failed) {
                    // 'failed' is true in (addition to 'finished') if something
                    // went wrong (file doesn't exist, or less bytes could be
                    // read from the file than expected)
                }
            }
        }

    (4) finally, call sfetch_shutdown() at the end of the application:

        sfetch_shutdown()

    There's many other loading-scenarios, for instance one doesn't have to
    provide a buffer upfront, this can also happen in the response callback.

    Or it's possible to stream huge files into small fixed-size buffer,
    complete with pausing and continuing the download.

    It's also possible to improve the 'pipeline throughput' by fetching
    multiple files in parallel, but at the same time limit the maximum
    number of requests that can be 'in-flight'.

    For how this all works, please read the following documentation sections :)


    API DOCUMENTATION
    =================

    void sfetch_setup(const sfetch_desc_t* desc)
    --------------------------------------------
    First call sfetch_setup(const sfetch_desc_t*) on any thread before calling
    any other sokol-fetch functions on the same thread.

    sfetch_setup() takes a pointer to an sfetch_desc_t struct with setup
    parameters. Parameters which should use their default values must
    be zero-initialized:

        - max_requests (uint32_t):
            The maximum number of requests that can be alive at any time, the
            default is 128.

        - num_channels (uint32_t):
            The number of "IO channels" used to parallelize and prioritize
            requests, the default is 1.

        - num_lanes (uint32_t):
            The number of "lanes" on a single channel. Each request which is
            currently 'inflight' on a channel occupies one lane until the
            request is finished. This is used for automatic rate-limiting
            (search below for CHANNELS AND LANES for more details). The
            default number of lanes is 1.

    For example, to setup sokol-fetch for max 1024 active requests, 4 channels,
    and 8 lanes per channel in C99:

        sfetch_setup(&(sfetch_desc_t){
            .max_requests = 1024,
            .num_channels = 4,
            .num_lanes = 8
        });

    sfetch_setup() is the only place where sokol-fetch will allocate memory.

    NOTE that the default setup parameters of 1 channel and 1 lane per channel
    has a very poor 'pipeline throughput' since this essentially serializes
    IO requests (a new request will only be processed when the last one has
    finished), and since each request needs at least one roundtrip between
    the user- and IO-thread the throughput will be at most one request per
    frame. Search for LATENCY AND THROUGHPUT below for more information on
    how to increase throughput.

    NOTE that you can call sfetch_setup() on multiple threads, each thread
    will get its own thread-local sokol-fetch instance, which will work
    independently from sokol-fetch instances on other threads.

    void sfetch_shutdown(void)
    --------------------------
    Call sfetch_shutdown() at the end of the application to stop any
    IO threads and free all memory that was allocated in sfetch_setup().

    sfetch_handle_t sfetch_send(const sfetch_request_t* request)
    ------------------------------------------------------------
    Call sfetch_send() to start loading data, the function takes a pointer to an
    sfetch_request_t struct with request parameters and returns a
    sfetch_handle_t identifying the request for later calls. At least
    a path/URL and callback must be provided:

        sfetch_handle_t h = sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = my_response_callback
        });

    sfetch_send() will return an invalid handle if no request can be allocated
    from the internal pool because all available request items are 'in-flight'.

    The sfetch_request_t struct contains the following parameters (optional
    parameters that are not provided must be zero-initialized):

        - path (const char*, required)
            Pointer to an UTF-8 encoded C string describing the filesystem
            path or HTTP URL. The string will be copied into an internal data
            structure, and passed "as is" (apart from any required
            encoding-conversions) to fopen(), CreateFileW() or
            XMLHttpRequest. The maximum length of the string is defined by
            the SFETCH_MAX_PATH configuration define, the default is 1024 bytes
            including the 0-terminator byte.

        - callback (sfetch_callback_t, required)
            Pointer to a response-callback function which is called when the
            request needs "user code attention". Search below for REQUEST
            STATES AND THE RESPONSE CALLBACK for detailed information about
            handling responses in the response callback.

        - channel (uint32_t, optional)
            Index of the IO channel where the request should be processed.
            Channels are used to parallelize and prioritize requests relative
            to each other. Search below for CHANNELS AND LANES for more
            information. The default channel is 0.

        - chunk_size (uint32_t, optional)
            The chunk_size member is used for streaming data incrementally
            in small chunks. After 'chunk_size' bytes have been loaded into
            to the streaming buffer, the response callback will be called
            with the buffer containing the fetched data for the current chunk.
            If chunk_size is 0 (the default), than the whole file will be loaded.
            Please search below for CHUNK SIZE AND HTTP COMPRESSION for
            important information how streaming works if the web server
            is serving compressed data.

        - buffer_ptr, buffer_size (void*, uint64_t, optional)
            This is a optional pointer/size pair describing a chunk of memory where
            data will be loaded into (if no buffer is provided upfront, this
            must happen in the response callback). If a buffer is provided,
            it must be big enough to either hold the entire file (if chunk_size
            is zero), or the *uncompressed* data for one downloaded chunk
            (if chunk_size is > 0).

        - user_data_ptr, user_data_size (const void*, uint32_t, both optional)
            user_data_ptr and user_data_size describe an optional POD (plain-old-data)
            associated with the request which will be copied(!) into an internal
            memory block. The maximum default size of this memory block is
            128 bytes (but can be overridden by defining SFETCH_MAX_USERDATA_UINT64
            before including the notification, note that this define is in
            "number of uint64_t", not number of bytes). The user-data
            block is 8-byte aligned, and will be copied via memcpy() (so don't
            put any C++ "smart members" in there).

    NOTE that request handles are strictly thread-local and only unique
    within the thread the handle was created on, and all function calls
    involving a request handle must happen on that same thread.

    bool sfetch_handle_valid(sfetch_handle_t request)
    -------------------------------------------------
    This checks if the provided request handle is valid, and is associated with
    a currently active request. It will return false if:

        - sfetch_send() returned an invalid handle because it couldn't allocate
          a new request from the internal request pool (because they're all
          in flight)
        - the request associated with the handle is no longer alive (because
          it either finished successfully, or the request failed for some
          reason)

    void sfetch_dowork(void)
    ------------------------
    Call sfetch_dowork(void) in regular intervals (for instance once per frame)
    on the same thread as sfetch_setup() to "turn the gears". If you are sending
    requests but never hear back from them in the response callback function, then
    the most likely reason is that you forgot to add the call to sfetch_dowork()
    in the per-frame function.

    sfetch_dowork() roughly performs the following work:

        - any new requests that have been sent with sfetch_send() since the
        last call to sfetch_dowork() will be dispatched to their IO channels
        and assigned a free lane. If all lanes on that channel are occupied
        by requests 'in flight', incoming requests must wait until
        a lane becomes available

        - for all new requests which have been enqueued on a channel which
        don't already have a buffer assigned the response callback will be
        called with (response->dispatched == true) so that the response
        callback can inspect the dynamically assigned lane and bind a buffer
        to the request (search below for CHANNELS AND LANE for more info)

        - a state transition from "user side" to "IO thread side" happens for
        each new request that has been dispatched to a channel.

        - requests dispatched to a channel are either forwarded into that
        channel's worker thread (on native platforms), or cause an HTTP
        request to be sent via an asynchronous XMLHttpRequest (on the web
        platform)

        - for all requests which have finished their current IO operation a
        state transition from "IO thread side" to "user side" happens,
        and the response callback is called so that the fetched data
        can be processed.

        - requests which are completely finished (either because the entire
        file content has been loaded, or they are in the FAILED state) are
        freed (this just changes their state in the 'request pool', no actual
        memory is freed)

        - requests which are not yet finished are fed back into the
        'incoming' queue of their channel, and the cycle starts again, this
        only happens for requests which perform data streaming (not load
        the entire file at once).

    void sfetch_cancel(sfetch_handle_t request)
    -------------------------------------------
    This cancels a request in the next sfetch_dowork() call and invokes the
    response callback with (response.failed == true) and (response.finished
    == true) to give user-code a chance to do any cleanup work for the
    request. If sfetch_cancel() is called for a request that is no longer
    alive, nothing bad will happen (the call will simply do nothing).

    void sfetch_pause(sfetch_handle_t request)
    ------------------------------------------
    This pauses an active request in the next sfetch_dowork() call and puts
    it into the PAUSED state. For all requests in PAUSED state, the response
    callback will be called in each call to sfetch_dowork() to give user-code
    a chance to CONTINUE the request (by calling sfetch_continue()). Pausing
    a request makes sense for dynamic rate-limiting in streaming scenarios
    (like video/audio streaming with a fixed number of streaming buffers. As
    soon as all available buffers are filled with download data, downloading
    more data must be prevented to allow video/audio playback to catch up and
    free up empty buffers for new download data.

    void sfetch_continue(sfetch_handle_t request)
    ---------------------------------------------
    Continues a paused request, counterpart to the sfetch_pause() function.

    void sfetch_bind_buffer(sfetch_handle_t request, void* buffer_ptr, uint64_t buffer_size)
    ----------------------------------------------------------------------------------------
    This "binds" a new buffer (pointer/size pair) to an active request. The
    function *must* be called from inside the response-callback, and there
    must not already be another buffer bound.

    void* sfetch_unbind_buffer(sfetch_handle_t request)
    ---------------------------------------------------
    This removes the current buffer binding from the request and returns
    a pointer to the previous buffer (useful if the buffer was dynamically
    allocated and it must be freed).

    sfetch_unbind_buffer() *must* be called from inside the response callback.

    The usual code sequence to bind a different buffer in the response
    callback might look like this:

        void response_callback(const sfetch_response_t* response) {
            if (response.fetched) {
                ...
                // switch to a different buffer (in the FETCHED state it is
                // guaranteed that the request has a buffer, otherwise it
                // would have gone into the FAILED state
                void* old_buf_ptr = sfetch_unbind_buffer(response.handle);
                free(old_buf_ptr);
                void* new_buf_ptr = malloc(new_buf_size);
                sfetch_bind_buffer(response.handle, new_buf_ptr, new_buf_size);
            }
            if (response.finished) {
                // unbind and free the currently associated buffer,
                // the buffer pointer could be null if the request has failed
                // NOTE that it is legal to call free() with a nullptr,
                // this happens if the request failed to open its file
                // and never goes into the OPENED state
                void* buf_ptr = sfetch_unbind_buffer(response.handle);
                free(buf_ptr);
            }
        }

    sfetch_desc_t sfetch_desc(void)
    -------------------------------
    sfetch_desc() returns a copy of the sfetch_desc_t struct passed to
    sfetch_setup(), with zero-initialized values replaced with
    their default values.

    int sfetch_max_userdata_bytes(void)
    -----------------------------------
    This returns the value of the SFETCH_MAX_USERDATA_UINT64 config
    define, but in number of bytes (so SFETCH_MAX_USERDATA_UINT64*8).

    int sfetch_max_path(void)
    -------------------------
    Returns the value of the SFETCH_MAX_PATH config define.


    REQUEST STATES AND THE RESPONSE CALLBACK
    ========================================
    A request goes through a number of states during its lifetime. Depending
    on the current state of a request, it will be 'owned' either by the
    "user-thread" (where the request was sent) or an IO thread.

    You can think of a request as "ping-ponging" between the IO thread and
    user thread, any actual IO work is done on the IO thread, while
    invocations of the response-callback happen on the user-thread.

    All state transitions and callback invocations happen inside the
    sfetch_dowork() function.

    An active request goes through the following states:

    ALLOCATED (user-thread)

        The request has been allocated in sfetch_send() and is
        waiting to be dispatched into its IO channel. When this
        happens, the request will transition into the DISPATCHED state.

    DISPATCHED (IO thread)

        The request has been dispatched into its IO channel, and a
        lane has been assigned to the request.

        If a buffer was provided in sfetch_send() the request will
        immediately transition into the FETCHING state and start loading
        data into the buffer.

        If no buffer was provided in sfetch_send(), the response
        callback will be called with (response->dispatched == true),
        so that the response callback can bind a buffer to the
        request. Binding the buffer in the response callback makes
        sense if the buffer isn't dynamically allocated, but instead
        a pre-allocated buffer must be selected from the request's
        channel and lane.

        Note that it isn't possible to get a file size in the response callback
        which would help with allocating a buffer of the right size, this is
        because it isn't possible in HTTP to query the file size before the
        entire file is downloaded (...when the web server serves files compressed).

        If opening the file failed, the request will transition into
        the FAILED state with the error code SFETCH_ERROR_FILE_NOT_FOUND.

    FETCHING (IO thread)

        While a request is in the FETCHING state, data will be loaded into
        the user-provided buffer.

        If no buffer was provided, the request will go into the FAILED
        state with the error code SFETCH_ERROR_NO_BUFFER.

        If a buffer was provided, but it is too small to contain the
        fetched data, the request will go into the FAILED state with
        error code SFETCH_ERROR_BUFFER_TOO_SMALL.

        If less data can be read from the file than expected, the request
        will go into the FAILED state with error code SFETCH_ERROR_UNEXPECTED_EOF.

        If loading data into the provided buffer works as expected, the
        request will go into the FETCHED state.

    FETCHED (user thread)

        The request goes into the FETCHED state either when the entire file
        has been loaded into the provided buffer (when request.chunk_size == 0),
        or a chunk has been loaded (and optionally decompressed) into the
        buffer (when request.chunk_size > 0).

        The response callback will be called so that the user-code can
        process the loaded data using the following sfetch_response_t struct members:

            - fetched_size: the number of bytes in the provided buffer
            - buffer_ptr: pointer to the start of fetched data
            - fetched_offset: the byte offset of the loaded data chunk in the
              overall file (this is only set to a non-zero value in a streaming
              scenario)

        Once all file data has been loaded, the 'finished' flag will be set
        in the response callback's sfetch_response_t argument.

        After the user callback returns, and all file data has been loaded
        (response.finished flag is set) the request has reached its end-of-life
        and will recycled.

        Otherwise, if there's still data to load (because streaming was
        requested by providing a non-zero request.chunk_size), the request
        will switch back to the FETCHING state to load the next chunk of data.

        Note that it is ok to associate a different buffer or buffer-size
        with the request by calling sfetch_bind_buffer() in the response-callback.

        To check in the response callback for the FETCHED state, and
        independently whether the request is finished:

            void response_callback(const sfetch_response_t* response) {
                if (response->fetched) {
                    // request is in FETCHED state, the loaded data is available
                    // in .buffer_ptr, and the number of bytes that have been
                    // loaded in .fetched_size:
                    const void* data = response->buffer_ptr;
                    const uint64_t num_bytes = response->fetched_size;
                }
                if (response->finished) {
                    // the finished flag is set either when all data
                    // has been loaded, the request has been cancelled,
                    // or the file operation has failed, this is where
                    // any required per-request cleanup work should happen
                }
            }


    FAILED (user thread)

        A request will transition into the FAILED state in the following situations:

            - if the file doesn't exist or couldn't be opened for other
              reasons (SFETCH_ERROR_FILE_NOT_FOUND)
            - if no buffer is associated with the request in the FETCHING state
              (SFETCH_ERROR_NO_BUFFER)
            - if the provided buffer is too small to hold the entire file
              (if request.chunk_size == 0), or the (potentially decompressed)
              partial data chunk (SFETCH_ERROR_BUFFER_TOO_SMALL)
            - if less bytes could be read from the file then expected
              (SFETCH_ERROR_UNEXPECTED_EOF)
            - if a request has been cancelled via sfetch_cancel()
              (SFETCH_ERROR_CANCELLED)

        The response callback will be called once after a request goes into
        the FAILED state, with the 'response->finished' and
        'response->failed' flags set to true.

        This gives the user-code a chance to cleanup any resources associated
        with the request.

        To check for the failed state in the response callback:

            void response_callback(const sfetch_response_t* response) {
                if (response->failed) {
                    // specifically check for the failed state...
                }
                // or you can do a catch-all check via the finished-flag:
                if (response->finished) {
                    if (response->failed) {
                        // if more detailed error handling is needed:
                        switch (response->error_code) {
                            ...
                        }
                    }
                }
            }

    PAUSED (user thread)

        A request will transition into the PAUSED state after user-code
        calls the function sfetch_pause() on the request's handle. Usually
        this happens from within the response-callback in streaming scenarios
        when the data streaming needs to wait for a data decoder (like
        a video/audio player) to catch up.

        While a request is in PAUSED state, the response-callback will be
        called in each sfetch_dowork(), so that the user-code can either
        continue the request by calling sfetch_continue(), or cancel
        the request by calling sfetch_cancel().

        When calling sfetch_continue() on a paused request, the request will
        transition into the FETCHING state. Otherwise if sfetch_cancel() is
        called, the request will switch into the FAILED state.

        To check for the PAUSED state in the response callback:

            void response_callback(const sfetch_response_t* response) {
                if (response->paused) {
                    // we can check here whether the request should
                    // continue to load data:
                    if (should_continue(response->handle)) {
                        sfetch_continue(response->handle);
                    }
                }
            }


    CHUNK SIZE AND HTTP COMPRESSION
    ===============================
    TL;DR: for streaming scenarios, the provided chunk-size must be smaller
    than the provided buffer-size because the web server may decide to
    serve the data compressed and the chunk-size must be given in 'compressed
    bytes' while the buffer receives 'uncompressed bytes'. It's not possible
    in HTTP to query the uncompressed size for a compressed download until
    that download has finished.

    With vanilla HTTP, it is not possible to query the actual size of a file
    without downloading the entire file first (the Content-Length response
    header only provides the compressed size). Furthermore, for HTTP
    range-requests, the range is given on the compressed data, not the
    uncompressed data. So if the web server decides to server the data
    compressed, the content-length and range-request parameters don't
    correspond to the uncompressed data that's arriving in the sokol-fetch
    buffers, and there's no way from JS or WASM to either force uncompressed
    downloads (e.g. by setting the Accept-Encoding field), or access the
    compressed data.

    This has some implications for sokol_fetch.h, most notably that buffers
    can't be provided in the exactly right size, because that size can't
    be queried from HTTP before the data is actually downloaded.

    When downloading whole files at once, it is basically expected that you
    know the maximum files size upfront through other means (for instance
    through a separate meta-data-file which contains the file sizes and
    other meta-data for each file that needs to be loaded).

    For streaming downloads the situation is a bit more complicated. These
    use HTTP range-requests, and those ranges are defined on the (potentially)
    compressed data which the JS/WASM side doesn't have access to. However,
    the JS/WASM side only ever sees the uncompressed data, and it's not possible
    to query the uncompressed size of a range request before that range request
    has finished.

    If the provided buffer is too small to contain the uncompressed data,
    the request will fail with error code SFETCH_ERROR_BUFFER_TOO_SMALL.


    CHANNELS AND LANES
    ==================
    Channels and lanes are (somewhat artificial) concepts to manage
    parallelization, prioritization and rate-limiting.

    Channels can be used to parallelize message processing for better
    'pipeline throughput', and to prioritize messages: user-code could
    reserve one channel for "small and big" streaming downloads,
    another channel for "regular" downloads and yet another high-priority channel
    which would only be used for small files which need to start loading
    immediately.

    Each channel comes with its own IO thread and message queues for pumping
    messages in and out of the thread. The channel where a request is
    processed is selected manually when sending a message:

        sfetch_send(&(sfetch_request_t){
            .path = "my_file.txt",
            .callback = my_response_callback,
            .channel = 2
        });

    The number of channels is configured at startup in sfetch_setup() and
    cannot be changed afterwards.

    Channels are completely separate from each other, and a request will
    never "hop" from one channel to another.

    Each channel consists of a fixed number of "lanes" for automatic rate
    limiting:

    When a request is sent to a channel via sfetch_send(), a "free lane" will
    be picked and assigned to the request. The request will occupy this lane
    for its entire life time (also while it is paused). If all lanes of a
    channel are currently occupied, new requests will need to wait until a
    lane becomes unoccupied.

    Since the number of channels and lanes is known upfront, it is guaranteed
    that there will never be more than "num_channels * num_lanes" requests
    in flight at any one time.

    This guarantee eliminates unexpected load- and memory-spikes when
    many requests are sent in very short time, and it allows to pre-allocate
    a fixed number of memory buffers which can be reused for the entire
    "lifetime" of a sokol-fetch context.

    In the most simple scenario - when a maximum file size is known - buffers
    can be statically allocated like this:

        uint8_t buffer[NUM_CHANNELS][NUM_LANES][MAX_FILE_SIZE];

    Then in the user callback pick a buffer by channel and lane,
    and associate it with the request like this:

        void response_callback(const sfetch_response_t* response) {
            if (response->dispatched) {
                void* ptr = buffer[response->channel][response->lane];
                sfetch_bind_buffer(response->handle, ptr, MAX_FILE_SIZE);
            }
            ...
        }


    NOTES ON OPTIMIZING PIPELINE LATENCY AND THROUGHPUT
    ===================================================
    With the default configuration of 1 channel and 1 lane per channel,
    sokol_fetch.h will appear to have a shockingly bad loading performance
    if several files are loaded.

    This has two reasons:

        (1) all parallelization when loading data has been disabled. A new
        request will only be processed, when the last request has finished.

        (2) every invocation of the response-callback adds one frame of latency
        to the request, because callbacks will only be called from within
        sfetch_dowork()

    sokol-fetch takes a few shortcuts to improve step (2) and reduce
    the 'inherent latency' of a request:

        - if a buffer is provided upfront, the response-callback won't be
        called in the OPENED state, but start right with the FETCHED state
        where data has already been loaded into the buffer

        - there is no separate CLOSED state where the callback is invoked
        separately when loading has finished (or the request has failed),
        instead the finished and failed flags will be set as part of
        the last FETCHED invocation

    This means providing a big-enough buffer to fit the entire file is the
    best case, the response callback will only be called once, ideally in
    the next frame (or two calls to sfetch_dowork()).

    If no buffer is provided upfront, one frame of latency is added because
    the response callback needs to be invoked in the OPENED state so that
    the user code can bind a buffer.

    This means the best case for a request without an upfront-provided
    buffer is 2 frames (or 3 calls to sfetch_dowork()).

    That's about what can be done to improve the latency for a single request,
    but the really important step is to improve overall throughput. If you
    need to load thousands of files you don't want that to be completely
    serialized.

    The most important action to increase throughput is to increase the
    number of lanes per channel. This defines how many requests can be
    'in flight' on a single channel at the same time. The guiding decision
    factor for how many lanes you can "afford" is the memory size you want
    to set aside for buffers. Each lane needs its own buffer so that
    the data loaded for one request doesn't scribble over the data
    loaded for another request.

    Here's a simple example of sending 4 requests without upfront buffer
    on a channel with 1, 2 and 4 lanes, each line is one frame:

        1 LANE (8 frames):
            Lane 0:
            -------------
            REQ 0 OPENED
            REQ 0 FETCHED
            REQ 1 OPENED
            REQ 1 FETCHED
            REQ 2 OPENED
            REQ 2 FETCHED
            REQ 3 OPENED
            REQ 3 FETCHED

    Note how the request don't overlap, so they can all use the same buffer.

        2 LANES (4 frames):
            Lane 0:         Lane 1:
            ---------------------------------
            REQ 0 OPENED    REQ 1 OPENED
            REQ 0 FETCHED   REQ 1 FETCHED
            REQ 2 OPENED    REQ 3 OPENED
            REQ 2 FETCHED   REQ 3 FETCHED

    This reduces the overall time to 4 frames, but now you need 2 buffers so
    that requests don't scribble over each other.

        4 LANES (2 frames):
            Lane 0:         Lane 1:         Lane 2:         Lane 3:
            -------------------------------------------------------------
            REQ 0 OPENED    REQ 1 OPENED    REQ 2 OPENED    REQ 3 OPENED
            REQ 0 FETCHED   REQ 1 FETCHED   REQ 2 FETCHED   REQ 3 FETCHED

    Now we're down to the same 'best-case' latency as sending a single
    request.

    Apart from the memory requirements for the streaming buffers (which is
    under your control), you can be generous with the number of channels,
    they don't add any processing overhead.

    The last option for tweaking latency and throughput is channels. Each
    channel works independently from other channels, so while one
    channel is busy working through a large number of requests (or one
    very long streaming download), you can set aside a high-priority channel
    for requests that need to start as soon as possible.

    On platforms with threading support, each channel runs on its own
    thread, but this is mainly an implementation detail to work around
    the blocking traditional file IO functions, not for performance reasons.


    FUTURE PLANS / V2.0 IDEA DUMP
    =============================
    - An optional polling API (as alternative to callback API)
    - Move buffer-management into the API? The "manual management"
      can be quite tricky especially for dynamic allocation scenarios,
      API support for buffer management would simplify cases like
      preventing that requests scribble over each other's buffers, or
      an automatic garbage collection for dynamically allocated buffers,
      or automatically falling back to dynamic allocation if static
      buffers aren't big enough.
    - Pluggable request handlers to load data from other "sources"
      (especially HTTP downloads on native platforms via e.g. libcurl
      would be useful)
    - I'm currently not happy how the user-data block is handled, this
      should getting and updating the user-data should be wrapped by
      API functions (similar to bind/unbind buffer)


    LICENSE
    =======
    zlib/libpng license

    Copyright (c) 2019 Andre Weissflog

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
enum SOKOL_FETCH_INCLUDED = 1;

/* configuration values for sfetch_setup() */
struct sfetch_desc_t
{
    uint _start_canary;
    uint max_requests; /* max number of active requests across all channels, default is 128 */
    uint num_channels; /* number of channels to fetch requests in parallel, default is 1 */
    uint num_lanes; /* max number of requests active on the same channel, default is 1 */
    uint _end_canary;
}

/* a request handle to identify an active fetch request, returned by sfetch_send() */
struct sfetch_handle_t
{
    uint id;
}

/* error codes */
enum sfetch_error_t
{
    SFETCH_ERROR_NO_ERROR = 0,
    SFETCH_ERROR_FILE_NOT_FOUND = 1,
    SFETCH_ERROR_NO_BUFFER = 2,
    SFETCH_ERROR_BUFFER_TOO_SMALL = 3,
    SFETCH_ERROR_UNEXPECTED_EOF = 4,
    SFETCH_ERROR_INVALID_HTTP_STATUS = 5,
    SFETCH_ERROR_CANCELLED = 6
}


/* the response struct passed to the response callback */
struct sfetch_response_t
{
    sfetch_handle_t handle; /* request handle this response belongs to */
    bool dispatched; /* true when request is in DISPATCHED state (lane has been assigned) */
    bool fetched; /* true when request is in FETCHED state (fetched data is available) */
    bool paused; /* request is currently in paused state */
    bool finished; /* this is the last response for this request */
    bool failed; /* request has failed (always set together with 'finished') */
    bool cancelled; /* request was cancelled (always set together with 'finished') */
    sfetch_error_t error_code; /* more detailed error code when failed is true */
    uint channel; /* the channel which processes this request */
    uint lane; /* the lane this request occupies on its channel */
    const(char)* path; /* the original filesystem path of the request (FIXME: this is unsafe, wrap in API call?) */
    void* user_data; /* pointer to read/write user-data area (FIXME: this is unsafe, wrap in API call?) */
    uint fetched_offset; /* current offset of fetched data chunk in file data */
    uint fetched_size; /* size of fetched data chunk in number of bytes */
    void* buffer_ptr; /* pointer to buffer with fetched data */
    uint buffer_size; /* overall buffer size (may be >= than fetched_size!) */
}

/* response callback function signature */
alias sfetch_callback_t = void function (const(sfetch_response_t)*);

/* request parameters passed to sfetch_send() */
struct sfetch_request_t
{
    uint _start_canary;
    uint channel; /* index of channel this request is assigned to (default: 0) */
    const(char)* path; /* filesystem path or HTTP URL (required) */
    sfetch_callback_t callback; /* response callback function pointer (required) */
    void* buffer_ptr; /* buffer pointer where data will be loaded into (optional) */
    uint buffer_size; /* buffer size in number of bytes (optional) */
    uint chunk_size; /* number of bytes to load per stream-block (optional) */
    const(void)* user_data_ptr; /* pointer to a POD user-data block which will be memcpy'd(!) (optional) */
    uint user_data_size; /* size of user-data block (optional) */
    uint _end_canary;
}

/* setup sokol-fetch (can be called on multiple threads) */
void sfetch_setup (const(sfetch_desc_t)* desc);
/* discard a sokol-fetch context */
void sfetch_shutdown ();
/* return true if sokol-fetch has been setup */
bool sfetch_valid ();
/* get the desc struct that was passed to sfetch_setup() */
sfetch_desc_t sfetch_desc ();
/* return the max userdata size in number of bytes (SFETCH_MAX_USERDATA_UINT64 * sizeof(uint64_t)) */
int sfetch_max_userdata_bytes ();
/* return the value of the SFETCH_MAX_PATH implementation config value */
int sfetch_max_path ();

/* send a fetch-request, get handle to request back */
sfetch_handle_t sfetch_send (const(sfetch_request_t)* request);
/* return true if a handle is valid *and* the request is alive */
bool sfetch_handle_valid (sfetch_handle_t h);
/* do per-frame work, moves requests into and out of IO threads, and invokes response-callbacks */
void sfetch_dowork ();

/* bind a data buffer to a request (request must not currently have a buffer bound, must be called from response callback */
void sfetch_bind_buffer (sfetch_handle_t h, void* buffer_ptr, uint buffer_size);
/* clear the 'buffer binding' of a request, returns previous buffer pointer (can be 0), must be called from response callback */
void* sfetch_unbind_buffer (sfetch_handle_t h);
/* cancel a request that's in flight (will call response callback with .cancelled + .finished) */
void sfetch_cancel (sfetch_handle_t h);
/* pause a request (will call response callback each frame with .paused) */
void sfetch_pause (sfetch_handle_t h);
/* continue a paused request */
void sfetch_continue (sfetch_handle_t h);

/* extern "C" */

/* reference-based equivalents for c++ */

// SOKOL_FETCH_INCLUDED

/*--- IMPLEMENTATION ---------------------------------------------------------*/

/* memset, memcpy */

/* fopen, fread, fseek, fclose */

/*=== private type definitions ===============================================*/

/* a thread with incoming and outgoing message queue syncing */

/* file handle abstraction */

/* user-side per-request state */

/* switch item to PAUSED state if true */
/* switch item back to FETCHING if true */
/* cancel the request, switch into FAILED state */
/* transfer IO => user thread */
/* number of bytes fetched so far */
/* size of last fetched chunk */

/* user thread only */

/* thread-side per-request state */

/* transfer IO => user thread */

/* IO thread only */

/* a request goes through the following states, ping-ponging between IO and user thread */

/* internal: request has just been initialized */
/* internal: request has been allocated from internal pool */
/* user thread: request has been dispatched to its IO channel */
/* IO thread: waiting for data to be fetched */
/* user thread: fetched data available */
/* user thread: request has been paused via sfetch_pause() */
/* user thread: follow state or FETCHING if something went wrong */

/* an internal request item */

/* updated by IO-thread, off-limits to user thread */

/* accessible by user-thread, off-limits to IO thread */

/* big stuff at the end */

/* a pool of internal per-request items */

/* a ringbuffer for pool-slot ids */

/* an IO channel with its own IO thread */

/* back-pointer to thread-local _sfetch state pointer,
   since this isn't accessible from the IO threads */

/* the sfetch global state */

/*=== general helper functions and macros =====================================*/

/*=== a circular message queue ===============================================*/

/* one slot reserved to detect full vs empty */

/*=== request pool implementation ============================================*/

/* NOTE: item slot 0 is reserved for the special "invalid" item index 0*/

/* generation counters indexable by pool slot index, slot 0 is reserved */

/* NOTE: it's not a bug to only reserve num_items here */

/* never allocate the 0-th item, this is the reserved 'invalid item' */

/* allocation error */

/* pool exhausted, return the 'invalid handle' */

/* debug check against double-free */

/* return pointer to item by handle without matching id check */

/* return pointer to item by handle with matching id check */

/*=== PLATFORM WRAPPER FUNCTIONS =============================================*/

/* FIXME: in debug mode, the threads should be named */

/* called when the thread-func is entered, this blocks the thread func until
   the _sfetch_thread_t object is fully initialized
*/

/* called by the thread-func right before it is left */

/* called from user thread */

/* called from thread function */

/* called from thread function */

/* called from user thread */

/* _SFETCH_PLATFORM_POSIX */

/* input string doesn't fit into destination buffer */

/* lpFileName */
/* dwDesiredAccess */
/* dwShareMode */
/* lpSecurityAttributes */
/* dwCreationDisposition */
/* dwFlagsAndAttributes */
/* hTemplateFile */

/* called by the thread-func right before it is left */

/* called from user thread */

/* called from thread function */

/* called from thread function */

/* called from user thread */

/* _SFETCH_PLATFORM_WINDOWS */

/*=== IO CHANNEL implementation ==============================================*/

/* per-channel request handler for native platforms accessing the local filesystem */

/* open file if not happened yet */

/* load entire file */

/* provided buffer to small to fit entire file */

/* provided buffer to small to fit next chunk */

/* ignore items in PAUSED or FAILED state */

/* block until work arrives */

/* slot_id will be invalid if the thread was woken up to join */

/* _SFETCH_HAS_THREADS */

/*=== embedded Javascript helper functions ===================================*/

/* if bytes_to_read != 0, a range-request will be sent, otherwise a normal request */

/*=== emscripten specific C helper functions =================================*/

/* send HTTP range request */

/* called by JS when an initial HEAD request finished successfully (only when streaming chunks) */

/* called by JS when a followup GET request finished successfully */

/* called by JS when an error occurred */

/* extern "C" */

/* if streaming download is requested, and the content-length isn't known
   yet, need to send a HEAD request first
 */

/* otherwise, this is either a request to load the entire file, or
   to load the next streaming chunk
 */

/* just move all other items (e.g. paused or cancelled)
   into the outgoing queue, so they wont get lost
*/

/* _SFETCH_PLATFORM_EMSCRIPTEN */

/* put a request into the channels sent-queue, this is where all new requests
   are stored until a lane becomes free.
*/

/* per-frame channel stuff: move requests in and out of the IO threads, call response callbacks */

/* move items from sent- to incoming-queue permitting free lanes */

/* if no buffer provided yet, invoke response callback to do so */

/* prepare incoming items for being moved into the IO thread */

/* transfer input params from user- to thread-data */

/* move new items into the IO threads and processed items out of IO threads */

/* without threading just directly dequeue items from the user_incoming queue and
   call the request handler, the user_outgoing queue will be filled as the
   asynchronous HTTP requests sent by the request handler are completed
*/

/* drain the outgoing queue, prepare items for invoking the response
   callback, and finally call the response callback, free finished items
*/

/* transfer output params from thread- to user-data */

/* state transition */

/* when the request is finish, free the lane for another request,
   otherwise feed it back into the incoming queue
*/

/*=== private high-level functions ===========================================*/

/* silence unused warnings in release*/

/*=== PUBLIC API FUNCTIONS ===================================================*/

/* replace zero-init items with default values */

/* setup the global request item pool */

/* setup IO channels (one thread per channel) */

/* IO threads must be shutdown first */

/* shortcut invalid handle */

/* send failed because the channels sent-queue overflowed */

/* we're pumping each channel 2x so that unfinished request items coming out the
   IO threads can be moved back into the IO-thread immediately without
   having to wait a frame
 */

/* SOKOL_IMPL */
