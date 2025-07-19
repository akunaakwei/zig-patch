const std = @import("std");
pub const PatchStep = @import("PatchStep.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const closedir_void = b.option(bool, "CLOSEDIR_VOID", "Define to true if the `closedir' function returns void instead of `int'.");
    const double_slash_is_distinct_root = b.option(bool, "DOUBLE_SLASH_IS_DISTINCT_ROOT", "Define to true if // is a file system root distinct from /.") orelse true;
    const d_ino_in_dirent = b.option(bool, "D_INO_IN_DIRENT", "Define if struct dirent has a member d_ino that actually works.") orelse true;
    const file_system_accepts_drive_letter_prefix = b.option(bool, "FILE_SYSTEM_ACCEPTS_DRIVE_LETTER_PREFIX", "Define on systems for which file names may have a so-called `drive letter' prefix, define this to compute the length of that prefix, including the colon.") orelse switch (target.result.os.tag) {
        .windows => true,
        else => false,
    };
    const file_system_backslash_is_file_name_separator = b.option(bool, "FILE_SYSTEM_BACKSLASH_IS_FILE_NAME_SEPARATOR", "Define if the backslash character may also serve as a file name component separator.") orelse switch (target.result.os.tag) {
        .windows => true,
        else => false,
    };
    const file_system_drive_prefix_can_be_relative = b.option(bool, "FILE_SYSTEM_DRIVE_PREFIX_CAN_BE_RELATIVE", "Define if a drive letter prefix denotes a relative path if it is not followed by a file name component separator.") orelse switch (target.result.os.tag) {
        .windows => true,
        else => false,
    };
    const have_bp_sym_h = b.option(bool, "HAVE_BP_SYM_H", "Define to true if you have the <bp-sym.h> header file.");
    const have_decl_clearerr_unlocked = b.option(bool, "HAVE_DECL_CLEARERR_UNLOCKED", "Define to true if you have the declaration of `clearerr_unlocked', and to false if you don't.");
    const have_decl_feof_unlocked = b.option(bool, "HAVE_DECL_FEOF_UNLOCKED", "Define to true if you have the declaration of `feof_unlocked', and to false if you don't.");
    const have_decl_ferror_unlocked = b.option(bool, "HAVE_DECL_FERROR_UNLOCKED", "Define to true if you have the declaration of `ferror_unlocked', and to false if you don't.");
    const have_decl_fflush_unlocked = b.option(bool, "HAVE_DECL_FFLUSH_UNLOCKED", "Define to true if you have the declaration of `fflush_unlocked', and to false if you don't.");
    const have_decl_fgets_unlocked = b.option(bool, "HAVE_DECL_FGETS_UNLOCKED", "Define to true if you have the declaration of `fgets_unlocked', and to false if you don't.");
    const have_decl_fputc_unlocked = b.option(bool, "HAVE_DECL_FPUTC_UNLOCKED", "Define to true if you have the declaration of `fputc_unlocked', and to false if you don't.");
    const have_decl_fputs_unlocked = b.option(bool, "HAVE_DECL_FPUTS_UNLOCKED", "Define to true if you have the declaration of `fputs_unlocked', and to false if you don't.");
    const have_decl_fread_unlocked = b.option(bool, "HAVE_DECL_FREAD_UNLOCKED", "Define to true if you have the declaration of `fread_unlocked', and to false if you don't.");
    const have_decl_fwrite_unlocked = b.option(bool, "HAVE_DECL_FWRITE_UNLOCKED", "Define to true if you have the declaration of `fwrite_unlocked', and to false if you don't.");
    const have_decl_getchar_unlocked = b.option(bool, "HAVE_DECL_GETCHAR_UNLOCKED", "Define to true if you have the declaration of `getchar_unlocked', and to false if you don't.");
    const have_decl_getc_unlocked = b.option(bool, "HAVE_DECL_GETC_UNLOCKED", "Define to true if you have the declaration of `getc_unlocked', and to false if you don't.");
    const have_decl_getenv = b.option(bool, "HAVE_DECL_GETENV", "Define to true if you have the declaration of `getenv', and to false if you don't.") orelse true;
    const have_decl_mktemp = b.option(bool, "HAVE_DECL_MKTEMP", "Define to true if you have the declaration of `mktemp', and to false if you don't.") orelse true;
    const have_decl_putchar_unlocked = b.option(bool, "HAVE_DECL_PUTCHAR_UNLOCKED", "Define to true if you have the declaration of `putchar_unlocked', and to false if you don't.");
    const have_decl_putc_unlocked = b.option(bool, "HAVE_DECL_PUTC_UNLOCKED", "Define to true if you have the declaration of `putc_unlocked', and to false if you don't.");
    const have_decl_strerror_r = b.option(bool, "HAVE_DECL_STRERROR_R", "Define to true if you have the declaration of `strerror_r', and to false if you don't.");
    const have_decl_strndup = b.option(bool, "HAVE_DECL_STRNDUP", "Define to true if you have the declaration of `strndup', and to false if you don't.");
    const have_decl_strnlen = b.option(bool, "HAVE_DECL_STRNLEN", "Define to true if you have the declaration of `strnlen', and to false if you don't.") orelse true;
    const have_dirent_h = b.option(bool, "HAVE_DIRENT_H", "Define to true if you have the <dirent.h> header file, and it defines `DIR'.") orelse true;
    const have_doprnt = b.option(bool, "HAVE_DOPRNT", "Define to true if you don't have `vprintf' but do have `_doprnt.'");
    const have_fcntl_h = b.option(bool, "HAVE_FCNTL_H", "Define to true if you have the <fcntl.h> header file.") orelse true;
    const have_fseeko = b.option(bool, "HAVE_FSEEKO", "Define to true if fseeko (and presumably ftello) exists and is declared.") orelse true;
    const have_geteuid = b.option(bool, "HAVE_GETEUID", "Define to true if you have the `geteuid' function.");
    const have_getopt_h = b.option(bool, "HAVE_GETOPT_H", "Define to true if you have the <getopt.h> header file.") orelse true;
    const have_getopt_long_only = b.option(bool, "HAVE_GETOPT_LONG_ONLY", "Define to true if you have the `getopt_long_only' function.") orelse true;
    const have_getuid = b.option(bool, "HAVE_GETUID", "Define to true if you have the `getuid' function.");
    const have_inline = b.option(bool, "HAVE_INLINE", "Define to true if the compiler supports one of the keywords 'inline', '__inline__', '__inline' and effectively inlines functions marked as such.") orelse true;
    const have_inttypes_h = b.option(bool, "HAVE_INTTYPES_H", "Define to true if you have the <inttypes.h> header file.") orelse true;
    const have_long_file_names = b.option(bool, "HAVE_LONG_FILE_NAMES", "Define to true if you support file names longer than 14 characters.") orelse true;
    const have_malloc_posix = b.option(bool, "HAVE_MALLOC_POSIX", "Define if the 'malloc' function is POSIX compliant.");
    const have_memchr = b.option(bool, "HAVE_MEMCHR", "Define to true if you have the `memchr' function.") orelse true;
    const have_memory_h = b.option(bool, "HAVE_MEMORY_H", "Define to true if you have the <memory.h> header file.") orelse true;
    const have_mkdir = b.option(bool, "HAVE_MKDIR", "Define to true if you have the `mkdir' function.");
    const have_mktemp = b.option(bool, "HAVE_MKTEMP", "Define to true if you have the `mktemp' function.");
    const have_ndir_h = b.option(bool, "HAVE_NDIR_H", "Define to true if you have the <ndir.h> header file, and it defines `DIR'.");
    const have_pathconf = b.option(bool, "HAVE_PATHCONF", "Define to true if you have the `pathconf' function.");
    const have_raise = b.option(bool, "HAVE_RAISE", "Define to true if you have the `raise' function.") orelse true;
    const have_realloc_posix = b.option(bool, "HAVE_REALLOC_POSIX", "Define if the 'realloc' function is POSIX compliant.");
    const have_setmode_dos = b.option(bool, "HAVE_SETMODE_DOS", "Define to true if you have the DOS-style `setmode' function.") orelse switch (target.result.os.tag) {
        .windows => true,
        else => null,
    };
    const have_sigaction = b.option(bool, "HAVE_SIGACTION", "Define to true if you have the `sigaction' function.");
    const have_sigprocmask = b.option(bool, "HAVE_SIGPROCMASK", "Define to true if you have the `sigprocmask' function.");
    const have_sigsetmask = b.option(bool, "HAVE_SIGSETMASK", "Define to true if you have the `sigsetmask' function.");
    const have_stdbool_h = b.option(bool, "HAVE_STDBOOL_H", "Define to true if stdbool.h conforms to C99.") orelse true;
    const have_stdint_h = b.option(bool, "HAVE_STDINT_H", "Define to true if you have the <stdint.h> header file.") orelse true;
    const have_stdlib_h = b.option(bool, "HAVE_STDLIB_H", "Define to true if you have the <stdlib.h> header file.") orelse true;
    const have_strcasecmp = b.option(bool, "HAVE_STRCASECMP", "Define to true if you have the `strcasecmp' function.") orelse true;
    const have_strerror_r = b.option(bool, "HAVE_STRERROR_R", "Define to true if you have the `strerror_r' function.");
    const have_strings_h = b.option(bool, "HAVE_STRINGS_H", "Define to true if you have the <strings.h> header file.") orelse true;
    const have_string_h = b.option(bool, "HAVE_STRING_H", "Define to true if you have the <string.h> header file.") orelse true;
    const have_strncasecmp = b.option(bool, "HAVE_STRNCASECMP", "Define to true if you have the `strncasecmp' function.") orelse true;
    const have_strndup = b.option(bool, "HAVE_STRNDUP", "Define if you have the strndup() function and it works.");
    const have_struct_utimbuf = b.option(bool, "HAVE_STRUCT_UTIMBUF", "Define if struct utimbuf is declared -- usually in <utime.h>. Some systems have utime.h but don't declare the struct anywhere.") orelse true;
    const have_sys_dir_h = b.option(bool, "HAVE_SYS_DIR_H", "Define to true if you have the <sys/dir.h> header file, and it defines `DIR'.");
    const have_sys_ndir_h = b.option(bool, "HAVE_SYS_NDIR_H", "Define to true if you have the <sys/ndir.h> header file, and it defines `DIR'.");
    const have_sys_stat_h = b.option(bool, "HAVE_SYS_STAT_H", "Define to true if you have the <sys/stat.h> header file.") orelse true;
    const have_sys_time_h = b.option(bool, "HAVE_SYS_TIME_H", "Define to true if you have the <sys/time.h> header file.") orelse true;
    const have_sys_types_h = b.option(bool, "HAVE_SYS_TYPES_H", "Define to true if you have the <sys/types.h> header file.") orelse true;
    const have_unistd_h = b.option(bool, "HAVE_UNISTD_H", "Define to true if you have the <unistd.h> header file.") orelse true;
    const have_utime_h = b.option(bool, "HAVE_UTIME_H", "Define to true if you have the <utime.h> header file.") orelse true;
    const have_vprintf = b.option(bool, "HAVE_VPRINTF", "Define to true if you have the `vprintf' function.") orelse true;
    const have__bool = b.option(bool, "HAVE__BOOL", "Define to true if the system has the type `_Bool'.") orelse true;
    const mkdir_takes_one_arg = b.option(bool, "MKDIR_TAKES_ONE_ARG", "Define if mkdir takes only one argument.") orelse switch (target.result.os.tag) {
        .windows => true,
        else => null,
    };
    const stdc_headers = b.option(bool, "STDC_HEADERS", "Define to true if you have the ANSI C header files.") orelse true;
    const strerror_r_char_p = b.option(bool, "STRERROR_R_CHAR_P", "Define to true if strerror_r returns char *.");
    const use_unlocked_io = b.option(bool, "USE_UNLOCKED_IO", "Define to true if you want getc etc. to use unlocked I/O if available. Unlocked I/O can improve performance in unithreaded apps, but it is not safe for multithreaded apps.") orelse true;
    const _file_offset_bits = b.option(bool, "_FILE_OFFSET_BITS", "Number of bits in a file offset, on hosts where this is settable.");
    const _largefile_source = b.option(bool, "_LARGEFILE_SOURCE", "Define to true to make fseeko visible on some hosts (e.g. glibc 2.2).");
    const _large_files = b.option(bool, "_LARGE_FILES", "Define for large files, on AIX-style hosts.");
    const _minix = b.option(bool, "_MINIX", "Define to true if on MINIX.");
    const _posix_1_source = b.option(bool, "_POSIX_1_SOURCE", "Define to 2 if the system does not provide POSIX.1 features except with this defined.");
    const _posix_source = b.option(bool, "_POSIX_SOURCE", "Define to true if you need to in order for `stat' and other things to work.");
    const _xopen_source = b.option(bool, "_XOPEN_SOURCE", "Define to 500 only on HP-UX.");
    const _all_source = b.option(bool, "_ALL_SOURCE", "Enable extensions on AIX 3, Interix.");
    const _gnu_source = b.option(bool, "_GNU_SOURCE", "Enable GNU extensions on systems that have them.");
    const _posix_pthread_semantics = b.option(bool, "_POSIX_PTHREAD_SEMANTICS", "Enable threading extensions on Solaris.");
    const _tandem_source = b.option(bool, "_TANDEM_SOURCE", "Enable extensions on HP NonStop.");
    const __extensions__ = b.option(bool, "__EXTENSIONS__", "");
    const __getopt_prefix = b.option([]const u8, "__GETOPT_PREFIX", "Define to rpl_ if the getopt replacement functions and variables should beused.");
    const mode_t = b.option([]const u8, "mode_t", "Define to `int' if <sys/types.h> does not define.");
    const off_t = b.option([]const u8, "off_t", "Define to `long int' if <sys/types.h> does not define.");
    const ssize_t = b.option([]const u8, "ssize_t", "Define as a signed type of the same size as size_t.");
    const strnlen = b.option([]const u8, "strnlen", "Define to rpl_strnlen if the replacement function should be used.");

    const patch_dep = b.dependency("patch", .{});

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();

    flags.appendSlice(&.{
        "-Wno-string-plus-int",
        "-Ded_PROGRAM=\"ed\"",
        "-DSAFE_WRITE",
    }) catch @panic("OOM");

    if (target.result.os.tag == .windows) {
        flags.appendSlice(&.{
            "-DO_BINARY=1",
            "-DRENAME_DEST_EXISTS_BUG",
            "-Dchown(path, owner, group)=0",
            "-Drename=rpl_rename",
        }) catch @panic("OOM");
    }

    const config = b.addConfigHeader(.{
        .style = .{ .autoconf_undef = patch_dep.path("config.hin") },
    }, .{
        .CLOSEDIR_VOID = closedir_void,
        .DOUBLE_SLASH_IS_DISTINCT_ROOT = double_slash_is_distinct_root,
        .D_INO_IN_DIRENT = d_ino_in_dirent,
        .FILE_SYSTEM_ACCEPTS_DRIVE_LETTER_PREFIX = file_system_accepts_drive_letter_prefix,
        .FILE_SYSTEM_BACKSLASH_IS_FILE_NAME_SEPARATOR = file_system_backslash_is_file_name_separator,
        .FILE_SYSTEM_DRIVE_PREFIX_CAN_BE_RELATIVE = file_system_drive_prefix_can_be_relative,
        .HAVE_BP_SYM_H = have_bp_sym_h,
        .HAVE_DECL_CLEARERR_UNLOCKED = have_decl_clearerr_unlocked,
        .HAVE_DECL_FEOF_UNLOCKED = have_decl_feof_unlocked,
        .HAVE_DECL_FERROR_UNLOCKED = have_decl_ferror_unlocked,
        .HAVE_DECL_FFLUSH_UNLOCKED = have_decl_fflush_unlocked,
        .HAVE_DECL_FGETS_UNLOCKED = have_decl_fgets_unlocked,
        .HAVE_DECL_FPUTC_UNLOCKED = have_decl_fputc_unlocked,
        .HAVE_DECL_FPUTS_UNLOCKED = have_decl_fputs_unlocked,
        .HAVE_DECL_FREAD_UNLOCKED = have_decl_fread_unlocked,
        .HAVE_DECL_FWRITE_UNLOCKED = have_decl_fwrite_unlocked,
        .HAVE_DECL_GETCHAR_UNLOCKED = have_decl_getchar_unlocked,
        .HAVE_DECL_GETC_UNLOCKED = have_decl_getc_unlocked,
        .HAVE_DECL_GETENV = have_decl_getenv,
        .HAVE_DECL_MKTEMP = have_decl_mktemp,
        .HAVE_DECL_PUTCHAR_UNLOCKED = have_decl_putchar_unlocked,
        .HAVE_DECL_PUTC_UNLOCKED = have_decl_putc_unlocked,
        .HAVE_DECL_STRERROR_R = have_decl_strerror_r,
        .HAVE_DECL_STRNDUP = have_decl_strndup,
        .HAVE_DECL_STRNLEN = have_decl_strnlen,
        .HAVE_DIRENT_H = have_dirent_h,
        .HAVE_DOPRNT = have_doprnt,
        .HAVE_FCNTL_H = have_fcntl_h,
        .HAVE_FSEEKO = have_fseeko,
        .HAVE_GETEUID = have_geteuid,
        .HAVE_GETOPT_H = have_getopt_h,
        .HAVE_GETOPT_LONG_ONLY = have_getopt_long_only,
        .HAVE_GETUID = have_getuid,
        .HAVE_INLINE = have_inline,
        .HAVE_INTTYPES_H = have_inttypes_h,
        .HAVE_LONG_FILE_NAMES = have_long_file_names,
        .HAVE_MALLOC_POSIX = have_malloc_posix,
        .HAVE_MEMCHR = have_memchr,
        .HAVE_MEMORY_H = have_memory_h,
        .HAVE_MKDIR = have_mkdir,
        .HAVE_MKTEMP = have_mktemp,
        .HAVE_NDIR_H = have_ndir_h,
        .HAVE_PATHCONF = have_pathconf,
        .HAVE_RAISE = have_raise,
        .HAVE_REALLOC_POSIX = have_realloc_posix,
        .HAVE_SETMODE_DOS = have_setmode_dos,
        .HAVE_SIGACTION = have_sigaction,
        .HAVE_SIGPROCMASK = have_sigprocmask,
        .HAVE_SIGSETMASK = have_sigsetmask,
        .HAVE_STDBOOL_H = have_stdbool_h,
        .HAVE_STDINT_H = have_stdint_h,
        .HAVE_STDLIB_H = have_stdlib_h,
        .HAVE_STRCASECMP = have_strcasecmp,
        .HAVE_STRERROR_R = have_strerror_r,
        .HAVE_STRINGS_H = have_strings_h,
        .HAVE_STRING_H = have_string_h,
        .HAVE_STRNCASECMP = have_strncasecmp,
        .HAVE_STRNDUP = have_strndup,
        .HAVE_STRUCT_UTIMBUF = have_struct_utimbuf,
        .HAVE_SYS_DIR_H = have_sys_dir_h,
        .HAVE_SYS_NDIR_H = have_sys_ndir_h,
        .HAVE_SYS_STAT_H = have_sys_stat_h,
        .HAVE_SYS_TIME_H = have_sys_time_h,
        .HAVE_SYS_TYPES_H = have_sys_types_h,
        .HAVE_UNISTD_H = have_unistd_h,
        .HAVE_UTIME_H = have_utime_h,
        .HAVE_VPRINTF = have_vprintf,
        .HAVE__BOOL = have__bool,
        .MKDIR_TAKES_ONE_ARG = mkdir_takes_one_arg,
        .PACKAGE_BUGREPORT = "bug-patch@gnu.org",
        .PACKAGE_NAME = "patch",
        .PACKAGE_STRING = "patch 2.6.1",
        .PACKAGE_TARNAME = "patch",
        .PACKAGE_VERSION = "2.6.1",
        .STDC_HEADERS = stdc_headers,
        .STRERROR_R_CHAR_P = strerror_r_char_p,
        .USE_UNLOCKED_IO = use_unlocked_io,
        ._FILE_OFFSET_BITS = _file_offset_bits,
        ._LARGEFILE_SOURCE = _largefile_source,
        ._LARGE_FILES = _large_files,
        ._MINIX = _minix,
        ._POSIX_1_SOURCE = _posix_1_source,
        ._POSIX_SOURCE = _posix_source,
        ._XOPEN_SOURCE = _xopen_source,
        ._ALL_SOURCE = _all_source,
        ._GNU_SOURCE = _gnu_source,
        ._POSIX_PTHREAD_SEMANTICS = _posix_pthread_semantics,
        ._TANDEM_SOURCE = _tandem_source,
        .__EXTENSIONS__ = __extensions__,
        .__GETOPT_PREFIX = __getopt_prefix,
        .@"inline" = null,
        .mode_t = mode_t,
        .off_t = off_t,
        .ssize_t = ssize_t,
        .strnlen = strnlen,
    });

    const gl = b.addLibrary(.{
        .name = "gl",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    gl.linkLibC();
    gl.addConfigHeader(config);
    gl.addIncludePath(patch_dep.path(b.pathJoin(&.{ "gl", "lib" })));
    gl.addCSourceFiles(.{
        .root = patch_dep.path(b.pathJoin(&.{ "gl", "lib" })),
        .files = &.{
            "argmatch.c",
            "backupfile.c",
            "basename.c",
            "dirname.c",
            "error.c",
            "exitfail.c",
            "full-write.c",
            "hash.c",
            "malloc.c",
            "mbrtowc.c",
            "memchr.c",
            "quote.c",
            "quotearg.c",
            "realloc.c",
            "rename.c",
            "safe-read.c",
            "safe-write.c",
            "strcasecmp.c",
            "stripslash.c",
            "strncasecmp.c",
            "strndup.c",
            "xmalloc.c",
            "xstrndup.c",
        },
        .flags = flags.items,
    });
    gl.root_module.sanitize_c = .off;

    const patch = b.addExecutable(.{
        .name = "patch",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    patch.linkLibC();
    patch.linkLibrary(gl);
    patch.addConfigHeader(config);
    patch.addIncludePath(patch_dep.path(b.pathJoin(&.{ "gl", "lib" })));
    patch.addIncludePath(patch_dep.path("src"));
    patch.addCSourceFiles(.{
        .root = patch_dep.path("src"),
        .files = &.{
            "inp.c",
            "maketime.c",
            "partime.c",
            "patch.c",
            "pch.c",
            "quotesys.c",
            "util.c",
            "version.c",
        },
        .flags = flags.items,
    });

    b.installArtifact(patch);
}
