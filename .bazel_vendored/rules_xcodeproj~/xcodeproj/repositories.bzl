"""Definitions for handling Bazel repositories used by rules_xcodeproj."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//xcodeproj/internal:logging.bzl", "green", "warn", "yellow")

def _maybe(repo_rule, name, ignore_version_differences, **kwargs):
    """Executes the given repository rule if it hasn't been executed already.

    Args:
        repo_rule: The repository rule to be executed (e.g., `http_archive`.)
        name: The name of the repository to be defined by the rule.
        ignore_version_differences: If `True`, warnings about potentially
            incompatible versions of depended-upon repositories will be
            silenced.
        **kwargs: Additional arguments passed directly to the repository rule.
    """
    if native.existing_rule(name):
        if not ignore_version_differences:
            # Verify that the repository is being loaded from the same URL and
            # tag that we asked for, and warn if they differ.
            # This isn't perfect, because the user could load from the same
            # commit SHA as the tag, or load from an HTTP archive instead of a
            # Git repository, but this is a good first step toward validating.
            # Bzlmod will remove the need for all of this in the longer term.
            existing_repo = native.existing_rule(name)
            if (existing_repo.get("remote") != kwargs.get("remote") or
                existing_repo.get("tag") != kwargs.get("tag")):
                expected = "{url} (tag {tag})".format(
                    tag = kwargs.get("tag"),
                    url = kwargs.get("remote"),
                )
                existing = "{url} (tag {tag})".format(
                    tag = existing_repo.get("tag"),
                    url = existing_repo.get("remote"),
                )

                warn("""\
`rules_xcodeproj` depends on `{repo}` loaded from \
{expected}, but we have detected it already loaded into your workspace from \
{existing}. You may run into compatibility issues. To silence this warning, \
pass `ignore_version_differences = True` to `xcodeproj_rules_dependencies()`.
""".format(
                    existing = yellow(existing, bold = True),
                    expected = green(expected, bold = True),
                    repo = name,
                ))
        return

    repo_rule(name = name, **kwargs)

def _generated_files_repo_impl(repository_ctx):
    repository_ctx.file(
        "BUILD",
        content = """
package_group(
    name = "package_group",
    packages = ["//..."],
)
""",
    )

    # Don't do anything on non-macOS platforms
    if repository_ctx.execute(["uname"]).stdout.strip() != "Darwin":
        return

    output_base_hash_result = repository_ctx.execute(
        ["bash", "-c", '/sbin/md5 -q -s "${PWD%/*/*/*/*}"'],
    )
    if output_base_hash_result.return_code != 0:
        fail("Failed to calculate output base hash: {}".format(
            output_base_hash_result.stderr,
        ))

    # Ensure that this repository is unique per output base
    output_base_hash = output_base_hash_result.stdout.strip()
    repository_ctx.symlink(
        "/var/tmp/rules_xcodeproj/generated_v2/{}/generator".format(output_base_hash),
        "generator",
    )

generated_files_repo = repository_rule(
    implementation = _generated_files_repo_impl,
)

# buildifier: disable=unnamed-macro
def xcodeproj_rules_dependencies(
        ignore_version_differences = False,
        include_bzlmod_ready_dependencies = True,
        internal_only = False):
    """Fetches repositories that are dependencies of `rules_xcodeproj`.

    Users should call this macro in their `WORKSPACE` to ensure that all of the
    dependencies of rules_xcodeproj are downloaded and that they are isolated
    from changes to those dependencies.

    Args:
        ignore_version_differences: If `True`, warnings about potentially
            incompatible versions of dependency repositories will be silenced.
        include_bzlmod_ready_dependencies: Whether or not bzlmod-ready
            dependencies should be included.
        internal_only: If `True`, only internal dependencies will be included.
            Should only be called from `extensions.bzl`.
    """
    if internal_only or include_bzlmod_ready_dependencies:
        # Used to house generated files
        generated_files_repo(name = "rules_xcodeproj_generated")

    if internal_only:
        return

    if include_bzlmod_ready_dependencies:
        _maybe(
            http_archive,
            name = "bazel_skylib",
            sha256 = "66ffd9315665bfaafc96b52278f57c7e2dd09f5ede279ea6d39b2be471e7e3aa",
            url = "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
            ignore_version_differences = ignore_version_differences,
        )

        _maybe(
            http_archive,
            name = "build_bazel_rules_swift",
            sha256 = "bb01097c7c7a1407f8ad49a1a0b1960655cf823c26ad2782d0b7d15b323838e2",
            url = "https://github.com/bazelbuild/rules_swift/releases/download/1.18.0/rules_swift.1.18.0.tar.gz",
            ignore_version_differences = ignore_version_differences,
        )

        _maybe(
            http_archive,
            name = "build_bazel_rules_apple",
            sha256 = "b4df908ec14868369021182ab191dbd1f40830c9b300650d5dc389e0b9266c8d",
            url = "https://github.com/bazelbuild/rules_apple/releases/download/3.5.1/rules_apple.3.5.1.tar.gz",
            ignore_version_differences = ignore_version_differences,
        )

        _maybe(
            http_archive,
            name = "bazel_features",
            sha256 = "4912fc2f5d17199a043e65c108d3f0a2896061296d4c335aee5e6a3a71cc4f0d",
            strip_prefix = "bazel_features-1.4.0",
            url = "https://github.com/bazel-contrib/bazel_features/releases/download/v1.4.0/bazel_features-v1.4.0.tar.gz",
            ignore_version_differences = ignore_version_differences,
        )

    # `rules_swift` depends on `build_bazel_rules_swift_index_import`, and we
    # also need to use `index-import`, so we could declare the same dependency
    # here in order to reuse it, and in case `rules_swift` stops depending on it
    # in the future. We don't though, because we need 5.5.3.1 or higher, and the
    # current lowest version of rules_swift we support uses 5.3.2.6.
    _maybe(
        http_archive,
        name = "rules_xcodeproj_index_import",
        build_file_content = """\
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")

native_binary(
    name = "index_import",
    src = "index-import",
    out = "index-import",
    visibility = ["//visibility:public"],
)
""",
        sha256 = "28c1ffa39d99e74ed70623899b207b41f79214c498c603915aef55972a851a15",
        url = "https://github.com/MobileNativeFoundation/index-import/releases/download/5.8.0.1/index-import.tar.gz",
        ignore_version_differences = ignore_version_differences,
    )
