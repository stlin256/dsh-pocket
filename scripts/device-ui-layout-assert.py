#!/usr/bin/env python3
"""Inspect HarmonyOS uitest dumps for bottom-dock layout regressions."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


def parse_bounds(value: str) -> tuple[int, int, int, int]:
    match = re.fullmatch(r"\[(-?\d+),(-?\d+)\]\[(-?\d+),(-?\d+)\]", value or "")
    if not match:
        raise ValueError(f"invalid bounds: {value!r}")
    return tuple(int(part) for part in match.groups())  # type: ignore[return-value]


def walk(node: dict[str, Any], ancestors: list[dict[str, Any]] | None = None):
    current = (ancestors or []) + [node]
    yield node, current
    for child in node.get("children", []):
        yield from walk(child, current)


def label(node: dict[str, Any]) -> str:
    attributes = node.get("attributes", {})
    return " | ".join(
        value
        for value in (
            attributes.get("text", ""),
            attributes.get("accessibilityText", ""),
            attributes.get("originalText", ""),
        )
        if value
    )


def describe(node: dict[str, Any], depth: int = 0) -> str:
    attributes = node.get("attributes", {})
    text = label(node).replace("\n", " ")
    return (
        f"{'  ' * depth}{attributes.get('type', '?')} "
        f"{attributes.get('bounds', '?')} "
        f"z={attributes.get('zIndex', '?')} "
        f"enabled={attributes.get('enabled', '?')} "
        f"hit={attributes.get('hitTestBehavior', '?')} "
        f"{text[:100]}"
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("layout", type=Path)
    parser.add_argument("--match", action="append", default=[])
    parser.add_argument("--type", dest="node_type", default="")
    parser.add_argument("--require-composer-visible", action="store_true")
    args = parser.parse_args()

    root = json.loads(args.layout.read_text(encoding="utf-8"))
    if isinstance(root, list):
        root = root[0]
    _, _, _, screen_bottom = parse_bounds(root["attributes"]["bounds"])
    failures: list[str] = []
    found_composer = False

    for node, ancestors in walk(root):
        attributes = node["attributes"]
        text = label(node)
        type_matches = bool(args.node_type) and attributes.get("type") == args.node_type
        if type_matches:
            print("\n" + describe(node))
            left, top, right, bottom = parse_bounds(attributes["bounds"])
            if bottom > screen_bottom:
                failures.append(
                    f"{args.node_type} extends below screen: {bottom} > {screen_bottom}"
                )
        if (
            args.require_composer_visible
            and attributes.get("type") == "TextArea"
            and not found_composer
        ):
            left, top, right, bottom = parse_bounds(attributes["bounds"])
            found_composer = True
            print("\ncomposer TextArea")
            for depth, ancestor in enumerate(ancestors):
                print(describe(ancestor, depth))
            if top >= screen_bottom or bottom > screen_bottom:
                failures.append(
                    f"composer is outside the visible screen: {left},{top},{right},{bottom}"
                )
        if not text:
            continue
        if not args.match and args.node_type:
            continue
        should_match = not args.match or any(token in text for token in args.match)
        if not should_match:
            continue
        left, top, right, bottom = parse_bounds(node["attributes"]["bounds"])
        print(f"\n{text[:120] or '<unlabelled>'}")
        for depth, ancestor in enumerate(ancestors):
            print(describe(ancestor, depth))
        if bottom > screen_bottom:
            failures.append(f"{text!r} extends below screen: {bottom} > {screen_bottom}")
    if args.require_composer_visible and not found_composer:
        failures.append("composer TextArea was not present in the layout dump")

    if failures:
        for failure in failures:
            print(f"FAIL: {failure}", file=sys.stderr)
        return 1
    print("\nPASS: requested layout bounds are visible")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
