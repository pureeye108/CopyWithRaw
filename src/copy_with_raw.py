#!/usr/bin/env python3
"""
Copy with RAW - Cross-platform core script
Copies JPEG/RAW photo pairs (and XMP sidecars) together.

Usage:
    copy_with_raw.py [options] file1 [file2 ...]

On macOS/Linux all selected files are passed as arguments directly.
On Windows this is called by the PowerShell wrapper.
"""

import os
import sys
import shutil
import argparse
import platform
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox, simpledialog

RAW_EXTENSIONS  = {'.nef', '.nrw', '.cr2', '.cr3', '.crw', '.arw',
                   '.srf', '.sr2', '.dng', '.raf', '.orf', '.rw2', '.pef', '.srw'}
JPEG_EXTENSIONS = {'.jpg', '.jpeg'}


# ---------------------------------------------------------------------------
# File matching logic
# ---------------------------------------------------------------------------

def find_associated_files(selected_files):
    """Given a list of selected file paths, return all files that should be copied."""
    to_copy = {}   # use dict to deduplicate while preserving order

    for file_path in selected_files:
        file_path = os.path.abspath(file_path)
        if not os.path.isfile(file_path):
            continue

        to_copy[file_path] = True
        ext       = os.path.splitext(file_path)[1].lower()
        base_name = os.path.splitext(os.path.basename(file_path))[0]
        dir_path  = os.path.dirname(file_path)

        try:
            dir_entries = os.listdir(dir_path)
        except OSError:
            continue

        if ext in JPEG_EXTENSIONS:
            # JPEG selected → find matching RAW (prefix match, longest wins)
            best_raw, best_len = None, 0
            for entry in dir_entries:
                entry_ext  = os.path.splitext(entry)[1].lower()
                entry_base = os.path.splitext(entry)[0]
                if entry_ext in RAW_EXTENSIONS:
                    if base_name.lower().startswith(entry_base.lower()) and len(entry_base) > best_len:
                        best_len = len(entry_base)
                        best_raw = os.path.join(dir_path, entry)

            if best_raw:
                to_copy[best_raw] = True
                raw_base = os.path.splitext(os.path.basename(best_raw))[0]
                raw_name = os.path.basename(best_raw)
                for xmp in [raw_base + '.xmp', raw_name + '.xmp']:
                    p = os.path.join(dir_path, xmp)
                    if os.path.isfile(p):
                        to_copy[p] = True

            # JPEG own XMP
            jpeg_xmp = os.path.join(dir_path, base_name + '.xmp')
            if os.path.isfile(jpeg_xmp):
                to_copy[jpeg_xmp] = True

        elif ext in RAW_EXTENSIONS:
            # RAW selected → find matching JPEGs (JPEG name starts with RAW base)
            for entry in dir_entries:
                entry_ext  = os.path.splitext(entry)[1].lower()
                entry_base = os.path.splitext(entry)[0]
                if entry_ext in JPEG_EXTENSIONS:
                    if entry_base.lower().startswith(base_name.lower()):
                        to_copy[os.path.join(dir_path, entry)] = True

            # RAW XMP sidecars
            raw_name = os.path.basename(file_path)
            for xmp in [base_name + '.xmp', raw_name + '.xmp']:
                p = os.path.join(dir_path, xmp)
                if os.path.isfile(p):
                    to_copy[p] = True

    return list(to_copy.keys())


# ---------------------------------------------------------------------------
# GUI helpers (tkinter - built into Python on all platforms)
# ---------------------------------------------------------------------------

def _make_root():
    root = tk.Tk()
    root.withdraw()
    root.attributes('-topmost', True)
    return root


def pick_folder(title, initial_dir=None):
    root = _make_root()
    folder = filedialog.askdirectory(title=title, initialdir=initial_dir or os.path.expanduser('~'))
    root.destroy()
    return folder or None


def ask_subfolder(root_window=None):
    root = _make_root()
    name = simpledialog.askstring('Subfolder', 'Enter a subfolder name (or leave blank to copy directly):', parent=root)
    root.destroy()
    return name.strip() if name else ''


