const std = @import("std");
const Builder = std.build.Builder;
const Step = std.build.Step;

pub fn build(b: *Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("zig-sokol", "src/main.zig");
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.addIncludeDir("libs/sokol");
    lib.addPackagePath("sokol", "libs/sokol-zig/src/sokol/sokol.zig");
    lib.install();

    const shader = addShader(b, "src/triangle.glsl");
    const shader_step = b.step("shader", "compile shader");
    shader_step.dependOn(&shader.step);

    const exe_name = "zig-sokol";
    if (target.isDarwin()) {
        // OSX gambs pra linkar os frameworks
        lib.disable_stack_probing = true;
        try b.makePath(b.getInstallPath(.Bin, ""));
        const exe = b.addSystemCommand(&[_][]const u8{
            "clang",
            "src/sokol.c", "-ObjC", "-Ilibs/sokol",
            b.getInstallPath(.Lib, lib.out_filename),
            "-framework", "Cocoa",
            "-framework", "QuartzCore",
            "-framework", "Metal",
            "-framework", "MetalKit",
            "-framework", "AudioToolbox",
            "-o", b.getInstallPath(.Bin, exe_name),
        });
        exe.step.dependOn(b.getInstallStep());
        exe.step.dependOn(&shader.step);

        const build_step = b.step("exe", "build the OSX app");
        build_step.dependOn(&exe.step);
    }
    else {
        const exe = b.addExecutable(exe_name, "src/sokol.c");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.addIncludeDir("libs/sokol");
        exe.linkLibrary(lib);
        exe.install();

        if (target.isLinux()) {
            exe.linkSystemLibrary("GL");
            exe.linkSystemLibrary("GLEW");
            exe.linkSystemLibrary("X11");
        }
    }
    
    // const exe = b.addExecutable("zig-sokol", "src/main.zig");
    // exe.setTarget(target);
    // exe.setBuildMode(mode);
    // exe.linkLibC();

    // if (target.isDarwin()) {
    //     const frameworks_dir = macosFrameworksDir(b) catch unreachable;
    //     // exe.addFrameworkDir(frameworks_dir);
    //     exe.addFrameworkDir("/Library/Developer/CommandLineTools/SDKs/MacOSX10.14.sdk/System/Library/Frameworks");
    //     for (&[_][]const u8{"Cocoa", "QuartzCore", "Metal", "MetalKit", "AudioToolbox"}) |name| {
    //         exe.linkFramework(name);
    //     }

    // } else if (target.isLinux()) {
    //     exe.linkSystemLibrary("GL");
    //     exe.linkSystemLibrary("GLEW");
    //     exe.linkSystemLibrary("X11");
    // }
    // exe.addIncludeDir("libs/sokol");
    // const cFlags = if (target.isDarwin()) &[_][]const u8{ "-ObjC", "-fobjc-arc" } else &[_][]const u8{"-std=c99"};
    // exe.addCSourceFile("src/sokol.c", cFlags);
    
    
    // exe.install();

//     const run_cmd = exe.run();
//     run_cmd.step.dependOn(b.getInstallStep());
//     if (b.args) |args| {
//         run_cmd.addArgs(args);
//     }

//     const run_step = b.step("run", "Run the app");
//     run_step.dependOn(&run_cmd.step);
}

fn addShader(builder: *Builder, shader_path: []const u8) *CompileShaderStep {
    const shader_step = builder.allocator.create(CompileShaderStep) catch unreachable;
    shader_step.* = CompileShaderStep.init(builder, shader_path);
    return shader_step;
}

const CompileShaderStep = struct {
    step: Step,
    builder: *Builder,
    shader_path: []const u8,

    var shdc: ?[]const u8 = null;

    pub fn init(builder: *Builder, shader_path: []const u8) CompileShaderStep {
        return .{
            .step = Step.init(.Custom, "compileshader", builder.allocator, make),
            .builder = builder,
            .shader_path = shader_path,
        };
    }

    fn make(step: *Step) !void {
        const self = @fieldParentPtr(CompileShaderStep, "step", step);
        const builder = self.builder;

        if (shdc == null) {
            shdc = try builder.findProgram(&[_][]const u8{"sokol-shdc"}, &[_][]const u8{});
        }

        const compileStep = builder.addSystemCommand(&[_][]const u8{
            shdc.?,
            "-i", self.shader_path,
            "-o", try std.mem.concat(builder.allocator, u8, &[_][]const u8{ self.shader_path, ".h" }),
            "-s", "glsl330",
        });
        self.step.dependOn(&compileStep.step);
    }
};

/// helper function to get SDK path on Mac
fn macosFrameworksDir(b: *Builder) ![]u8 {
    var str = try b.exec(&[_][]const u8{ "xcrun", "--show-sdk-path" });
    const strip_newline = std.mem.lastIndexOf(u8, str, "\n");
    if (strip_newline) |index| {
        str = str[0..index];
    }
    const frameworks_dir = try std.mem.concat(b.allocator, u8, &[_][]const u8{ str, "/System/Library/Frameworks" });
    return frameworks_dir;
}