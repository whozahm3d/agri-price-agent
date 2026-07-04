# ==============================================================================
# Makefile — Pakistan Crop Prices Time-Series Analysis
# Usage: make <target>
# ==============================================================================

.DEFAULT_GOAL := help
PYTHON        := python3
PIP           := pip
NOTEBOOK      := notebooks/DM_Project_Final_Deliverable.ipynb
VENV_DIR      := venv

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------
.PHONY: help
help:
	@echo ""
	@echo "  Pakistan Crop Prices — Time-Series Analysis"
	@echo "  ============================================"
	@echo ""
	@echo "  Setup"
	@echo "    make venv          Create virtual environment"
	@echo "    make install       Install all dependencies"
	@echo "    make setup         venv + install (full first-time setup)"
	@echo ""
	@echo "  Data"
	@echo "    make data          Download dataset from Kaggle"
	@echo ""
	@echo "  Run"
	@echo "    make run           Execute the full notebook end-to-end"
	@echo "    make all           setup + data + run (one command from scratch)"
	@echo ""
	@echo "  Quality"
	@echo "    make lint          Run flake8 linter"
	@echo "    make format        Auto-format with black"
	@echo "    make check-format  Check formatting without modifying files"
	@echo ""
	@echo "  Maintenance"
	@echo "    make clean         Clear notebook outputs (required before git push)"
	@echo "    make clean-results Remove generated CSVs and figures"
	@echo "    make clean-all     clean + clean-results + remove venv"
	@echo ""

# ------------------------------------------------------------------------------
# Setup
# ------------------------------------------------------------------------------
.PHONY: venv
venv:
	@echo "[setup] Creating virtual environment at $(VENV_DIR)/ ..."
	$(PYTHON) -m venv $(VENV_DIR)
	@echo "[setup] Activate with:  source $(VENV_DIR)/bin/activate"

.PHONY: install
install:
	@echo "[setup] Installing dependencies from requirements.txt ..."
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	$(PIP) install flake8 black
	@echo "[setup] All dependencies installed."

.PHONY: setup
setup: venv install
	@echo "[setup] Environment ready."

# ------------------------------------------------------------------------------
# Data
# ------------------------------------------------------------------------------
.PHONY: data
data:
	@echo "[data] Downloading dataset from Kaggle ..."
	@$(PYTHON) -c "import kaggle" 2>/dev/null || \
		(echo "ERROR: kaggle package not found. Install with: pip install kaggle" && exit 1)
	@$(PYTHON) -c "import os; assert os.path.exists(os.path.expanduser('~/.kaggle/kaggle.json')), \
		'ERROR: ~/.kaggle/kaggle.json not found. Generate an API token at kaggle.com/account.'" 
	mkdir -p data/raw
	kaggle datasets download -d humairarana/crop-prices-dataset-of-pakistan \
		--path data/raw --unzip
	@echo "[data] Dataset downloaded to data/raw/"
	@echo "[data] Update DATA_DIR in notebook Cell 4 to point to data/raw/"

# ------------------------------------------------------------------------------
# Run
# ------------------------------------------------------------------------------
.PHONY: run
run:
	@echo "[run] Executing notebook: $(NOTEBOOK) ..."
	$(PYTHON) -m jupyter nbconvert \
		--to notebook \
		--execute \
		--inplace \
		--ExecutePreprocessor.timeout=3600 \
		$(NOTEBOOK)
	@echo "[run] Notebook execution complete. Outputs saved to results/"

# ------------------------------------------------------------------------------
# Full Pipeline (one command)
# ------------------------------------------------------------------------------
.PHONY: all
all: setup data run
	@echo ""
	@echo "  Pipeline complete."
	@echo "  Results : results/outputs/"
	@echo "  Figures : results/figures/"
	@echo ""

# ------------------------------------------------------------------------------
# Code Quality
# ------------------------------------------------------------------------------
.PHONY: lint
lint:
	@echo "[lint] Running flake8 ..."
	flake8 . \
		--max-line-length=100 \
		--exclude=venv,.venv,__pycache__,notebooks \
		--extend-ignore=E203,W503 \
		--statistics
	@echo "[lint] flake8 passed."

.PHONY: format
format:
	@echo "[format] Running black ..."
	black . --exclude "/(\.git|venv|__pycache__|notebooks)/"
	@echo "[format] Formatting applied."

.PHONY: check-format
check-format:
	@echo "[format] Checking formatting with black (read-only) ..."
	black --check --diff . --exclude "/(\.git|venv|__pycache__|notebooks)/"

# ------------------------------------------------------------------------------
# Maintenance
# ------------------------------------------------------------------------------
.PHONY: clean
clean:
	@echo "[clean] Clearing notebook outputs ..."
	$(PYTHON) -m jupyter nbconvert \
		--clear-output \
		--inplace \
		notebooks/DM_Project_Deliverable_1.ipynb \
		$(NOTEBOOK)
	@echo "[clean] Notebook outputs cleared. Safe to commit."

.PHONY: clean-results
clean-results:
	@echo "[clean] Removing generated results (CSVs and figures) ..."
	rm -rf results/outputs/*.csv
	rm -rf results/figures/EDA/*
	rm -rf results/figures/Decomposition/*
	rm -rf results/figures/Modeling/*
	rm -rf results/figures/Comparison/*
	rm -rf results/figures/Clustering/*
	@echo "[clean] Results cleared. Re-run 'make run' to regenerate."

.PHONY: clean-all
clean-all: clean clean-results
	@echo "[clean] Removing virtual environment ..."
	rm -rf $(VENV_DIR)
	@echo "[clean] Full clean complete."
