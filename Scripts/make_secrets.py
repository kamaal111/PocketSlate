import json
import sys
from functools import reduce
from getopt import getopt
from pathlib import Path


def parse_opts(shortopts: list[str] = [], longopts: list[str] = []) -> dict[str, str]:
    argv = sys.argv[1:]
    unique_shortopts = set(shortopts)
    unique_longopts = set(longopts)
    given_opts = unique_shortopts.union(unique_longopts)
    opts, _ = getopt(
        argv, ":".join(unique_shortopts) + ":", map(lambda x: f"{x}=", unique_longopts)
    )
    opts_dict = {}
    for opt, arg in opts:
        if arg == "":
            continue

        for given_opt in given_opts:
            opt = opt.replace("-", "", 2)
            if opt != given_opt:
                continue

            opts_dict[given_opt] = arg
            break

    return opts_dict


def main():
    output_keys = ["api_key", "api_url", "github_token"]
    opts = parse_opts(longopts=["output"] + output_keys)
    output = opts.get("output")
    if not output:
        raise Exception("No output provied")

    secrets = json.dumps(
        reduce(lambda acc, key: {**acc, key: opts.get(key)}, output_keys, {})
    )

    output_path = Path(output)
    output_path.write_text(secrets)
    print("successfully written secrets")


if __name__ == "__main__":
    main()
