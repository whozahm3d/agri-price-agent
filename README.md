# Pakistan Agricultural Price Intelligence Agent

![Python](https://img.shields.io/badge/python-3.12-blue)
![ADK](https://img.shields.io/badge/Google_ADK-2.3.0-green)
![MCP](https://img.shields.io/badge/protocol-MCP-purple)
![License](https://img.shields.io/badge/license-MIT-lightgrey)
![Status](https://img.shields.io/badge/status-capstone_submission-orange)

A multi-agent system that turns 7.99 million Pakistani crop-price records into plain-language buy/sell recommendations for farmers — built on Google's Agent Development Kit (ADK), the Model Context Protocol (MCP), and Gemini.

Capstone project for Kaggle's **5-Day AI Agents: Intensive Vibe Coding Course with Google**.

---

## Overview

Pakistan's agricultural sector employs nearly half the country's workforce, yet the price data that could help farmers make informed selling decisions is scattered across years of market records and inaccessible to the people who need it most.

This system takes a farmer's question in plain language — *"Should I sell my wheat now, or wait?"* — and answers it by coordinating four specialist agents: one that retrieves the relevant historical data, one that forecasts where prices are heading, one that turns that forecast into a concrete recommendation, and an orchestrator that ties the three together.

## Architecture

```
                    ┌─────────────────────────┐
                    │  agri_price_orchestrator │
                    │   (routes & coordinates) │
                    └───────────┬─────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                        │
┌───────▼────────┐    ┌─────────▼──────────┐   ┌─────────▼──────────┐
│   data_agent    │    │ forecasting_agent  │   │ recommendation_agent│
│                 │    │                    │   │                     │
│ • get_price_    │    │ • forecast_prices  │   │ • generate_         │
│   history       │    │ • summarise_       │   │   recommendation    │
│ • compare_crops_│    │   forecast         │   │ • generate_market_  │
│   by_city       │    │                    │   │   strategy          │
│ • MCP tools ──┐ │    └────────────────────┘   └─────────────────────┘
└───────────────┼┘
                 │
        ┌────────▼──────────┐
        │    MCP Server      │
        │ (mcp_server/       │
        │  server.py)        │
        │                    │
        │ • get_available_   │
        │   crops            │
        │ • get_available_   │
        │   cities           │
        │ • get_crop_price_  │
        │   stats            │
        │ • get_monthly_     │
        │   averages         │
        └────────────────────┘
```

**Orchestrator** holds no tools of its own. Its only job is delegating each step of a request to the correct sub-agent, exactly once, and assembling the final response. This constraint is written explicitly into its instruction — an earlier version without it fell into an infinite transfer loop with `data_agent`.

**Data Agent** is the sole point of contact with the dataset. Four of its tools (`get_available_crops`, `get_available_cities`, `get_crop_price_stats`, `get_monthly_averages`) are served through a standalone **MCP server** over stdio, connected via ADK's `MCPToolset`. Two additional tools (`get_price_history`, `compare_crops_by_city`) are registered directly as Python functions. Each tool has exactly one registration path — registering the same function through both channels previously caused a "duplicate function declaration" error.

**Forecasting Agent** fits a linear regression over the monthly price averages supplied by `data_agent`, returning a per-month forecast with 95% prediction intervals, a trend classification, and an R² confidence score.

**Recommendation Agent** combines the forecast trend and confidence into an action — buy, sell, hold, or wait — with an urgency level and plain-language reasoning, and can aggregate recommendations across multiple crops into a market strategy.

## Why a Multi-Agent System

A single prompt can't reason over 7.99 million records — it doesn't fit in any context window, and the underlying task isn't one job but three distinct ones: retrieving the right data, projecting it forward statistically, and translating that projection into farmer-facing advice with appropriate risk hedging.

Splitting these into separate agents keeps each one's tool surface minimal and independently testable, and makes the reasoning chain fully visible through ADK's event trace — which mattered considerably during debugging.

## Tech Stack

| Component | Technology |
|---|---|
| Agent framework | Google Agent Development Kit (ADK) 2.3.0 |
| LLM | Gemini (`gemini-flash-lite-latest`) |
| Data protocol | Model Context Protocol (MCP), via FastMCP |
| Data layer | pandas / NumPy |
| Forecasting | scikit-learn (linear regression) |
| Development environment | Google Antigravity (IDE + CLI) |

**Model choice note:** All four agents run on `gemini-flash-lite-latest`. Early development used `gemini-2.0-flash` and `gemini-2.5-flash`, both of which hit their free-tier ceiling of roughly 20 requests/day almost immediately — a single user query touches three to four model calls across the pipeline. `gemini-2.0-flash-lite` and `gemini-1.5-flash` were deprecated mid-project. `gemini-flash-lite-latest` provides close to 1,500 requests/day of free-tier headroom and is served from a broader capacity pool, which also reduced intermittent `503` congestion errors seen on pinned model versions.

## Project Structure

```
agri-price-agent/
├── agents/
│   ├── orchestrator/
│   │   ├── agent.py
│   │   └── .env
│   ├── data_agent/
│   │   ├── agent.py
│   │   └── .env
│   ├── forecasting_agent/
│   │   ├── agent.py
│   │   └── .env
│   └── recommendation_agent/
│       ├── agent.py
│       └── .env
├── mcp_server/
│   └── server.py
├── data/
│   └── cleaned_merged_crop_prices.csv   # not committed — see Dataset section
├── src/                                  # earlier Data Mining pipeline (preprocessing, modeling, clustering)
├── notebooks/                             # exploratory analysis from the original Data Mining project
├── reports/                                # LaTeX reports from the original Data Mining project
├── results/                                # model outputs / figures from the original Data Mining project
├── tests/
│   └── smoke_test.py                      # non-LLM tests for tool logic
├── .github/
│   └── workflows/
│       └── lint.yml
├── main.py                                 # CLI entry point
├── requirements.txt
├── Makefile
├── CONTRIBUTING.md
└── LICENSE
```

## Getting Started

### 1. Prerequisites
- Python 3.12+
- A Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey)

### 2. Clone and install
```bash
git clone https://github.com/whozahm3d/agri-price-agent.git
cd agri-price-agent
pip install -r requirements.txt
```

### 3. Dataset
The dataset (`cleaned_merged_crop_prices.csv`, ~400MB) is not committed to this repository due to its size. Download it and place it at `data/cleaned_merged_crop_prices.csv`:

👉 [Download from Google Drive](https://drive.google.com/file/d/1sOyXcNtR8pP8B3qPtvWVB2Z6XXDR1Hqn/view?usp=drive_link)

This file is the cleaned, outlier-controlled output of an earlier Data Mining course project applied to Kaggle's Crop Prices Dataset of Pakistan (53 raw CSVs, ~7.99M records, 2008–2024, 138 cities, 76 crops). The original pipeline (IQR winsorization, calendar feature extraction, STL decomposition, nine benchmarked forecasting models) is preserved in `src/`, `notebooks/`, and `reports/` for reference.

### 4. Configure environment variables
Each agent reads its own `.env` file. Add your Gemini API key to **all four**:
```
agents/orchestrator/.env
agents/data_agent/.env
agents/forecasting_agent/.env
agents/recommendation_agent/.env
```
Each file should contain:
```
GOOGLE_API_KEY=your_api_key_here
```

> ⚠️ **Security note:** `.env` files are git-ignored and must never be committed. Do not paste your API key into any file inside this repository other than the `.env` files listed above.

### 5. Run

**Interactive web UI (recommended for testing):**
```bash
export PYTHONPATH=$(pwd)        # Windows: $env:PYTHONPATH = (Get-Location)
adk web agents/orchestrator --port 8080
```
Then open `http://127.0.0.1:8080`, select **orchestrator**, and start chatting.

**Command line:**
```bash
python main.py
```

**Run tests (no API calls required):**
```bash
python tests/smoke_test.py
```

## Example Interaction

```
You: What will wheat cost in Lahore over the next 6 months, and should I sell now?

Agent:
Current average price: PKR 3,450/40kg

6-Month Forecast (R² = 0.82 — high confidence)
  2026-08: PKR 3,510  [3,320 – 3,700]
  2026-09: PKR 3,565  [3,340 – 3,790]
  ...

Trend: RISING (~1.6%/month)

ACTION: HOLD / SELL LATER
Risk Level: LOW
Reasoning: Prices are trending upward with high model confidence.
Holding stock for 2–3 months is likely to yield a better price than
selling today. Please confirm final decisions with your local market
committee.
```

## Course Concepts Demonstrated

| Concept | Where |
|---|---|
| Multi-agent system (ADK) | `agents/orchestrator/agent.py`, sub-agent delegation |
| MCP Server | `mcp_server/server.py`, connected via `MCPToolset` in `data_agent` |
| Agent skills | `forecast_prices`, `generate_recommendation`, and related tool functions |

## Known Limitations

- **Forecasting model:** currently a simple linear regression for speed and zero added dependencies inside the tool layer. The earlier Data Mining pipeline (`src/`) already validated ARIMA, Holt-Winters, and tuned XGBoost against this dataset — exposing the strongest of these as an additional MCP tool is a natural next step.
- **No input validation / guardrails** at the orchestrator boundary yet. Malformed or adversarial input is not explicitly sanitized before being routed to sub-agents.
- **Occasional redundant tool calls:** `data_agent` sometimes calls the same MCP tool more than once for a single user turn before settling on an answer. This does not currently affect correctness, only response latency and quota usage.

## Roadmap

- [ ] Expose the validated ARIMA/XGBoost forecasting models as an additional MCP tool
- [ ] Add input validation and basic guardrails at the orchestrator level
- [ ] Reduce redundant tool calls in `data_agent`
- [ ] Add automated evaluation sets using ADK's built-in eval framework

## Author

**Ali Ahmad** — FAST NUCES Lahore, Data Science & AI

## License

MIT — see [LICENSE](LICENSE)
