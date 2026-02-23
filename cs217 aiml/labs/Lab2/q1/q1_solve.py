#!/usr/bin/env python3
"""
q1_solve.py

Implement ALL functions below.
Do NOT import sklearn.
"""

import numpy as np
from typing import List, Tuple


# -------------------------
# Utilities
# -------------------------
def add_bias(X: np.ndarray) -> np.ndarray:
    """
    Add bias (column of ones) as first column.
    See main.py for usage.
    """
    oneee = np.ones((X.shape[0],1))
    return np.concatenate([oneee, X], axis=1)


def mse(y: np.ndarray, y_pred: np.ndarray) -> float:
    """Mean squared error."""
    diff = y-y_pred
    return np.sum((diff**2))/diff.shape[0]


def standardize_train(X: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Standardize features using training statistics.
    Returns standardized X, mean, and stddev.
    See main.py for usage.
    """
    x_mean= np.mean(X, axis=0)
    x_std = np.std(X, axis=0)
    return (X-x_mean)/(x_std), x_mean, x_std


def standardize_apply(X: np.ndarray, mean: np.ndarray, std: np.ndarray) -> np.ndarray:
    """
    Apply training standardization.
    See main.py for usage.
    """
    return (X-mean)/std


# -------------------------
# Ridge Regression
# -------------------------
def ridge_regression_closed_form(X: np.ndarray, y: np.ndarray, lam: float) -> np.ndarray:
    """
    Closed-form ridge regression:
        (X^T X + λD) w = X^T y
    where D[0,0] = 0 (bias not regularized).
    """
    unity = np.identity(X.shape[1])
    unity[0][0]=0
    coeff = ((X.T)@X)+lam*unity
    w = np.linalg.solve(coeff, (X.T)@y)
    return w


# -------------------------
# Cross-validation
# -------------------------
def k_fold_split(N: int, k: int) -> List[np.ndarray]:
    """
        k-fold split after shuffling
        Returns list of k arrays of indices.
    """
    arr = np.arange(N)
    np.random.shuffle(arr)
    return np.split(arr, k)


def ridge_cv(X: np.ndarray, y: np.ndarray, lam: float, k: int) -> float:
    """
    k-fold CV MSE for ridge.
    Use the k_fold_split function above to get the folds
    Use ridge_regression_closed_form to fit the model.
    Parameters:
        X: (N, D) training data
        y: (N,) training targets
        lam: regularization parameter
        k: number of folds
    Returns average MSE across folds.
    """
    x_y_train = np.concatenate([X, y.reshape(X.shape[0], 1)], axis=1)
    split_list = k_fold_split(X.shape[0], k)
    msee=0
    for i in range(k):
        indices = split_list[:i]+split_list[i+1:]
        np_indices = np.concatenate(indices)
        x_y_k_1 = x_y_train[np_indices]
        x_y_i = x_y_train[split_list[i]]
        w = ridge_regression_closed_form(x_y_k_1[:,:-1], x_y_k_1[:, -1], lam)
        y_pred = (x_y_i[:, :-1])@w
        y_true = x_y_i[:,-1]
        msee+=mse(y_true, y_pred)
    return msee/k




# -------------------------
# Hyperparameter search
# -------------------------
def grid_search_lambdas(
    X: np.ndarray, y: np.ndarray,
    lambdas: np.ndarray, k: int
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Evaluate each λ using CV.
    Parameters:
        X: (N, D) training data
        y: (N,) training targets
        lambdas: (M,) array of λ values to evaluate
        k: number of folds
    Returns:
        lambdas: (M,) same as input
        mses: (M,) average CV MSE for each λ
    """
    ans = []
    for lambdo in lambdas:
        ans.append(ridge_cv(X, y, lambdo, k))
    return lambdas, ans


def random_search_lambdas(
    X: np.ndarray, y: np.ndarray,
    n_iter: int,
    low_exp: float,
    high_exp: float,
    k: int
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Sample λ = 10^u, where u ~ Uniform(low_exp, high_exp).
    Parameters:
        X: (N, D) training data
        y: (N,) training targets
        n_iter: number of λ values to sample
        low_exp: lower bound of exponent
        high_exp: upper bound of exponent
        k: number of folds
    Returns:
        lambdas: (n_iter,) sampled λ values
        mses: (n_iter,) average CV MSE for each λ
    """
    # TODO
    lambdas = []
    ans = []
    rng = np.random.default_rng()
    for _ in range(n_iter):
        poww = rng.random()*(high_exp-low_exp) + low_exp
        lambdo = 10**poww
        lambdas.append(lambdo)
        ans.append(ridge_cv(X, y, lambdo, k))
    return lambdas, ans