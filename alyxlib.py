from pathlib import Path
from typing import Callable
import hashlib
import os
import re
import lib.interface as interface
import lib.templates as TEMPLATE

GIT_LIBRARY_INSTALLED = False
try:
    import git
    GIT_LIBRARY_INSTALLED = True
except ImportError:
    print("GitPython library required for some operations, plase use 'pip install gitpython' to install...")


DEFAULT_MANIFEST_HASH = '52a853e6cd865e341e7cb5c1cd1f59cf'
DEFAULT_SOUNDEVENT_HASH = 'cfbacc91bdc9cc53818dc4adb0950407'

# Relative symlinks do not work with Alyx!
USE_RELATIVE_SYMLINKS = False

def get_file_hash(path:Path) -> str|None:
    if path.exists():
        with path.open('rb') as f:
            return hashlib.md5(f.read()).hexdigest()
    return None

def files_match(file1: Path|str, file2: Path|str) -> bool:
    """Check if two files (or hashes) match.

    Args:
        file1 (Path | str): The first file path or file hash.
        file2 (Path | str): The second file path or file hash.

    Returns:
        bool: True if the file hashes match.
    """
    if isinstance(file1, Path):
        file1 = get_file_hash(file1)
    if isinstance(file2, Path):
        file2 = get_file_hash(file2)
    
    if not isinstance(file1, str) or not isinstance(file2, str):
        return False

    return file1 == file2


onupload_files:list[tuple[Path,str|None,Path|None]] = []
def add_onupload_file(path:Path, content:str = None, symlink_source:Path = None):
    onupload_files.append((path, content, symlink_source))
def clear_onupload_files():
    onupload_files.clear()
def write_onupload_file(onupload_path:Path):
    if len(onupload_files) == 0:
        return
    
    if onupload_path.name != "on_upload.bat":
        onupload_path /= "on_upload.bat"
    
    onupload_dir = os.path.dirname(onupload_path)
    
    with (onupload_path).open("w") as f:
        removes:list[str] = []
        for data in onupload_files:
            dst = data[0]
            content = data[1]
            symlink_src = data[2]
            removes.append(f'{"rmdir" if os.path.isdir(symlink_src) else "del"} "{dst.relative_to(onupload_dir)}"')

        reinstates:list[str] = []
        for data in onupload_files:
            dst = data[0]
            content = data[1]
            symlink_src = data[2]
            symlink_src_rel = symlink_src
            dst_rel = dst
            if USE_RELATIVE_SYMLINKS:
                symlink_src_rel = os.path.relpath(symlink_src,dst.parent)
                dst_rel = dst.relative_to(onupload_dir)
            # Creating symlinks
            if symlink_src is not None:
                reinstates.append(f'mklink{" /d" if os.path.isdir(symlink_src) else ""} "{dst_rel}" "{symlink_src_rel}"\necho.')
            # Directly writing to files
            elif content is not None:
                reinstates.append(f'echo {content}> {dst_rel}')
        
        f.write(TEMPLATE.ON_UPLOAD_FILE.format(os.path.relpath(alyxlib_content_path, onupload_dir), "\n".join(removes), "\n".join(reinstates)))

alyxlib_content_path = Path(os.path.abspath('.'))

alyx_base_path = Path(os.path.abspath('../../..'))

while not alyx_base_path.exists() or alyx_base_path.name != 'Half-Life Alyx':
    inp = input("Please enter Half-Life Alyx path:")
    if inp.strip() == '':
        exit()
    alyx_base_path = Path(inp)

content_path = alyx_base_path / 'content' / 'hlvr_addons'
game_path = alyx_base_path / 'game' / 'hlvr_addons'

addons = [x for x in content_path.iterdir() if x.is_dir()]

def print_addons():
    for addon in addons:
            print(addon.name)

verbose = True

def vprint(msg):
    if verbose:
        print(msg)

