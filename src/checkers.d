import std.math : PI;

import glfw;

import constants;
import camera;
import gfx;
import globals;
import input;
import mathtypes;
import mesh;
import node;
import regular_polygon;
import timer;
import tween;

//enum projection_matrix = Mat4.orthographic(
    //-8, 8,
    //-4.5, 4.5,
    //-10, 10
//);
enum projection_matrix = Mat4.perspectiveDegrees(
    100,
    windowAspectX,
    1,
    100,
) 
* Transform3D.fromTranslation(Vec3(0, 0, -4));

struct Arena(uint N)
{
    mixin Node;

    Pipeline pipeline;
    Camera.Rebind cameraRebind;
    StandardUniform arenaValues;
    UVTransformUniform uvTransform = {{
        transform: Transform3D.fromScaling([3, 1]),
    }};
    InstancedMesh lines;

    IndexType[N * Mesh.quadIndices.length] indices = void;
    Vertex[N * Mesh.quadVertices.length] vertices = void;

    enum uvSpeed = 3;

    Tween!("easeInOutSine", TweenOptions.yoyo) tintTween = {
        duration: 3,
        running: true,
        looping: true,
    };
    enum tintRange = Vec4Range(
        Vec4(0.1, 0.1, 0.1, 1),
        Vec4(0, 200.0 / 255, 200.0 / 255, 1),
    );

    void generateIndices()
    {
        import std.range : chunks, enumerate;
        enum length = Mesh.quadIndices.length;
        foreach (i, c; indices[].chunks(length).enumerate)
        {
            c[] = Mesh.quadIndices[] + cast(IndexType)(Mesh.quadVertices.length * i);
        }
    }
    void generateVertices()
    {
        enum sideSize = 1.2;
        enum radius = 4;
        enum depth = 10;
        enum Color colorFront = [255, 255, 255, 255];
        enum Color colorBack = [51, 51, 51, 0];
        enum Vertex[4] lineVertices = [
            { position: [+sideSize, -radius],         uv: [UV(0), UV(1)], color: colorFront },
            { position: [-sideSize, -radius],         uv: [UV(0), UV(0)], color: colorFront },
            { position: [+sideSize, -radius, -depth], uv: [UV(1), UV(1)], color: colorBack },
            { position: [-sideSize, -radius, -depth], uv: [UV(1), UV(0)], color: colorBack },
        ];

        import std.range : chunks, enumerate;
        foreach (i, c; vertices[].chunks(lineVertices.length).enumerate)
        {
            const auto rotation = Transform3DCompact.fromRotation(RegularPolygon!N.angleAt(cast(int) i));
            foreach (j, ref vertex; c)
            {
                vertex = lineVertices[j].transformed(rotation);
            }
        }
    }

    void initialize()
    {
        pipeline = Pipeline.standardUVTransform;

        generateVertices();
        generateIndices();
        lines.setup(vertices, indices);
        lines.texture_id = checkered2x2Texture.getId();
    }

    void update(double dt)
    {
        arenaValues.tint_color = tintTween.value(tintRange);
        if (window.glfwGetKey(GLFW_KEY_W) || window.glfwGetKey(GLFW_KEY_UP))
        {
            uvTransform.transform.translate([uvSpeed * dt]);
        }
        if (window.glfwGetKey(GLFW_KEY_S) || window.glfwGetKey(GLFW_KEY_DOWN))
        {
            uvTransform.transform.translate([-uvSpeed * dt]);
        }
    }
}

struct Checkers
{
    mixin Node;

    Pipeline pipeline;
    Camera camera = projection_matrix;
    StandardUniform quadTransform;
    InstancedMesh quad;
    Arena!N arena;

    enum tweenDuration = 0.8;
    Tween!("easeOutQuad", TweenOptions.yoyo | TweenOptions.endCallback) jumpTween = {
        duration: tweenDuration / 2,
        running: false,
        looping: false,
        yoyoLoops: true,
    };

    enum N = 5;

    int currentAngleIndex = 0;
    alias RotateArenaAngles = RegularPolygon!(N * 2);
    auto angleRange = RotateArenaAngles.angleRangeClockwise(0);
    alias RotateSelfAngles = RegularPolygon!(2);
    auto inverseAngleRange = RotateSelfAngles.angleRangeCounterClockwise(0);
    bool jumpingClockwise;

    enum size = 1;
    enum transform = Transform3DCompact.identity
        .scale(Vec2(size))
        .translate(Vec2(-size*0.5, -size*0.5))
        ;
    enum jumpTranslate = Vec2Range(
        Vec2(0, -3.5),
        Vec2(0, -2),
    );

    void initialize()
    {
        pipeline = Pipeline.standard;

        quad.mesh = Mesh.quad;
        quad.texture_id = checkered2x2Texture.getId();

        jumpTween.endCallback = &jumpEndCallback;
    }

    void updateAngleRanges()
    {
        if (jumpingClockwise)
        {
            angleRange = RotateArenaAngles.angleRangeClockwise(currentAngleIndex);
            inverseAngleRange = RotateSelfAngles.angleRangeCounterClockwise(-currentAngleIndex);
        }
        else
        {
            angleRange = RotateArenaAngles.angleRangeCounterClockwise(currentAngleIndex);
            inverseAngleRange = RotateSelfAngles.angleRangeClockwise(-currentAngleIndex);
        }
    }

    void jumpEndCallback()
    {
        if (jumpingClockwise)
        {
            currentAngleIndex++;
        }
        else
        {
            currentAngleIndex--;
        }
        updateAngleRanges();
        if (jumpTween.isRewinding)
        {
            angleRange.invert();
            inverseAngleRange.invert();
        }
    }

    void update(double dt)
    {
        if (!jumpTween.running)
        {
            if (window.glfwGetKey(GLFW_KEY_A) || window.glfwGetKey(GLFW_KEY_LEFT))
            {
                jumpingClockwise = true;
                updateAngleRanges();
                jumpTween.running = true;
            }
            else if (window.glfwGetKey(GLFW_KEY_D) || window.glfwGetKey(GLFW_KEY_RIGHT))
            {
                jumpingClockwise = false;
                updateAngleRanges();
                jumpTween.running = true;
            }
        }
        transform
            .rotate(inverseAngleRange.lerp(jumpTween.position))
            .translate(jumpTween.value(jumpTranslate))
            .rotate(angleRange.lerp(jumpTween.position))
            .fullInto(quadTransform.transform);
    }
}
