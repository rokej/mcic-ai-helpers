#!/usr/bin/env python3
"""
Check if an AI-assisted reply already exists for a PR comment or review thread.

Usage:
    check_replied.py <owner> <repo> <pr_number> <comment_id> --type <issue_comment|review_thread|review_comment>

Returns:
    Exit 0: Safe to reply (no existing bot reply found)
    Exit 1: Already replied
    Exit 2: Error occurred
"""

import argparse
import json
import subprocess
import sys
from typing import Any

# Known automation bot accounts (extend when CI bot is created)
BOT_SIGNATURES = [
    "mcic-jira-solve-ci[bot]",
    "mcic-jira-solve-ci",
]

REPLY_SIGNATURE = "*AI-assisted response via Claude Code*"


def run_gh(args: list[str]) -> Any:
    result = subprocess.run(
        ["gh"] + args,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"gh command failed: {result.stderr}")
    return json.loads(result.stdout) if result.stdout.strip() else None


def is_bot_reply(login: str, body: str) -> bool:
    if not login:
        return False
    if login in BOT_SIGNATURES:
        return True
    if body and REPLY_SIGNATURE in body:
        return True
    return False


def check_review_thread(owner: str, repo: str, pr_number: int, thread_id: str) -> dict:
    query = '''
    query($owner: String!, $repo: String!, $number: Int!, $cursor: String) {
      repository(owner: $owner, name: $repo) {
        pullRequest(number: $number) {
          reviewThreads(first: 100, after: $cursor) {
            nodes {
              id
              comments(first: 100) {
                nodes {
                  id
                  author { login }
                  body
                  createdAt
                }
              }
            }
            pageInfo { hasNextPage endCursor }
          }
        }
      }
    }
    '''

    all_threads = []
    cursor = None
    while True:
        args = [
            "api", "graphql",
            "-f", f"query={query}",
            "-f", f"owner={owner}",
            "-f", f"repo={repo}",
            "-F", f"number={pr_number}",
        ]
        if cursor:
            args.extend(["-f", f"cursor={cursor}"])
        result = run_gh(args)
        threads_data = result["data"]["repository"]["pullRequest"]["reviewThreads"]
        all_threads.extend(threads_data["nodes"])
        if not threads_data["pageInfo"]["hasNextPage"]:
            break
        cursor = threads_data["pageInfo"]["endCursor"]

    target_thread = next((t for t in all_threads if t["id"] == thread_id), None)
    if not target_thread:
        return {"safe_to_reply": True, "reason": "thread_not_found"}

    for comment in target_thread["comments"]["nodes"]:
        author = comment["author"]["login"] if comment["author"] else ""
        body = comment.get("body", "")
        if is_bot_reply(author, body):
            return {
                "safe_to_reply": False,
                "reason": "bot_already_replied",
                "existing_reply": {"author": author, "created_at": comment["createdAt"]},
            }

    return {"safe_to_reply": True, "reason": "no_bot_reply_found"}


def check_issue_comment(owner: str, repo: str, pr_number: int, comment_id: str) -> dict:
    comments = run_gh([
        "api", f"repos/{owner}/{repo}/issues/{pr_number}/comments", "--paginate"
    ])
    target = next((c for c in comments if str(c["id"]) == str(comment_id)), None)
    if not target:
        return {"safe_to_reply": True, "reason": "comment_not_found"}

    target_time = target["created_at"]
    for comment in comments:
        if comment["created_at"] <= target_time:
            continue
        author = comment["user"]["login"] if comment.get("user") else ""
        body = comment.get("body", "")
        if is_bot_reply(author, body):
            return {"safe_to_reply": False, "reason": "bot_replied_after"}

    return {"safe_to_reply": True, "reason": "no_bot_reply_after"}


def check_review_comment(owner: str, repo: str, pr_number: int, comment_id: str) -> dict:
    comments = run_gh([
        "api", f"repos/{owner}/{repo}/pulls/{pr_number}/comments", "--paginate"
    ])
    target_id = int(comment_id)
    for comment in comments:
        if comment.get("in_reply_to_id") == target_id:
            author = comment["user"]["login"] if comment.get("user") else ""
            body = comment.get("body", "")
            if is_bot_reply(author, body):
                return {"safe_to_reply": False, "reason": "bot_already_replied"}

    return {"safe_to_reply": True, "reason": "no_bot_reply_found"}


def main():
    parser = argparse.ArgumentParser(description="Check if bot already replied to a PR comment")
    parser.add_argument("owner")
    parser.add_argument("repo")
    parser.add_argument("pr_number", type=int)
    parser.add_argument("comment_id")
    parser.add_argument("--type", choices=["issue_comment", "review_thread", "review_comment"], required=True)
    args = parser.parse_args()

    try:
        if args.type == "review_thread":
            result = check_review_thread(args.owner, args.repo, args.pr_number, args.comment_id)
        elif args.type == "issue_comment":
            result = check_issue_comment(args.owner, args.repo, args.pr_number, args.comment_id)
        else:
            result = check_review_comment(args.owner, args.repo, args.pr_number, args.comment_id)

        print(json.dumps(result, indent=2))
        sys.exit(0 if result.get("safe_to_reply", False) else 1)
    except (RuntimeError, KeyError, TypeError, ValueError) as e:
        print(json.dumps({"error": str(e), "safe_to_reply": False, "reason": "error"}, indent=2))
        sys.exit(2)


if __name__ == "__main__":
    main()