def write_to_file(path:Path, line:str = None, lines:list[str] = None, mode = 'w') -> bool:
    if path.exists():
        vprint(f"{path} already exists!")
        return False

    if not path.parent.exists():
        os.makedirs(path.parent)

    with path.open("w") as f:
        if line is not None:
            f.write(line)
        elif lines is not None:
            f.writelines(lines)
    
    return True

def create_symlinks(addon_content_path:Path, addon_game_path:Path, symlinks:list[tuple[Path,Path,bool]]):

    # Creating links
    for symlink in symlinks:
        src = symlink[0]
        dst = symlink[1]
        remove = symlink[2]
        if not dst.parent.exists():
            os.makedirs(dst.parent)
        
        # Don't replace existing files/dirs
        if os.path.exists(dst):
            vprint(f"{dst} already exists, symlink can't be created.")
        else:
            # But do remove a broken link
            if os.path.islink(dst):
                os.unlink(dst)
            # Then create the link
            if USE_RELATIVE_SYMLINKS:
                os.symlink(os.path.relpath(src, dst.parent), dst)
            else:
                os.symlink(src, dst)
            vprint(f"{dst} symlink created.")
            
        if remove:
            add_onupload_file(dst, symlink_source=src)

    print(f"Created {len(symlinks)} script symlinks!")

def create_modinit_script(addon_content_path:Path, addon_game_path:Path):
    write_to_file(addon_content_path / "scripts/vscripts/mods/init" / (addon_content_path.name + ".lua"), TEMPLATE.SCRIPT_INIT_LOCAL.format(addon_content_path.name))

    create_workshop_init = True
    pattern = re.compile("\d{10}\d*\.lua")
    for filepath in os.listdir(addon_content_path / "scripts/vscripts/mods/init"):
        if pattern.match(filepath):
            create_workshop_init = False
            break
    if create_workshop_init:
        write_to_file(addon_content_path / "scripts/vscripts/mods/init" / "0000000000.lua", TEMPLATE.SCRIPT_INIT_WORKSHOP.format(addon_content_path.name))
    else:
        vprint("Workshop init file not created because one was found")

    write_to_file(addon_content_path / f"scripts/vscripts/{addon_content_path.name}/init.lua", TEMPLATE.SCRIPT_INIT_MAIN)

    print("Created Scalable Init Support initialization files!")

def init_git(addon_content_path:Path, addon_game_path:Path):
    if not GIT_LIBRARY_INSTALLED:
        print("GitPython library required, plase use 'pip install gitpython' to install...")
        return
    
    repo = git.Repo.init(addon_content_path)
    if repo.bare:
        print("Something went wrong when creating the git repository...")
        return

    write_to_file(addon_content_path / ".gitignore", line="/_bakeresourcecache/\n*bakeresourcecache.vpk\n__pycache__\n__test*")
    
    print("Set up local git repository!")

def create_sound_files(addon_content_path:Path, addon_game_path:Path):
    if files_match(addon_content_path / "resourcemanifests/addon_template_addon_resources.vrman", DEFAULT_MANIFEST_HASH):
        os.remove(addon_content_path / "resourcemanifests/addon_template_addon_resources.vrman")
    
    addon_resource_path = addon_content_path / f"resourcemanifests/{addon_content_path.name}_addon_resources.vrman"
    if not addon_resource_path.exists():
        with addon_resource_path.open("w") as f:
            f.write(TEMPLATE.RESOURCE_MANIFEST_FILE.format(addon_content_path.name))
        print("Created addon resource manifest...")

    if files_match(addon_content_path / "soundevents/addon_template_soundevents.vsndevts", DEFAULT_SOUNDEVENT_HASH):
        os.remove(addon_content_path / "soundevents/addon_template_soundevents.vsndevts")

    addon_soundevent_path = addon_content_path / f"soundevents/{addon_content_path.name}_soundevents.vsndevts"
    if write_to_file(addon_content_path / f"soundevents/{addon_content_path.name}_soundevents.vsndevts", TEMPLATE.SOUNDEVENT_FILE):
        print("Created addon soundevent file...")
    

# MACROS

