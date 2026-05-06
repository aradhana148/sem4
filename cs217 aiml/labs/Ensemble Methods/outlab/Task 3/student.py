"""
Task 3 — Open-Ended Ensemble Fusion
=====================================
You have two baseline predictors from Tasks 1 and 2.
Combine them (and anything else you like) to get the lowest MAE on test data.

Rules
-----
* Edit THIS file only. Do not rename task3_predict or FUSION_LEARNERS.
* No pre-built boosting libraries (XGBoost, LightGBM, GradientBoostingRegressor, …).
* Allowed base learners: same weak-learner constraint as Task 2.
* Do NOT use test labels at any point.
"""

import numpy as np
from typing import List
from sklearn.base import BaseEstimator, clone
from sklearn.tree import DecisionTreeRegressor
from sklearn.linear_model import Ridge, Lasso, LinearRegression
from sklearn.neighbors import KNeighborsRegressor
from sklearn.svm import SVR
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import KFold

# ===========================================================================
# ALLOWED_MODEL_SPECS (required by autograder)
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
# FUSION_LEARNERS — pool of weak learners available to your fusion
# ===========================================================================
# Rules:
#   • >= 5 unfitted estimators
#   • Only allowed base learners (same as Task 2)
#   • No pre-built boosting models

FUSION_LEARNERS: List[BaseEstimator] = [
    DecisionTreeRegressor(max_depth=3),
    DecisionTreeRegressor(max_depth=2),
    DecisionTreeRegressor(max_depth=1),
    Ridge(alpha=1.0),
    Ridge(alpha=10.0),
    Lasso(alpha=0.01),
    KNeighborsRegressor(n_neighbors=5),
    KNeighborsRegressor(n_neighbors=10),
    SVR(kernel="rbf", C=5.0, epsilon=0.05),
    LinearRegression(),
]


# ===========================================================================
# Task 1 Gradient Boosting (inline reimplementation to avoid import issues)
# ===========================================================================

def _huber_pseudo_residuals(y_true, y_pred, delta):
    residuals = np.asarray(y_true, dtype=float) - np.asarray(y_pred, dtype=float)
    return np.where(np.abs(residuals) <= delta, residuals, delta * np.sign(residuals))


def _fit_gradient_boosting(X_train, y_train, n_estimators=200, delta=2.0, lr=0.05):
    """Fit a gradient boosting ensemble using decision stumps/trees."""
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X_train)

    learners = [
        DecisionTreeRegressor(max_depth=3),
        DecisionTreeRegressor(max_depth=3),
        DecisionTreeRegressor(max_depth=3),
        DecisionTreeRegressor(max_depth=2),
        DecisionTreeRegressor(max_depth=1),
    ]

    initial_pred = float(np.mean(y_train))
    f = np.full(len(y_train), initial_pred, dtype=float)
    models = []
    n = len(learners)

    for m in range(1, n_estimators + 1):
        g = _huber_pseudo_residuals(y_train, f, delta)
        learner = learner = clone(learners[(m - 1) % n])
        learner.fit(X_scaled, g)
        f = f + lr * learner.predict(X_scaled)
        models.append(learner)

    return scaler, initial_pred, models, lr


def _predict_gradient_boosting(scaler, initial_pred, models, lr, X):
    X_scaled = scaler.transform(X)
    f = np.full(X_scaled.shape[0], initial_pred, dtype=float)
    for model in models:
        f = f + lr * model.predict(X_scaled)
    return f


# ===========================================================================
# task3_predict — entry point called by the autograder
# ===========================================================================

def task3_predict(
    X_train: np.ndarray,
    y_train: np.ndarray,
    X_test:  np.ndarray,
) -> np.ndarray:
    """
    Strategy: Stacking with cross-validation meta-features.

    1. Build a diverse pool of base learners (including GB from Task 1).
    2. Generate out-of-fold predictions on X_train for each base learner.
    3. Fit a Ridge meta-learner on these OOF predictions.
    4. Refit all base learners on full X_train, generate test predictions.
    5. Meta-learner combines test predictions.
    """
    rng = np.random.default_rng(42)
    n_folds = 5
    kf = KFold(n_splits=n_folds, shuffle=True, random_state=42)

    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    # -----------------------------------------------------------------
    # Base learners (all work on scaled features)
    # -----------------------------------------------------------------
    base_learners = [
        DecisionTreeRegressor(max_depth=3),
        DecisionTreeRegressor(max_depth=2),
        DecisionTreeRegressor(max_depth=1),
        Ridge(alpha=1.0),
        Ridge(alpha=100.0),
        Lasso(alpha=0.01),
        KNeighborsRegressor(n_neighbors=5),
        KNeighborsRegressor(n_neighbors=10),
        SVR(kernel="rbf", C=5.0, epsilon=0.05),
        LinearRegression(),
    ]

    n_base = len(base_learners)
    n_train = len(X_train)
    n_test = len(X_test)

    # -----------------------------------------------------------------
    # OOF predictions for level-1 (meta) features
    # -----------------------------------------------------------------
    oof_preds = np.zeros((n_train, n_base))

    for fold_idx, (train_idx, val_idx) in enumerate(kf.split(X_train_scaled)):
        X_fold_train = X_train_scaled[train_idx]
        y_fold_train = y_train[train_idx]
        X_fold_val = X_train_scaled[val_idx]

        for j, learner in enumerate(base_learners):
            m = clone(learner)
            m.fit(X_fold_train, y_fold_train)
            oof_preds[val_idx, j] = m.predict(X_fold_val)

    # -----------------------------------------------------------------
    # Fit all base learners on full training data
    # -----------------------------------------------------------------
    fitted_base = []
    test_preds = np.zeros((n_test, n_base))

    for j, learner in enumerate(base_learners):
        m = clone(learner)
        m.fit(X_train_scaled, y_train)
        fitted_base.append(m)
        test_preds[:, j] = m.predict(X_test_scaled)

    # -----------------------------------------------------------------
    # Also include a gradient-boosting column (Task 1 style)
    # -----------------------------------------------------------------
    gb_scaler, gb_init, gb_models, gb_lr = _fit_gradient_boosting(
        X_train, y_train, n_estimators=150, delta=2.0, lr=0.05
    )
    gb_test = _predict_gradient_boosting(gb_scaler, gb_init, gb_models, gb_lr, X_test)

    # Generate GB OOF predictions via cross-validation
    gb_oof = np.zeros(n_train)
    for train_idx, val_idx in kf.split(X_train):
        _s, _ip, _ms, _lr = _fit_gradient_boosting(
            X_train[train_idx], y_train[train_idx], n_estimators=100, delta=2.0, lr=0.05
        )
        gb_oof[val_idx] = _predict_gradient_boosting(_s, _ip, _ms, _lr, X_train[val_idx])

    # Append GB column
    oof_preds = np.column_stack([oof_preds, gb_oof])
    test_preds = np.column_stack([test_preds, gb_test])

    # -----------------------------------------------------------------
    # Level-2 meta-learner: Ridge regression on OOF predictions
    # -----------------------------------------------------------------
    meta = Ridge(alpha=1.0)
    meta.fit(oof_preds, y_train)

    # Final predictions
    y_pred = meta.predict(test_preds)
    return y_pred
