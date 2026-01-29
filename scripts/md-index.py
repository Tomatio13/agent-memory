#!/usr/bin/env python3
"""Lightweight Markdown CLI for heading tree and section extraction."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass, field
from typing import List, Optional


HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
FENCE_RE = re.compile(r"^(?P<fence>`{3,}|~{3,})")


@dataclass
class Heading:
    level: int
    text: str
    offset: int
    line_end: int


@dataclass
class Node:
    heading: Heading
    children: List["Node"] = field(default_factory=list)


def normalize_heading_text(text: str) -> str:
    # Strip trailing closing hashes (e.g. "Title ###") and surrounding whitespace.
    cleaned = re.sub(r"\s*#+\s*$", "", text).strip()
    return cleaned


def parse_headings(content: str) -> List[Heading]:
    headings: List[Heading] = []
    offset = 0
    in_fence: Optional[str] = None

    for line in content.splitlines(keepends=True):
        stripped = line.rstrip("\n")
        fence_match = FENCE_RE.match(stripped.strip())
        if fence_match:
            fence = fence_match.group("fence")
            if in_fence is None:
                in_fence = fence[0]  # '`' or '~'
            elif in_fence == fence[0]:
                in_fence = None
            # Fences can coexist with headings, but we do not parse headings inside.
        if in_fence is None:
            match = HEADING_RE.match(stripped)
            if match:
                level = len(match.group(1))
                text = normalize_heading_text(match.group(2))
                line_end = offset + len(line)
                headings.append(Heading(level=level, text=text, offset=offset, line_end=line_end))
        offset += len(line)

    return headings


def build_tree(headings: List[Heading]) -> List[Node]:
    roots: List[Node] = []
    stack: List[Node] = []

    for heading in headings:
        node = Node(heading=heading)
        while stack and stack[-1].heading.level >= heading.level:
            stack.pop()
        if stack:
            stack[-1].children.append(node)
        else:
            roots.append(node)
        stack.append(node)

    return roots


def render_tree(nodes: List[Node], prefix: str = "") -> None:
    for idx, node in enumerate(nodes):
        is_last = idx == len(nodes) - 1
        connector = "└─ " if is_last else "├─ "
        marker = "#" * node.heading.level
        print(f"{prefix}{connector}{marker} {node.heading.text}")
        child_prefix = f"{prefix}{'   ' if is_last else '│  '}"
        render_tree(node.children, child_prefix)


def extract_section(content: str, headings: List[Heading], section_name: str) -> str:
    target = section_name.strip().lower()
    exact_index = next(
        (i for i, h in enumerate(headings) if h.text.lower() == target),
        None,
    )
    if exact_index is not None:
        heading_index = exact_index
    else:
        partial_matches = [
            i for i, h in enumerate(headings) if target in h.text.lower()
        ]
        if not partial_matches:
            raise ValueError(f"Section '{section_name}' not found")
        if len(partial_matches) > 1:
            matches = ", ".join(headings[i].text for i in partial_matches[:5])
            suffix = "..." if len(partial_matches) > 5 else ""
            raise ValueError(
                f"Section '{section_name}' matched multiple headings: {matches}{suffix}"
            )
        heading_index = partial_matches[0]

    heading = headings[heading_index]
    content_start = content.find("\n", heading.offset)
    if content_start == -1:
        content_start = len(content)
    else:
        content_start += 1

    next_heading = next(
        (h for h in headings[heading_index + 1 :] if h.level <= heading.level),
        None,
    )
    end = next_heading.offset if next_heading else len(content)

    return content[content_start:end].strip()


def read_input(path: Optional[str]) -> str:
    if path:
        if path == "-":
            return sys.stdin.read()
        with open(path, "r", encoding="utf-8") as fh:
            return fh.read()

    if not sys.stdin.isatty():
        return sys.stdin.read()

    raise ValueError("No input provided. Specify a file or pipe stdin.")


def parse_args(argv: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="treemd-lite",
        description="Lightweight Markdown CLI for heading tree and section extraction.",
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--tree", action="store_true", help="Show heading tree")
    group.add_argument(
        "-s",
        "--section",
        metavar="HEADING",
        help="Extract specific section by heading name",
    )
    parser.add_argument("file", nargs="?", help="Markdown file path (or '-' for stdin)")
    return parser.parse_args(argv)


def main(argv: List[str]) -> int:
    try:
        args = parse_args(argv)
        content = read_input(args.file)
        headings = parse_headings(content)

        if args.tree:
            tree = build_tree(headings)
            render_tree(tree)
            return 0

        section_content = extract_section(content, headings, args.section)
        print(section_content)
        return 0

    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
