"""
Read every docstring carefully before implementing.
Do NOT rename any class, method, or variable — the autograder depends on them.
"""

import numpy as np
from typing import List
from sklearn.base import BaseEstimator, clone
from sklearn.preprocessing import StandardScaler

# ===========================================================================
# Training data loader (students only get TRAIN data)
# ===========================================================================

def load_training_data(path="train.npz"):
    """
    Load training data from disk.
    """
    data = np.load(path)
    X_train = data["X"]
    y_train = data["y"]
    return X_train, y_train


# ===========================================================================
# PART A  —  Loss functions
# ===========================================================================

def huber_loss(residuals: np.ndarray, delta: float) -> float:
    """
    Compute the MEAN Huber loss over an array of residuals.

    L_delta(r) = 0.5 * r^2               if |r| <= delta
                 delta * |r| - 0.5*delta^2  otherwise

    Returns
    -------
    float — mean Huber loss across all residuals
    """
    residuals = np.asarray(residuals, dtype=float)
    abs_r = np.abs(residuals)
    loss = np.where(
        abs_r <= delta,
        0.5 * residuals ** 2,
        delta * abs_r - 0.5 * delta ** 2
    )
    return float(np.mean(loss))


def huber_pseudo_residuals(y_true: np.ndarray,
                           y_pred: np.ndarray,
                           delta: float) -> np.ndarray:
    """
    Compute the negative gradient of the Huber loss w.r.t. y_pred.

    g_i = r_i                  if |r_i| <= delta
          delta * sign(r_i)    otherwise

    where r_i = y_i - y_pred_i

    Returns
    -------
    np.ndarray — pseudo-residuals, same shape as y_true
    """
    residuals = np.asarray(y_true, dtype=float) - np.asarray(y_pred, dtype=float)
    pseudo = np.where(
        np.abs(residuals) <= delta,
        residuals,
        delta * np.sign(residuals)
    )
    return pseudo


# ===========================================================================
# PART B  —  GradientBoostingEnsemble class
# ===========================================================================

