@block CameraUniform
layout(binding=0) uniform CameraUniform {
    mat4 projection_matrix;
};
@end

@block TransformUniform
layout(binding=1) uniform TransformUniform {
    mat4 transform;
};
@end

@block TransformInstancedUniform
const uint MAX_INSTANCES = 16;

layout(binding=1) uniform TransformInstancedUniform {
    mat4[MAX_INSTANCES] transform;
};
@end