def show_info(title, msg):
    root = _make_root()
    messagebox.showinfo(title, msg, parent=root)
    root.destroy()


def show_error(title, msg):
    root = _make_root()
    messagebox.showerror(title, msg, parent=root)
    root.destroy()


# ---------------------------------------------------------------------------
# Copy + open
# ---------------------------------------------------------------------------

def copy_files(paths, dest_folder):
    os.makedirs(dest_folder, exist_ok=True)
    copied = errors = 0
    for path in paths:
        try:
            shutil.copy2(path, os.path.join(dest_folder, os.path.basename(path)))
            copied += 1
        except Exception as e:
            errors += 1
    return copied, errors


def open_folder(path):
    system = platform.system()
    if system == 'Darwin':
        subprocess.run(['open', path])
    elif system == 'Linux':
        subprocess.run(['xdg-open', path])
    else:
        subprocess.run(['explorer', path])


# ---------------------------------------------------------------------------
# Read config from platform-appropriate location
# ---------------------------------------------------------------------------

def read_config():
    """Read WL destination and default picker folder from config file."""
    config = {'wl_destination': '', 'default_picker': ''}
    system = platform.system()

    if system == 'Windows':
        try:
            import winreg
            key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r'SOFTWARE\CopyWithRAW')
            config['wl_destination'], _ = winreg.QueryValueEx(key, 'WLDestination')
            config['default_picker'], _ = winreg.QueryValueEx(key, 'DefaultPickerFolder')
            winreg.CloseKey(key)
        except Exception:
            pass
    else:
        config_path = os.path.expanduser('~/.config/CopyWithRAW/config.ini')
        if os.path.isfile(config_path):
            import configparser
            cfg = configparser.ConfigParser()
            cfg.read(config_path)
            config['wl_destination'] = cfg.get('Paths', 'WLDestination', fallback='')
            config['default_picker'] = cfg.get('Paths', 'DefaultPickerFolder', fallback='')

    return config


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description='Copy RAW/JPEG pairs together')
    parser.add_argument('files', nargs='+', help='Selected photo files')
    parser.add_argument('--dest',                 default='',    help='Fixed destination (or "WL:" to use configured WL folder)')
    parser.add_argument('--default-picker',       default='',    help='Default folder for the picker dialog (or "PICKER:")')
    parser.add_argument('--auto-subfolder',       action='store_true', help='Auto-create subfolder named after source folder')
    parser.add_argument('--skip-subfolder-prompt',action='store_true', help='Skip subfolder prompt entirely')
    parser.add_argument('--open-destination',     action='store_true', help='Open destination folder after copy')
    args = parser.parse_args()

    # Resolve config tokens
    config = read_config()
    dest         = config['wl_destination']  if args.dest           == 'WL:'     else args.dest
    default_pick = config['default_picker']  if args.default_picker == 'PICKER:' else args.default_picker

    # Gather all files to copy
    paths = find_associated_files(args.files)
    if not paths:
        show_info('Copy with RAW', 'No matching JPEG or RAW files found.')
        return

    # Determine destination folder
    if dest:
        dest_folder = dest
    else:
        dest_folder = pick_folder(f'Select destination for {len(paths)} files', initial_dir=default_pick or None)
    if not dest_folder:
        return

    # Subfolder handling
    if args.auto_subfolder:
        source_dir  = os.path.dirname(os.path.abspath(args.files[0]))
        dest_folder = os.path.join(dest_folder, os.path.basename(source_dir))
    elif not args.skip_subfolder_prompt:
        sub = ask_subfolder()
        if sub:
            dest_folder = os.path.join(dest_folder, sub)

    # Copy
    copied, errors = copy_files(paths, dest_folder)

    msg = f'Successfully copied {copied} file(s) to:\n{dest_folder}'
    if errors:
        msg += f'\n\nFailed to copy {errors} file(s).'
    show_info('Copy with RAW', msg)

    if args.open_destination:
        open_folder(dest_folder)


if __name__ == '__main__':
    main()
