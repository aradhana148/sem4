"""
KNORA-U — Dynamic Ensemble Selection for Regression (with optional Bagging)

Read every docstring carefully before implementing.
Do NOT rename any class, method, or variable — the autograder depends on them.
"""

import numpy as np
from typing import List, Tuple
from sklearn.base import BaseEstimator, clone
from sklearn.preprocessing import StandardScaler


# ===========================================================================
# Training data loader (students only get TRAIN data)
# ===========================================================================

def load_training_data(path="../train.npz"):
    """
    Load training data.

    NOTE:
    - Students only get access to TRAIN data.
    - DSEL must be constructed from training data only.
    """
    data = np.load(path)
    return data["X"], data["y"]


# ===========================================================================
# Utility functions
# ===========================================================================

def euclidean_distance(a: np.ndarray, b: np.ndarray) -> float:
    """
    Compute Euclidean distance between two vectors.

    Parameters
    ----------
    a, b : np.ndarray of shape (n_features,)

    Returns
    -------
    float
    """
    return float(np.sqrt(np.sum((a - b) ** 2)))


def knn_indices(X: np.ndarray, x: np.ndarray, K: int) -> np.ndarray:
    """
    Find indices of the K nearest neighbors of x in X.

    Parameters
    ----------
    X : np.ndarray, shape (n_samples, n_features)
    x : np.ndarray, shape (n_features,)
    K : int

    Returns
    -------
    np.ndarray — indices of K nearest neighbors
    """
    # Compute distances from x to all rows in X
    diffs = X - x  # (n_samples, n_features)
    distances = np.sqrt(np.sum(diffs ** 2, axis=1))
    # Return indices of K smallest distances
    return np.argpartition(distances, K)[:K]


# ===========================================================================
# Bagging utilities
# ===========================================================================

