import sokol_gfx;

struct BufferDesc
{
    void[] content;
    sg_buffer_type type;
    sg_usage usage;
    string label;

    sg_buffer make()
    {
        sg_buffer_desc desc = {
            size: cast(int) content.length,
            content: cast(void*) content,
            type: type,
            usage: usage,
            label: cast(char*) label,
        };
        return sg_make_buffer(&desc);
    }
}

struct Pipeline
{
    sg_pipeline pipeline;
    alias pipeline this;

    void draw()
    {
        sg_apply_pipeline(pipeline);
    }
}

struct Bindings
{
    sg_bindings bindings;
    alias bindings this;

    void draw()
    {
        sg_apply_bindings(&bindings);
    }
}

