#!/usr/bin/env python3
# flake8: noqa: E501
import json
import os
import shutil
import sys
import time
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Optional

MAX_WIDTH = 60
SAFE_DIRECTORY_NAME = "ix-safe"


class ActionMode(Enum):
    """Valid action modes."""

    ALWAYS = "always"
    CHECK = "check"


class FileMode:
    """File mode with validation and consistent formatting."""

    def __init__(self, mode_str: str = ""):
        """
        Initialize FileMode from octal string.

        Args:
            mode_str: Octal mode string (e.g., "0755"). Must start with "0".

        Raises:
            ValueError: If mode string is invalid or doesn't start with "0"
        """
        self._mode = 0
        if mode_str:
            if not mode_str.startswith("0"):
                raise ValueError(
                    f"Invalid file mode format: {mode_str}. Mode must start with '0' (e.g., '0755')"
                )

            try:
                self._mode = int(mode_str, 8)
            except ValueError as e:
                raise ValueError(f"Invalid file mode format: {mode_str}") from e

            # Validate range
            if self._mode > 0o777:
                raise ValueError(f"File mode out of range: {mode_str}")

    @property
    def mode(self) -> int:
        """Get the integer mode value."""
        return self._mode

    def __str__(self) -> str:
        if self._mode == 0:
            return "0"
        return f"0{oct(self._mode)[2:]}"

    def __bool__(self) -> bool:
        """Check if mode is set (non-zero)."""
        return self._mode != 0


@dataclass
class Action:
    """Action configuration with validation."""

    identifier: str
    path: str
    is_temporary: bool
    read_only: bool
    mode: ActionMode
    uid: int
    gid: int
    chmod: FileMode
    recursive: bool

    @classmethod
    def from_dict(cls, data: dict) -> "Action":
        """
        Create Action from dictionary with validation.

        Args:
            data: Dictionary from JSON

        Returns:
            Validated Action instance

        Raises:
            ValueError: If validation fails
        """
        # Validate and parse mode
        mode_str = data.get("mode", "")
        try:
            mode = ActionMode(mode_str)
        except ValueError:
            raise ValueError(
                f"Invalid action mode '{mode_str}' in action '{data.get('identifier', 'unknown')}'"
            )

        # Validate and parse chmod
        chmod_str = data.get("chmod", "")
        try:
            chmod = FileMode(chmod_str)
        except ValueError as e:
            raise ValueError(
                f"Invalid chmod in action '{data.get('identifier', 'unknown')}': {e}"
            )

        return cls(
            identifier=data["identifier"],
            path=data["mount_path"],
            is_temporary=data.get("is_temporary", False),
            read_only=data.get("read_only", False),
            mode=mode,
            uid=data.get("uid", 0),
            gid=data.get("gid", 0),
            chmod=chmod,
            recursive=data.get("recursive", False),
        )


def load_actions(path: str = "/script/actions.json") -> list[Action]:
    """
    Load and validate actions from JSON file.

    Args:
        path: Path to actions.json file

    Returns:
        List of validated Action objects

    Raises:
        SystemExit: If file cannot be loaded or validation fails
    """
    try:
        with open(path, "r") as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"❌ Error: Actions file not found: {path}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"❌ Error: Invalid JSON in {path}: {e}")
        sys.exit(1)

    if not data:
        print("❌ Error: No actions data found")
        sys.exit(1)

    actions: list[Action] = []
    for item in data:
        try:
            actions.append(Action.from_dict(item))
        except Exception as e:
            print(f"❌ Error loading action {item.get('identifier', 'unknown')}: {e}")
            sys.exit(1)

    return actions


class Logger:
    def __init__(self, identifier: str = ""):
        self.identifier = identifier

    def log(self, message: str):
        """Log a message with context prefix."""
        print(message)

    def header(self):
        total_width = MAX_WIDTH
        # Account for spaces around identifier
        remaining = total_width - len(self.identifier) - 2
        if remaining < 0:
            # Identifier too long, just print with minimal dashes
            print(f"- {self.identifier} -")
        else:
            left_dashes = remaining // 2
            right_dashes = remaining - left_dashes
            print(f"{'-' * left_dashes} {self.identifier} {'-' * right_dashes}")

    def separator(self, char: str = "="):
        """Print a separator line."""
        print(char * MAX_WIDTH)


def fix_ownership(path: str, uid: int, gid: int, recursive: bool):
    """
    Fix ownership of a path.

    Args:
        path: Path to modify
        uid: Target user ID
        gid: Target group ID
        recursive: Whether to apply recursively
    """
    os.chown(path, uid, gid)
    if recursive:
        for root, dirs, files in os.walk(path):
            for d in dirs:
                os.chown(os.path.join(root, d), uid, gid)
            for f in files:
                os.chown(os.path.join(root, f), uid, gid)


def fix_permissions(path: str, mode: FileMode, recursive: bool):
    """
    Fix permissions of a path.

    Args:
        path: Path to modify
        mode: Target file mode
        recursive: Whether to apply recursively
    """
    os.chmod(path, mode.mode)
    if recursive:
        for root, dirs, files in os.walk(path):
            for d in dirs:
                os.chmod(os.path.join(root, d), mode.mode)
            for f in files:
                os.chmod(os.path.join(root, f), mode.mode)


