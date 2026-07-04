#Configuration

#Set DATA_DIR to the folder containing your 53 CSV files before running.

# ================================================================
#  CONFIGURATION  —  Only this cell needs to be edited
# ================================================================

DATA_DIR     = r"E:\Documents\Data Mining\Project\pakistan_crop_prices_dataset" 
MERGED_FILE =  r"E:\Documents\Data Mining\Project\merged_crop_prices.csv"
CLEANED_FILE = r"E:\Documents\Data Mining\Project\cleaned_merged_crop_prices.csv"
FEATURED_FILE = r"E:\Documents\Data Mining\Project\outputs\featured.csv"
OUT_DIR      = r"E:\Documents\Data Mining\Project\outputs"

TOP_N        = 5       # Number of top crops to analyze in EDA / decomposition
MIN_LEN      = 100     # Minimum records required per (Crop, City) series
RANDOM_STATE = 42

# ── Split ratios
TRAIN_RATIO = 0.70
VAL_RATIO   = 0.10
TEST_RATIO  = 0.20   # remaining

# ── Forecast horizons (months ahead)
HORIZONS = {
    "1-month" : 1,
    "3-month" : 3,
    "6-month" : 6,
}

# For clustering (Phase 3)
MAX_K        = 8

os.makedirs(OUT_DIR, exist_ok=True)
print(f"Output directory ready  : {OUT_DIR}")
print(f"Data directory          : {DATA_DIR}")

# Helper Utilities and Functions

# ── Color palette (used consistently across all visualizations) ───
C = {
    'blue'  : '#2196F3',
    'teal'  : '#009688',
    'green' : '#4CAF50',
    'orange': '#FF9800',
    'red'   : '#F44336',
    'purple': '#9C27B0',
    'grey'  : '#607D8B',
}

MODEL_COLORS = {
    'Naive'          : C['grey'],
    'Seasonal Naive' : C['purple'],
    'Holt-Winters'   : C['teal'],
    'ARIMA'          : C['orange'],
    'Linear Reg'     : C['blue'],
    'Random Forest'  : C['green'],
    'XGBoost'        : C['red'],
    'RF Tuned'       : '#00BCD4',
    'XGB Tuned'      : '#FF5722',
}


def save_and_show(name, folder):
    """Save the current figure to <folder>/<name>.png and display it."""
    os.makedirs(folder, exist_ok=True)
    plt.savefig(os.path.join(folder, f"{name}.png"), dpi=100, bbox_inches='tight')
    plt.show()
    plt.close('all')


def mape(y_true, y_pred):
    mask = np.array(y_true) != 0
    return np.mean(np.abs((y_true[mask]-y_pred[mask])/y_true[mask]))*100


def eval_metrics(y_true, y_pred, label=''):
    y_true, y_pred = np.array(y_true), np.array(y_pred)
    mae  = mean_absolute_error(y_true, y_pred)
    rmse = np.sqrt(mean_squared_error(y_true, y_pred))
    mp   = mape(y_true, y_pred)
    if label:
        print(f'  {label:<30}  MAE={mae:>7.4f}  RMSE={rmse:>7.4f}  MAPE={mp:>6.2f}%')
    return {'MAE': round(mae,4), 'RMSE': round(rmse,4), 'MAPE': round(mp,2)}


def print_memory(label=""):
    """Print current process memory usage in MB."""
    try:
        mb = psutil.Process(os.getpid()).memory_info().rss / 1024 / 1024
        print(f"  Memory {label:<35}: {mb:>8,.0f} MB")
    except Exception as e:
        print(f"  Memory check failed: {e}")

print("Helper utilities ready.")
