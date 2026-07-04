# Contributing to Pakistan Crop Prices — Time-Series Analysis

Thank you for taking the time to contribute. This document outlines the process for reporting issues, proposing changes, and submitting pull requests. Please read it before opening any issue or PR.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Reporting Issues](#reporting-issues)
- [Proposing Changes](#proposing-changes)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Notebook Guidelines](#notebook-guidelines)
- [Commit Message Format](#commit-message-format)
- [Project Maintainers](#project-maintainers)

---

## Code of Conduct

This project follows a standard open-source code of conduct. Be respectful, constructive, and inclusive in all interactions. Harassment of any kind will not be tolerated.

---

## Getting Started

### 1. Fork and clone the repository

```bash
git clone https://github.com/<your-username>/Time-Series-Data-Analysis-and-Trend-Discovery-in-Pakistan-Crop-Prices.git
cd Time-Series-Data-Analysis-and-Trend-Discovery-in-Pakistan-Crop-Prices
```

### 2. Create a virtual environment

```bash
python -m venv venv
source venv/bin/activate        # Linux / macOS
venv\Scripts\activate           # Windows
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
pip install flake8 black        # linting tools for development
```

### 4. Download the dataset

Follow the instructions in [`data/README.txt`](data/README.txt) to download the dataset from Kaggle and configure the `DATA_DIR` path in the notebook.

---

## Reporting Issues

Before opening a new issue:

- Search [existing issues](../../issues) to avoid duplicates
- Include your Python version (`python --version`) and OS
- If reporting a bug, include the full traceback and the cell number where it occurs
- If reporting incorrect results, attach the relevant CSV from `results/outputs/`

Use the following labels when filing issues:

| Label | When to use |
|-------|-------------|
| `bug` | Something produces an error or wrong output |
| `data` | Issue related to dataset loading or schema |
| `enhancement` | Suggesting a new feature or model |
| `documentation` | Typo, missing section, or unclear explanation |
| `performance` | Memory usage, runtime, or scalability concern |

---

## Proposing Changes

For non-trivial changes (new models, new phases, structural refactoring):

1. Open an issue first and describe what you intend to change and why
2. Wait for a maintainer to acknowledge and label it before starting work
3. Reference the issue in your PR: `Closes #<issue-number>`

For small fixes (typos, broken paths, pinned versions):
- Open a PR directly — no issue needed

---

## Pull Request Process

1. **Branch off `main`** using a descriptive branch name:

```bash
git checkout -b feature/add-prophet-model
git checkout -b fix/requirements-version-conflict
git checkout -b docs/update-phase3-readme
```

2. **Make your changes** following the [coding standards](#coding-standards) below

3. **Run linting before committing:**

```bash
black --check .
flake8 . --max-line-length=100 --exclude=venv,__pycache__
```

4. **Clear notebook outputs before committing:**

```bash
jupyter nbconvert --clear-output --inplace notebooks/DM_Project_Final_Deliverable.ipynb
```

5. **Push and open a PR** against the `main` branch with:
   - A clear title summarizing the change
   - A short description of what changed and why
   - Reference to the related issue (if applicable)
   - Screenshots or metric comparisons for result-changing contributions

6. **At least one maintainer review** is required before merging

---

## Coding Standards

All `.py` files must pass the following before merging:

| Tool | Rule |
|------|------|
| `black` | Auto-formatter — run `black .` to fix formatting |
| `flake8` | Max line length 100, no unused imports |
| Naming | `snake_case` for functions and variables, `UPPER_CASE` for constants |
| Docstrings | All public functions must have a one-line docstring minimum |
| Type hints | Encouraged for function signatures |

Example of acceptable function style:

```python
def compute_mape(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    """Return Mean Absolute Percentage Error between true and predicted values."""
    mask = y_true != 0
    return np.mean(np.abs((y_true[mask] - y_pred[mask]) / y_true[mask])) * 100
```

---

## Notebook Guidelines

- **Cell order matters** — all notebooks must run cleanly top-to-bottom via `Kernel → Restart & Run All`
- **No committed outputs** — clear all cell outputs before pushing (`make clean` handles this)
- **One notebook per phase** is preferred; do not merge unrelated analysis into existing notebooks
- **Magic commands** (`%timeit`, `%matplotlib inline`) are acceptable; shell commands (`!pip install`) inside notebooks are not — add to `requirements.txt` instead
- **Markdown cells** should accompany every major code section explaining what the cell does and why

---

## Commit Message Format

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <short summary>

[optional body]
[optional footer: Closes #issue]
```

**Types:**

| Type | When to use |
|------|-------------|
| `feat` | A new model, phase, or analysis |
| `fix` | A bug fix or incorrect result correction |
| `docs` | README, CONTRIBUTING, or docstring changes |
| `refactor` | Code restructuring with no behaviour change |
| `chore` | Dependency updates, CI config, tooling |
| `perf` | Performance improvement (memory, speed) |

**Examples:**

```
feat(modeling): add Prophet model to Phase 2 forecasting pipeline
fix(phase1): correct Winsorization bounds applied per city instead of globally
docs(readme): add clustering silhouette scores to results table
chore(deps): pin xgboost to 2.0.3 in requirements.txt
```

---

## Project Maintainers

| Name | GitHub | Role |
|------|--------|------|
| Ali Ahmad | [@whozahm3d](https://github.com/whozahm3d) | Lead |
| Taha Nawaz | — | Contributor |
| Shahzeb Imran | — | Contributor |

For questions not suited to a GitHub issue, open a discussion in the [Discussions](../../discussions) tab.
