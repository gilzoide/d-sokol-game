import mathtypes;
import sokol_gfx;

struct Texture(uint W, uint H)
{
    Color[W * H] pixels;
    sg_filter filter = SG_FILTER_LINEAR;
    private sg_image texture_id = 0;

    sg_image getId()
    {
        if (texture_id == 0)
        {
            sg_image_desc desc = {
                width: W,
                height: H,
                pixel_format: SG_PIXELFORMAT_RGBA8,
                min_filter: filter,
                mag_filter: filter,
            };
            with (desc.content.subimage[0][0])
            {
                ptr = cast(void*) pixels;
                size = pixels.sizeof;
            }
            texture_id = sg_make_image(&desc);
        }
        return texture_id;
    }
}