def MACRO_full_setup(a, b):
    print("Doing full addon setup...")
    create_symlinks(a, b, [
        (alyxlib_content_path / "scripts/vscripts/alyxlib", a / "scripts/vscripts/alyxlib", True),
        (alyxlib_content_path / "scripts/vlua_globals.lua", a / "scripts/vlua_globals.lua", True),
        (alyxlib_content_path / "scripts/vscripts/game", a / "scripts/vscripts/game", True),
        (alyxlib_content_path / ".vscode", a / ".vscode", False),
        (alyxlib_content_path / "panorama/scripts/custom_game/panorama_lua.js", a / "panorama/scripts/custom_game/panorama_lua.js", False),
        (alyxlib_content_path / "panorama/scripts/custom_game/panoramadoc.js", a / "panorama/scripts/custom_game/panoramadoc.js", False),
        (a / "scripts", b / "scripts", False)
    ])
    create_modinit_script(a, b)
    init_git(a, b)
    create_sound_files(a, b)
    print("...Finished full addon setup")

def MACRO_scripts_nogit_setup(a, b):
    print("Doing full addon setup (no Git)...")
    create_symlinks(a, b, [
        (alyxlib_content_path / "scripts/vscripts/alyxlib", a / "scripts/vscripts/alyxlib", True),
        (alyxlib_content_path / "scripts/vlua_globals.lua", a / "scripts/vlua_globals.lua", True),
        (alyxlib_content_path / "scripts/vscripts/game", a / "scripts/vscripts/game", True),
        (alyxlib_content_path / ".vscode", a / ".vscode", False),
        (alyxlib_content_path / "panorama/scripts/custom_game/panorama_lua.js", a / "panorama/scripts/custom_game/panorama_lua.js", False),
        (alyxlib_content_path / "panorama/scripts/custom_game/panoramadoc.js", a / "panorama/scripts/custom_game/panoramadoc.js", False),
        (a / "scripts", b / "scripts", False)
    ])
    create_modinit_script(a, b)
    create_sound_files(a, b)
    print("...Finished full addon setup (no Git)")

def MACRO_vscript_setup(a, b):
    print("Doing vscript only setup...")
    create_symlinks(a, b, [
        (alyxlib_content_path / "scripts/vlua_globals.lua", a / "scripts/vlua_globals.lua", True),
        (alyxlib_content_path / ".vscode", a / ".vscode", False),
        (a / "scripts", b / "scripts", False)
    ])
    print("...Finished vscript only setup")

class Macro:
    desc:str = ""
    func:Callable[[Path, Path], None] = None
    def __init__(self, desc:str, func:Callable[[Path, Path], None]):
        self.desc = desc
        self.func = func

macros = [
    Macro("Full Setup", MACRO_full_setup),
    Macro("Full Setup (no Git)", MACRO_scripts_nogit_setup),
    Macro("VScript Setup", MACRO_vscript_setup),
    Macro("Git Setup", init_git)
]

def perform_actions(addon_content_path: Path, addon_game_path: Path):
    while True:
        # i = 1
        # for macro in macros:
        #     print(f'{i}. {macro.desc}')
        #     i += 1

        choice = interface.get_list_selection([macro.desc for macro in macros], msg="Please choose an action to perform: ")
        if choice is None:
            return
        macro = next(macro for macro in macros if macro.desc == choice)

        clear_onupload_files()
        macro.func(addon_content_path, addon_game_path)
        write_onupload_file(addon_content_path / "on_upload.bat")

def main():
    choice = interface.get_list_selection([addon.name for addon in addons], msg="Please choose an addon to setup alyxlib: ")
    if choice is None:
        exit()
    if choice == "alyxlib":
        print("DO NOT MODIFY ALYXLIB")
        exit()
    addon_content_path = content_path / choice
    addon_game_path = game_path / choice

    print(f"\nAddon chosen: {addon_content_path.name}")

    perform_actions(addon_content_path, addon_game_path)


if __name__ == "__main__":
    main()