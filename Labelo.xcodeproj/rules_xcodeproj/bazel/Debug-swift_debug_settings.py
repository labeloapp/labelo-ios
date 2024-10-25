#!/usr/bin/python3

"""An lldb module that registers a stop hook to set swift settings."""

import lldb
import re

# Order matters, it needs to be from the most nested to the least
_BUNDLE_EXTENSIONS = [
    ".framework",
    ".xctest",
    ".appex",
    ".bundle",
    ".app",
]

_TRIPLE_MATCH = re.compile(r"([^-]+-[^-]+)(-\D+)[^-]*(-.*)?")

_SETTINGS = {
    "arm64-apple-ios-simulator Labelo.app/LabeloBinary": {
        "c": "-I$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_combine_schedulers/CombineSchedulers -I$(BAZEL_EXTERNAL)/rules_swift_package_manager~~swift_deps~swiftpkg_swift_navigation/Sources/UIKitNavigationShim/include -I$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_navigation/Sources/UIKitNavigationShim/include -I$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_navigation/UIKitNavigationShim -I$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_composable_architecture/ComposableArchitecture -iquote$(BAZEL_EXTERNAL)/rules_swift_package_manager~~swift_deps~swiftpkg_swift_composable_architecture -iquote$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_composable_architecture -iquote$(BAZEL_EXTERNAL)/rules_swift_package_manager~~swift_deps~swiftpkg_combine_schedulers -iquote$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_combine_schedulers -iquote$(BAZEL_EXTERNAL)/rules_swift_package_manager~~swift_deps~swiftpkg_swift_navigation -iquote$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_navigation -iquote$(PROJECT_DIR) -iquote$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin -fmodule-map-file=$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_combine_schedulers/CombineSchedulers.rspm_modulemap/_/module.modulemap -fmodule-map-file=$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_combine_schedulers/CombineSchedulers.rspm_modulemap_modulemap/_/module.modulemap -fmodule-map-file=$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_navigation/UIKitNavigationShim.rspm_objc_modulemap/_/module.modulemap -fmodule-map-file=$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_navigation/UIKitNavigationShim.rspm_modulemap/_/module.modulemap -fmodule-map-file=$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_navigation/UIKitNavigationShim.rspm_modulemap_modulemap/_/module.modulemap -fmodule-map-file=$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_composable_architecture/ComposableArchitecture.rspm_modulemap/_/module.modulemap -fmodule-map-file=$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_composable_architecture/ComposableArchitecture.rspm_modulemap_modulemap/_/module.modulemap -O0 -DDEBUG=1 -fstack-protector -fstack-protector-all",
        "s": [
            "$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_xctest_dynamic_overlay",
            "$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_case_paths",
            "$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_concurrency_extras",
            "$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_combine_schedulers",
            "$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_custom_dump",
            "$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_clocks",
            "$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_dependencies",
            "$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_collections",
            "$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_identified_collections",
            "$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_perception",
            "$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_navigation",
            "$(BAZEL_OUT)/ios_sim_arm64-dbg-ios-sim_arm64-min16.0-applebin_ios-ST-d656ce74c288/bin/external/rules_swift_package_manager~~swift_deps~swiftpkg_swift_composable_architecture",
        ],
    },
}

def __lldb_init_module(debugger, _internal_dict):
    # Register the stop hook when this module is loaded in lldb
    ci = debugger.GetCommandInterpreter()
    res = lldb.SBCommandReturnObject()
    ci.HandleCommand(
        "target stop-hook add -P swift_debug_settings.StopHook",
        res,
    )
    if not res.Succeeded():
        print(f"""\
Failed to register Swift debug options stop hook:

{res.GetError()}
Please file a bug report here: \
https://github.com/MobileNativeFoundation/rules_xcodeproj/issues/new?template=bug.md
""")
        return

def _get_relative_executable_path(module):
    for extension in _BUNDLE_EXTENSIONS:
        prefix, _, suffix = module.rpartition(extension)
        if prefix:
            return prefix.split("/")[-1] + extension + suffix
    return module.split("/")[-1]

class StopHook:
    "An lldb stop hook class, that sets swift settings for the current module."

    def __init__(self, _target, _extra_args, _internal_dict):
        pass

    def handle_stop(self, exe_ctx, _stream):
        "Method that is called when the user stops in lldb."
        module = exe_ctx.frame.module
        if not module:
            return

        module_name = module.file.GetDirectory() + "/" + module.file.GetFilename()
        versionless_triple = _TRIPLE_MATCH.sub(r"\1\2\3", module.GetTriple())
        executable_path = _get_relative_executable_path(module_name)
        key = f"{versionless_triple} {executable_path}"

        settings = _SETTINGS.get(key)

        if settings:
            frameworks = " ".join([
                f'"{path}"'
                for path in settings.get("f", [])
            ])
            if frameworks:
                lldb.debugger.HandleCommand(
                    f"settings set -- target.swift-framework-search-paths {frameworks}",
                )
            else:
                lldb.debugger.HandleCommand(
                    "settings clear target.swift-framework-search-paths",
                )

            includes = " ".join([
                f'"{path}"'
                for path in settings.get("s", [])
            ])
            if includes:
                lldb.debugger.HandleCommand(
                    f"settings set -- target.swift-module-search-paths {includes}",
                )
            else:
                lldb.debugger.HandleCommand(
                    "settings clear target.swift-module-search-paths",
                )

            clang = settings.get("c")
            if clang:
                lldb.debugger.HandleCommand(
                    f"settings set -- target.swift-extra-clang-flags '{clang}'",
                )
            else:
                lldb.debugger.HandleCommand(
                    "settings clear target.swift-extra-clang-flags",
                )

        return True