def bootstrap_sample(
    X: np.ndarray,
    y: np.ndarray,
    random_state: int
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Draw a bootstrap sample from (X, y).

    Parameters
    ----------
    X : np.ndarray
    y : np.ndarray
    random_state : int

    Returns
    -------
    X_boot, y_boot : np.ndarray
    """
    rng = np.random.default_rng(random_state)
    n = len(X)
    indices = rng.choice(n, size=n, replace=True)
    return X[indices], y[indices]


def fit_with_optional_bagging(
    model: BaseEstimator,
    X: np.ndarray,
    y: np.ndarray,
    use_bagging: bool,
    random_state: int
) -> BaseEstimator:
    """
    Fit a model either normally or using bagging.

    Parameters
    ----------
    model : BaseEstimator (unfitted)
    X, y : training data
    use_bagging : bool
        Whether to apply bagging
    random_state : int

    Returns
    -------
    fitted model
    """
    fitted = clone(model)
    if use_bagging:
        X_boot, y_boot = bootstrap_sample(X, y, random_state)
        fitted.fit(X_boot, y_boot)
    else:
        fitted.fit(X, y)
    return fitted


# ===========================================================================
# KNORA-U Regressor
# ===========================================================================

class KNORAURegressor:
    """
    K-Nearest Oracles Union (KNORA-U) for regression.

    Dynamic ensemble selection based on local competence.
    """

    def __init__(self, K: int = 7, epsilon: float = 1.0):
        """
        Parameters
        ----------
        K : int
            Initial neighborhood size
        epsilon : float
            Local error tolerance
        """
        self.K = K
        self.epsilon = epsilon

        self.models_: List[BaseEstimator] = []
        self.X_dsel_: np.ndarray = None
        self.y_dsel_: np.ndarray = None
        self.scaler_ = StandardScaler()

    # ------------------------------------------------------------------
    # fit
    # ------------------------------------------------------------------
    def fit(
        self,
        models: List[BaseEstimator],
        X_dsel: np.ndarray,
        y_dsel: np.ndarray
    ) -> "KNORAURegressor":
        """
        Store the fitted model pool and DSEL dataset.

        Parameters
        ----------
        models : list of FITTED regressors
        X_dsel : np.ndarray
        y_dsel : np.ndarray

        Returns
        -------
        self
        """
        self.models_ = models
        # Scale and store DSEL
        self.X_dsel_ = self.scaler_.fit_transform(X_dsel)
        self.y_dsel_ = np.asarray(y_dsel, dtype=float)
        return self

    # ------------------------------------------------------------------
    # _select_models
    # ------------------------------------------------------------------
    def _select_models(self, x: np.ndarray) -> List[BaseEstimator]:
        """
        Select locally competent models for a single test point x
        using the KNORA-U algorithm.

        Algorithm
        ---------
        1. Find K nearest neighbors of x in DSEL
        2. For each model:
             - compute MAE on these neighbors
        3. Select all models with MAE <= epsilon
        4. If none selected:
             - select the single best model (lowest MAE)

        Returns
        -------
        list of selected models (non-empty)
        """
        # Scale the test point
        x_scaled = self.scaler_.transform(x.reshape(1, -1)).ravel()

        # Step 1: Find K nearest neighbors in scaled DSEL
        nn_idx = knn_indices(self.X_dsel_, x_scaled, self.K)

        X_nn = self.X_dsel_[nn_idx]  # (K, n_features)
        y_nn = self.y_dsel_[nn_idx]  # (K,)

        # Step 2: Compute MAE for each model on the neighborhood
        maes = []
        for model in self.models_:
            preds = model.predict(X_nn)
            mae = float(np.mean(np.abs(preds - y_nn)))
            maes.append(mae)

        maes = np.array(maes)

        # Step 3: Select models with MAE <= epsilon
        mask = maes <= self.epsilon
        if mask.any():
            return [self.models_[i] for i in np.where(mask)[0]]

        # Step 4: Fallback — best single model
        best_idx = int(np.argmin(maes))
        return [self.models_[best_idx]]

    # ------------------------------------------------------------------
    # predict
    # ------------------------------------------------------------------
    def predict(self, X: np.ndarray) -> np.ndarray:
        """
        Predict target values using dynamic model selection.

        For each test point:
        - select models using _select_models
        - return average prediction

        Parameters
        ----------
        X : np.ndarray, shape (n_samples, n_features)

        Returns
        -------
        np.ndarray, shape (n_samples,)
        """
        # Scale X since models were trained on scaled features
        X_scaled = self.scaler_.transform(X)
        predictions = []
        for i in range(X_scaled.shape[0]):
            x = X[i]  # raw, for _select_models (which internally scales)
            selected = self._select_models(x)
            x_s = X_scaled[i].reshape(1, -1)
            preds = np.array([m.predict(x_s)[0] for m in selected])
            predictions.append(float(np.mean(preds)))
        return np.array(predictions)


# ===========================================================================
# Allowed base learners (provided, not implemented by students)
# ===========================================================================

from sklearn.tree import DecisionTreeRegressor
from sklearn.linear_model import Ridge, Lasso, LinearRegression
from sklearn.neighbors import KNeighborsRegressor
from sklearn.svm import SVR

ALLOWED_MODEL_SPECS = {
    DecisionTreeRegressor: {
        "max_depth": {1, 2, 3}
    },
    LinearRegression: {},

    Ridge: {
        "alpha": (1e-4, 1e3)
    },
    Lasso: {
        "alpha": (1e-4, 1e1)
    },

    KNeighborsRegressor: {
        "n_neighbors": {5, 10}
    },

    SVR: {
        "kernel": {"rbf"},
        "C": (0.1, 10.0),
        "epsilon": (0.01, 1.0),
    },
}


# ===========================================================================
# PART D — Student-defined model pool
# ===========================================================================
#
# Rules enforced by autograder:
# - >= 5 models
# - Each model must be fitted
# - If same architecture appears multiple times:
#     -> bagging MUST be used
#

# Load training data
_X_train, _y_train = load_training_data("../train.npz")

# Scale training data for models that need it (KNN, SVR)
_scaler = StandardScaler()
_X_train_scaled = _scaler.fit_transform(_X_train)

# Define base (unfitted) model pool
# Using diverse learners: trees at different depths, Ridge variants, KNN, SVR
_base_models = [
    (DecisionTreeRegressor(max_depth=3), True),   # bagging: appears multiple times
    (DecisionTreeRegressor(max_depth=3), True),   # bagging
    (DecisionTreeRegressor(max_depth=2), True),   # bagging: appears multiple times
    (DecisionTreeRegressor(max_depth=2), True),   # bagging
    (DecisionTreeRegressor(max_depth=1), True),   # bagging: appears multiple times
    (Ridge(alpha=1.0),                    False),  # linear
    (Lasso(alpha=0.01),                   False),  # sparse linear
    (KNeighborsRegressor(n_neighbors=5),  False),  # non-linear local
    (KNeighborsRegressor(n_neighbors=10), False),  # smoother non-linear
    (SVR(kernel="rbf", C=5.0, epsilon=0.05), False),  # RBF kernel
]

REGRESSION_MODELS: List[BaseEstimator] = []

for _i, (_model, _use_bagging) in enumerate(_base_models):
    _fitted = fit_with_optional_bagging(
        _model, _X_train_scaled, _y_train, _use_bagging, random_state=_i * 42
    )
    REGRESSION_MODELS.append(_fitted)