class GradientBoostingEnsemble:
    """
    A from-scratch gradient boosting ensemble supporting regression
    using the Huber loss.

    The model has the form:
        f(x) = initial_prediction_ + sum_{m=1}^{M} learning_rate(m) * F_m(x)

    where:
        - M is the number of boosting stages (n_estimators)
        - F_m is the m-th weak learner fitted on pseudo-residuals
        - weak_learners is cycled over to fill M stages
    """

    def __init__(self,
                 weak_learners: List[BaseEstimator] = None,
                 n_estimators: int = 300,
                 delta: float = 2.0):
        """
        Parameters
        ----------
        weak_learners : list of sklearn-compatible regressors
            The pool to cycle through. If None, uses REGRESSION_LEARNERS.
        n_estimators : int
            Total number of boosting stages M.
        delta : float
            Huber loss threshold.
        """
        self.weak_learners = weak_learners
        self.n_estimators = n_estimators
        self.delta = delta

        self.models_: List[BaseEstimator] = []
        self.initial_prediction_: float = 0.0
        self.scaler_ = StandardScaler()

    # ------------------------------------------------------------------
    # B1 · learning_rate
    # ------------------------------------------------------------------
    def learning_rate(self, m: int) -> float:
        """
        Return the learning rate coefficient beta_m for stage m (1-indexed).

        Uses a constant shrinkage rate — well-established default for
        gradient boosting. Small learning rate + many estimators gives
        the best generalisation.

        Returns
        -------
        float — positive learning rate for stage m
        """
        return 0.03   # constant shrinkage — lower LR + more stages = better generalisation

    # ------------------------------------------------------------------
    # B2 · _compute_pseudo_residuals
    # ------------------------------------------------------------------
    def _compute_pseudo_residuals(self,
                                  y_true: np.ndarray,
                                  f_pred: np.ndarray) -> np.ndarray:
        """
        Compute the pseudo-residuals (negative gradients) for the current stage.

        Returns
        -------
        np.ndarray — pseudo-residuals
        """
        return huber_pseudo_residuals(y_true, f_pred, self.delta)

    # ------------------------------------------------------------------
    # B3 · fit
    # ------------------------------------------------------------------
    def fit(self,
            weak_learners: List[BaseEstimator],
            X: np.ndarray,
            y: np.ndarray) -> "GradientBoostingEnsemble":
        """
        Fit the boosting ensemble.

        Algorithm
        ---------
        1. f_i = mean(y)  for all i
        2. Scale X with StandardScaler
        3. For m = 1..n_estimators:
             a. g = pseudo_residuals(y, f)
             b. clone & fit the (m % len(weak_learners))-th learner on (X_scaled, g)
             c. f += learning_rate(m) * F_m(X_scaled)
        """
        self.models_ = []

        # Use learners passed in fit() (autograder passes REGRESSION_LEARNERS)
        learner_pool = weak_learners

        # Step 1: initialise f = mean(y)
        self.initial_prediction_ = float(np.mean(y))

        # Step 2: scale X
        X_scaled = self.scaler_.fit_transform(X)

        # Running prediction
        f = np.full(y.shape[0], self.initial_prediction_, dtype=float)

        n = len(learner_pool)

        # Step 3: boosting loop — cycle through learner_pool for n_estimators stages
        for m in range(1, self.n_estimators + 1):
            # a. Pseudo-residuals
            g = self._compute_pseudo_residuals(y, f)

            # b. Select learner (cycle), clone, fit
            learner = learner_pool[(m - 1) % n]
            fitted = clone(learner)
            fitted.fit(X_scaled, g)

            # c. Update running prediction
            beta = self.learning_rate(m)
            f = f + beta * fitted.predict(X_scaled)

            # Store fitted learner
            self.models_.append(fitted)

        return self

    # ------------------------------------------------------------------
    # B4 · predict
    # ------------------------------------------------------------------
    def predict(self, X: np.ndarray) -> np.ndarray:
        """
        Generate final predictions for new data.

        Returns
        -------
        np.ndarray — predictions, shape (n_samples,)
        """
        X_scaled = self.scaler_.transform(X)
        f = np.full(X_scaled.shape[0], self.initial_prediction_, dtype=float)
        for m, model in enumerate(self.models_, start=1):
            beta = self.learning_rate(m)
            f = f + beta * model.predict(X_scaled)
        return f

    # ------------------------------------------------------------------
    # B5 · staged_loss
    # ------------------------------------------------------------------
    def staged_loss(self, X: np.ndarray, y: np.ndarray) -> np.ndarray:
        """
        Compute the Huber loss after each boosting stage on dataset (X, y).

        Returns
        -------
        np.ndarray — Huber loss after each stage, shape (n_estimators,)
        """
        X_scaled = self.scaler_.transform(X)
        f = np.full(X_scaled.shape[0], self.initial_prediction_, dtype=float)
        losses = []
        for m, model in enumerate(self.models_, start=1):
            beta = self.learning_rate(m)
            f = f + beta * model.predict(X_scaled)
            residuals = y - f
            losses.append(huber_loss(residuals, self.delta))
        return np.array(losses)


# ===========================================================================
# PART C  —  Weak learner design
# ===========================================================================
#
# - At least 5 learners, at most 10
# - Must be sklearn regressors
# - Must obey ALLOWED_MODEL_SPECS
# - No pre-built boosting models allowed
#

from sklearn.tree import DecisionTreeRegressor
from sklearn.linear_model import Ridge, Lasso, LinearRegression
from sklearn.neighbors import KNeighborsRegressor
from sklearn.svm import SVR

# ===========================================================================
# Allowed weak learner specifications (DO NOT MODIFY)
# ===========================================================================

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
# Define your weak learners here
# ===========================================================================
#
# Strategy: Use a mix of depth-1 (stumps), depth-2, and depth-3 trees as the
# primary workhorse — they are fast and effective for gradient boosting.
# Supplement with Ridge and KNN for diversity.
# The boosting loop cycles through these learners for n_estimators stages.
#
REGRESSION_LEARNERS: List[BaseEstimator] = [
    DecisionTreeRegressor(max_depth=3),   # primary workhorse — best bias/variance
    DecisionTreeRegressor(max_depth=3),   # duplicate for higher selection frequency
    DecisionTreeRegressor(max_depth=3),   # triplicate
    DecisionTreeRegressor(max_depth=2),   # medium depth for diversity
    DecisionTreeRegressor(max_depth=1),   # stumps for regularisation
    Ridge(alpha=0.1),                     # fast linear component
    Lasso(alpha=0.01),                    # sparse linear component
    KNeighborsRegressor(n_neighbors=5),   # non-linear local fit
    KNeighborsRegressor(n_neighbors=10),  # smoother non-linear
    SVR(kernel="rbf", C=5.0, epsilon=0.05),  # RBF kernel diversity
]