def apply_action(action: Action) -> Optional[str]:
    """
    Apply a single action.

    Args:
        action: Action to apply

    Returns:
        Error message if failed, None if successful
    """
    logger = Logger(action.identifier)
    logger.header()
    if action.read_only:
        logger.log("🔒 Status: READ-ONLY - Skipping...")
        logger.separator("=")
        return None
    start_time = time.time()
    path = Path(action.path)
    if not path.exists():
        return f"Path does not exist: {action.path}"
    if not path.is_dir():
        logger.log(f"⚠️  Path is not a directory, skipping...")
        logger.separator("=")
        return None
    if action.is_temporary:
        logger.log("🗑️  Temporary directory - ensuring it is empty...")
        for item in path.iterdir():
            if item.name == SAFE_DIRECTORY_NAME:
                continue
            try:
                if item.is_dir():
                    shutil.rmtree(item)
                else:
                    item.unlink()
            except Exception as e:
                logger.log(f"❌ Error deleting {item}: {e}")
                logger.separator("=")
                return f"Failed to delete {item}: {e}"
    else:
        if any(path.iterdir()):
            logger.log("⏭️  Path is not empty, no changes will be applied")
            logger.separator("=")
            return None
    si = os.stat(action.path)
    curr_mode = FileMode(f"0{oct(si.st_mode)[-3:]}")
    target_mode = action.chmod if action.chmod else curr_mode
    recursive_indicator = " [recursive]" if action.recursive else ""

    # Determine if changes should be made
    should_change_ownership = si.st_uid != action.uid or si.st_gid != action.gid
    should_change_perms = action.chmod and curr_mode.mode != action.chmod.mode

    if action.mode == ActionMode.ALWAYS:
        # ALWAYS mode applies unconditionally
        mode_desc = "Always. Applies changes regardless of current state"
        own_log = f"👤 Ownership: [{si.st_uid}:{si.st_gid}] -> [{action.uid}:{action.gid}]{recursive_indicator} [will apply]"
        perm_log = f"🔐 Permissions: [{curr_mode}] [no change]"
        if action.chmod:
            perm_log = f"🔐 Permissions: [{curr_mode}] -> [{target_mode}] [will apply]"
    elif action.mode == ActionMode.CHECK:
        mode_desc = "Check. Only applies changes if are incorrect"
        # CHECK mode only applies if needed
        own_log = f"👤 Ownership: [{si.st_uid}:{si.st_gid}] [no change]"
        if should_change_ownership:
            own_log = f"👤 Ownership: [{si.st_uid}:{si.st_gid}] -> [{action.uid}:{action.gid}]{recursive_indicator} [will change]"

        perm_log = f"🔐 Permissions: [{curr_mode}] [no change]"
        if should_change_perms:
            perm_log = f"🔐 Permissions: [{curr_mode}] -> [{target_mode}] [will change]"

    logger.log(own_log)
    logger.log(perm_log)
    logger.log(f"⚙️  Mode: {mode_desc}")
    try:
        if action.mode == ActionMode.ALWAYS:
            fix_ownership(action.path, action.uid, action.gid, action.recursive)
            if not action.chmod:
                logger.log(
                    "⏭️  Permissions will remain unchanged (chmod not configured)"
                )
            else:
                fix_permissions(action.path, action.chmod, action.recursive)

        elif action.mode == ActionMode.CHECK:
            if should_change_ownership:
                fix_ownership(action.path, action.uid, action.gid, action.recursive)
            if not action.chmod:
                logger.log(
                    "⏭️  Permissions will remain unchanged (chmod not configured)"
                )
            elif should_change_perms:
                fix_permissions(action.path, action.chmod, action.recursive)
        si = os.stat(action.path)
        final_mode = FileMode(f"0{oct(si.st_mode)[-3:]}")
        logger.log(f"📊 Final: 👤 [{si.st_uid}:{si.st_gid}] 🔐 [{final_mode}]")
        logger.log(f"⏱️  Time taken: {(time.time() - start_time) * 1000:.2f}ms")
        logger.separator("=")
        return None
    except Exception as e:
        return f"Failed to apply action: {e}"


def main():
    """Main entry point."""
    start_time = time.time()
    print("🚀 Starting permissions configuration...")
    actions = load_actions()
    errors = []
    for action in actions:
        error = apply_action(action)
        if error:
            errors.append(f"❌ Error applying action [{action.identifier}]: {error}")
        print()
    if errors:
        print(f"\n❌ Encountered {len(errors)} errors during execution:")
        for error in errors:
            print(f"  • {error}")
        print("\n💥 Execution failed with errors")
        sys.exit(1)
    print(f"\n⏱️  Total time taken: {(time.time() - start_time) * 1000:.2f}ms")
    print("🎉 All permissions configured successfully!")


if __name__ == "__main__":
    main()
