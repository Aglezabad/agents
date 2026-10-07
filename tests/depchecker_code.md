# Test Input: DEPCHECKER — dependency and license issues

Analyze this project. Report findings only — do not modify anything.

Project license: MIT (file `LICENSE` in the repo root). No network access is available; there are no vendored license files for third-party packages.

**pyproject.toml**

```toml
[project]
name = "acme-reporter"
license = {text = "MIT"}
dependencies = [
    "requests>=2.31",
    "gplpdf==1.2.0",       # PDF generation library, known GPL-3.0-only
    "mysticlog==0.9.1",    # logging helper, license unknown
    "rich>=13.0",          # known Apache-2.0, ships a NOTICE file
    "black>=24.0",
]

[dependency-groups]
dev = ["pytest>=8.0"]
```

There is no lockfile in the repository.

**src/acme_reporter/main.py**

```python
import requests
from rich.console import Console


def main():
    console = Console()
    data = requests.get("https://api.example.com/report").json()
    console.print(data["summary"])


if __name__ == "__main__":
    main()
```

**src/acme_reporter/pdf.py**

```python
import gplpdf


def render(report):
    return gplpdf.from_html(report["html"])
```

Notes:

- `mysticlog` appears nowhere in the source, scripts, CI, or docs.
- `black` is only referenced in the contributing guide as a formatting tool.
- The distribution model is a distributed binary wheel published to an internal index.
- There is no About page, acknowledgements file, or NOTICE content anywhere in the project.
