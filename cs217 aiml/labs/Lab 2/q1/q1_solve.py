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
    # TODO
    N,d=X.shape
    onee=np.ones((N,1))
    X_t=np.c_[onee,X]
    return X_t
    raise NotImplementedError


def mse(y: np.ndarray, y_pred: np.ndarray) -> float:
    """Mean squared error."""
    # TODO
    y_diff=y_pred-y
    y_diff=y_diff**2
    return np.mean(y_diff)
    raise NotImplementedError


def standardize_train(X: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Standardize features using training statistics.
    Returns standardized X, mean, and stddev.
    See main.py for usage.
    """
    # TODO
    means=np.mean(X,axis=0)
    stdd=np.std(X,axis=0)
    
    std_X=(X-means)/stdd
    return std_X, means,stdd
    raise NotImplementedError


def standardize_apply(X: np.ndarray, mean: np.ndarray, std: np.ndarray) -> np.ndarray:
    """
    Apply training standardization.
    See main.py for usage.
    """
    # TODO
    return (X-mean)/std
    raise NotImplementedError


# -------------------------
# Ridge Regression
# -------------------------
def ridge_regression_closed_form(X: np.ndarray, y: np.ndarray, lam: float) -> np.ndarray:
    """
    Closed-form ridge regression:
        (X^T X + λD) w = X^T y
    where D[0,0] = 0 (bias not regularized).
    """
    # TODO
    N,d=np.shape(X)
    D=np.identity(d+1)
    D[0,0]=0
    X=add_bias(X)
    blah=X.T@X+lam*D
    if(np.linalg.det(blah)!=0):
        # print(np.shape(y))
        w=np.linalg.solve((blah),X.T@y)
    else:
        w=np.zeros((d,1))
    return w
    raise NotImplementedError


# -------------------------
# Cross-validation
# -------------------------
def k_fold_split(N: int, k: int) -> List[np.ndarray]:
    """
        k-fold split after shuffling
        Returns list of k arrays of indices.
    """
    # TODO
    arr=np.arange(N)
    np.random.shuffle(arr)
    slash=N//k
    first=np.array(arr[0:slash])
    for i in range(1,k):
        addd=np.array(arr[i*slash:(i+1)*slash])
        first=np.c_[first,addd]

    return first
    raise NotImplementedError


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
    # TODO
    N,d=np.shape(X)
    ks=k_fold_split(N,k)
    
    temp=(X[ks[0],:])
    temp_y=(y[ks[0]])
    full_x_t=temp
    full_y_t=temp_y
    msee=[]
    for i in range(1,k):
        temp=np.array(X[ks[i],:])
        temp_y=np.array(y[ks[i]])
        full_x_t=np.vstack((full_x_t,temp))
        full_y_t=np.vstack((full_y_t,temp_y))
    # print(full_y_t.shape())
    for i in range(k):
        del_indices=np.arange(k*i,k*(i+1))
        X_t=np.delete(full_x_t,del_indices,0)
        y_t=np.delete(full_y_t,del_indices,0)
        std_X_t,mean,std=standardize_train(X_t)
        w=ridge_regression_closed_form(std_X_t,y_t,lam)
        X_test=full_x_t[del_indices,:]
        y_test=full_y_t[del_indices]
        std_X_test=standardize_apply(X_test,mean,std)
        y_pred=std_X_test@w
        msee.append(mse(y_test,y_pred))
    msee=np.array(msee)
    return np.mean(msee)
    raise NotImplementedError


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
    # TODO
    mses=[]
    for i in lambdas:
        mses.append(ridge_cv(X,y,i,k))
    mses=np.array(mses)
    return lambdas,mses
    raise NotImplementedError


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
    rng = np.random.default_rng()
    s = rng.uniform(low_exp,high_exp,n_iter)
    lambdas=10**s
    mses=[]
    for i in lambdas:
        mses.append(ridge_cv(X,y,i,k))
    mses=np.array(mses)
    return lambdas,mses
    raise NotImplementedError
