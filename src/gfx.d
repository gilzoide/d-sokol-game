import sokol_gfx;
public import pipelines;
public import texture;
public import uniforms;

struct Bindings
{
    sg_bindings bindings;

    void draw()
    {
        sg_apply_bindings(&bindings);
    }
}
