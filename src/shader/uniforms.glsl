@block CameraUniform
layout(binding=0) uniform CameraUniform {
    mat4 projection_matrix;
};
@end

@block StandardUniform
layout(binding=1) uniform StandardUniform {
    mat4 transform;
    vec4 tint_color;
};
@end

@block UVTransformUniform
uniform UVTransformUniform {
    mat4 uv_transform;
};
@end

@block StandardInstancedUniform
const uint MAX_INSTANCES = 16;

layout(binding=1) uniform StandardInstancedUniform {
    mat4[MAX_INSTANCES] transform;
    vec4[MAX_INSTANCES] tint_color;
};
@end
