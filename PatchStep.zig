const std = @import("std");
const fs = std.fs;
const Step = std.Build.Step;
const LazyPath = std.Build.LazyPath;
const GeneratedFile = std.Build.GeneratedFile;
const PatchStep = @This();

step: Step,
patch_exe: *Step.Compile,
root_directory: LazyPath,
generated_directory: GeneratedFile,
patch_files: std.ArrayList(LazyPath),
strip: u32,

pub const Options = struct {
    root_directory: LazyPath,
    patch_dep_name: []const u8 = "patch",
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    strip: u32 = 0,
};

pub fn create(b: *std.Build, options: Options) *PatchStep {
    const step = Step.init(.{
        .id = .custom,
        .name = "patch",
        .owner = b,
        .makeFn = make,
    });
    const patch_exe = b.dependency(options.patch_dep_name, .{
        .target = options.target,
        .optimize = options.optimize,
    }).artifact("patch");
    const root_directory = options.root_directory.dupe(b);

    const patch = b.allocator.create(PatchStep) catch @panic("OOM");
    patch.* = .{
        .step = step,
        .patch_exe = patch_exe,
        .root_directory = root_directory,
        .generated_directory = .{ .step = &patch.step },
        .patch_files = .{},
        .strip = options.strip,
    };
    root_directory.addStepDependencies(&patch.step);
    patch.step.dependOn(&patch_exe.step);
    return patch;
}

pub fn getDirectory(patch: *PatchStep) LazyPath {
    return .{ .generated = .{ .file = &patch.generated_directory } };
}

pub fn addPatch(patch: *PatchStep, file: LazyPath) void {
    patch.patch_files.append(patch.step.owner.allocator, file) catch @panic("OOM");
}

fn make(step: *Step, options: Step.MakeOptions) !void {
    const b = step.owner;
    const patch: *PatchStep = @fieldParentPtr("step", step);

    const exe_cache_path = patch.patch_exe.getEmittedBin().getPath3(b, step);
    const exe_path = b.pathResolve(&.{ exe_cache_path.root_dir.path orelse ".", exe_cache_path.sub_path });

    const root_path = patch.root_directory.getPath3(b, step);
    var root_directory = root_path.openDir(".", .{ .iterate = true }) catch |err| {
        const abs_path = root_path.toString(b.allocator) catch @panic("OOM");
        return step.fail("unable to open directory '{s}': {s}", .{
            abs_path, @errorName(err),
        });
    };

    var man = b.graph.cache.obtain();
    defer man.deinit();

    man.hash.add(@as(u32, 0xEB465BF1));
    man.hash.addBytes(exe_path);
    {
        var it = try root_directory.walk(b.allocator);
        defer it.deinit();
        while (try it.next()) |entry| {
            switch (entry.kind) {
                .file => {
                    const file_path = try root_path.join(b.allocator, entry.path);
                    _ = try man.addFilePath(file_path, null);
                },
                else => continue,
            }
        }
    }
    for (patch.patch_files.items) |patch_file| {
        const patch_path = patch_file.getPath3(b, step);
        _ = try man.addFilePath(patch_path, null);
    }

    if (try step.cacheHitAndWatch(&man)) {
        const digest = man.final();
        patch.generated_directory.path = try b.cache_root.join(b.allocator, &.{ "o", &digest });
        return;
    }

    const digest = man.final();
    const cache_path = b.pathJoin(&.{ "o", &digest });
    const absolute_cache_path = try b.cache_root.join(b.allocator, &.{ "o", &digest });
    patch.generated_directory.path = absolute_cache_path;

    var cache_dir = b.cache_root.handle.makeOpenPath(cache_path, .{}) catch |err| {
        return step.fail("unable to make path '{f}{s}': {s}", .{
            b.cache_root, cache_path, @errorName(err),
        });
    };
    defer cache_dir.close();

    // copy everything from root_directory to cache_dir
    {
        var progress_node = options.progress_node.start(b.fmt("copy root dir {s}", .{patch.root_directory.getDisplayName()}), 0);
        defer progress_node.end();
        var it = try root_directory.walk(b.allocator);
        defer it.deinit();
        while (try it.next()) |entry| {
            switch (entry.kind) {
                .directory => cache_dir.makePath(entry.path) catch |err| {
                    return step.fail("unable to make path '{f}{s}{c}{s}': {s}", .{
                        b.cache_root, cache_path, fs.path.sep, entry.path, @errorName(err),
                    });
                },
                .file => {
                    const prev_status = std.fs.Dir.updateFile(
                        root_directory,
                        entry.path,
                        cache_dir,
                        entry.path,
                        .{},
                    ) catch |err| {
                        return step.fail("unable to update file from '{s}' to '{any}{s}{c}{s}': {s}", .{
                            entry.path, b.cache_root, cache_path, fs.path.sep, entry.path, @errorName(err),
                        });
                    };
                    _ = prev_status;
                },
                else => continue,
            }
        }
    }
    options.progress_node.increaseEstimatedTotalItems(patch.patch_files.items.len);
    for (patch.patch_files.items) |patch_file| {
        var argv_list: std.ArrayList([]const u8) = .{};
        defer argv_list.deinit(b.allocator);

        try argv_list.append(b.allocator, exe_path);
        try argv_list.append(b.allocator, "--strip");
        try argv_list.append(b.allocator, b.fmt("{d}", .{patch.strip}));
        try argv_list.append(b.allocator, "--quiet");
        try argv_list.append(b.allocator, "--no-backup-if-mismatch");
        if (patch.patch_exe.rootModuleTarget().os.tag == .windows) {
            try argv_list.append(b.allocator, "--binary");
        }
        try argv_list.append(b.allocator, "--directory");
        try argv_list.append(b.allocator, absolute_cache_path);
        var progress_node = options.progress_node.start(b.fmt("patch apply {s}", .{patch_file.getDisplayName()}), 0);
        defer progress_node.end();
        const patch_path = patch_file.getPath3(b, step);
        try argv_list.append(b.allocator, "--input");
        try argv_list.append(b.allocator, b.pathResolve(&.{ patch_path.root_dir.path orelse ".", patch_path.sub_path }));

        var child = std.process.Child.init(argv_list.items, b.allocator);
        child.cwd = null;
        child.cwd_dir = null;
        child.env_map = &b.graph.env_map;

        child.stdin_behavior = .Ignore;
        child.stdout_behavior = .Ignore;
        child.stderr_behavior = .Ignore;

        child.spawn() catch |err| {
            return step.fail("unable to spawn patch process {s}: {s}", .{
                exe_path, @errorName(err),
            });
        };
        _ = child.wait() catch |err| {
            return step.fail("patch process failed: {s}", .{@errorName(err)});
        };
        options.progress_node.setCompletedItems(1);
    }

    try man.writeManifest();
}
