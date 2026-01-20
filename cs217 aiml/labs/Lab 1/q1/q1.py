# do not modify the imports below
import json
import numpy as np

# ============================================================
# OLS implementations
# ============================================================

def ols_with_intercept(X, y):
    """
    OLS with intercept
    X : (N, d)
    y : (N,)
    Returns:
        w  : (d,) slope vector
        w0 : scalar intercept
    """

    # TODO: closed-form solution of OLS
    N,d=np.shape(X)
    X_t=np.c_[np.ones((N,1)),X]
    theta=np.linalg.inv(X_t.T@X_t)@X_t.T@y
    w0=theta[0]
    w=np.reshape(theta[1:],(d,1))
    return w,w0
    raise NotImplementedError


def ols_no_intercept(X, y):
    """
    OLS without intercept
    X : (N, d)
    y : (N,)
    Returns:
        w : (d,) slope vector
    """
    N,d=np.shape(X)
    X_t=X
    theta=np.linalg.inv(X_t.T@X_t)@X_t.T@y
    return theta
    # TODO: closed-form solution of OLS without intercept
    raise NotImplementedError


# ============================================================
# Metrics
# ============================================================

def predict_with_intercept(X, w, w0):
    N,blah=np.shape(X)
    X_t=np.c_[np.ones((N,1)),X]
    d,dc=np.shape(w)
    w=np.reshape(w,(1,d))
    w_t=np.c_[np.full((1,1),w0),w]
    y_pred=X_t@w_t.T
    return y_pred
    raise NotImplementedError


def predict_no_intercept(X, w):
    return X@w
    raise NotImplementedError


def compute_metrics(y, y_hat):

    # TODO: Compute mean squared error
    diff=y-y_hat
    diff=diff**2
    mse = diff.mean()

    # TODO: Compute correlation between y and y_hat
    y_mean=y.mean()
    y_hat_mean=y_hat.mean()
    y_diff=y-y_mean
    y_hat_diff=y_hat-y_hat_mean
    num=(y_diff*y_hat_diff).sum()
    y_diff=y_diff**2
    y_hat_diff=y_hat_diff**2
    den=(y_diff.sum())*(y_hat_diff.sum())**(0.5)
    corr = num/den

    # TODO: Compute squared correlation
    corr_sq=corr**2

    # TODO: Compute R^2
    meann=y.mean()
    den=y-meann
    den=den**2
    den_sum=den.sum()
    num=y-y_hat
    num=num**2
    num_sum=num.sum()
    r2 = (1-(num_sum/den_sum))

    return {
        "mse": float(mse),
        "corr": float(corr),
        "corr_sq": float(corr_sq),
        "r2": float(r2),
    }


# ============================================================
# Data loading
# ============================================================

def load_data():
    """
    Load all datasets required for the lab.

    Returns
    -------
    X_train, y_train (q1_train.csv)
    X_test, y_test (q1_test.csv)
    X_train_outlier, y_train_outlier (q1_train.csv appeanded by q1_outliers.csv)
    """
    # TODO: Load data from CSV files and return numpy arrays
    train=np.loadtxt("q1_train.csv",skiprows=1,delimiter=',')
    X_train=train[:,:-1]
    y_train=train[:,-1]
    test=np.loadtxt("q1_test.csv",skiprows=1,delimiter=',')
    X_test=test[:,:-1]
    y_test=test[:,-1]
    outliers=np.loadtxt("q1_outliers.csv",skiprows=1,delimiter=',')
    X_train_outlier=np.vstack((X_train,outliers[:,:-1]))
    y_train_outlier=np.hstack((y_train,outliers[:,-1]))
    return X_train, y_train,X_test,y_test,X_train_outlier,y_train_outlier
    raise NotImplementedError

# ============================================================
# Main experiment (DO NOT MODIFY, AUTOGRADER TESTS WILL RUN THIS)
# ============================================================

if __name__ == "__main__": 
    X_train, y_train, X_test, y_test, X_train_outlier, y_train_outlier = load_data()

    # ---------- Standard OLS ----------
    w, w0 = ols_with_intercept(X_train, y_train)

    yhat_train = predict_with_intercept(X_train, w, w0)
    yhat_test = predict_with_intercept(X_test, w, w0)

    standard_train_metrics = compute_metrics(y_train, yhat_train)
    standard_test_metrics = compute_metrics(y_test, yhat_test)

    # ---------- OLS with outliers ----------
    w_o, w0_o = ols_with_intercept(X_train_outlier, y_train_outlier)

    yhat_train_outlier = predict_with_intercept(X_train_outlier, w_o, w0_o)
    yhat_test_outlier = predict_with_intercept(X_test, w_o, w0_o)

    outlier_train_metrics = compute_metrics(y_train_outlier, yhat_train_outlier)
    outlier_test_metrics = compute_metrics(y_test, yhat_test_outlier)

    # ---------- No-intercept OLS ----------
    w_no = ols_no_intercept(X_train, y_train)

    yhat_train_no = predict_no_intercept(X_train, w_no)
    yhat_test_no = predict_no_intercept(X_test, w_no)

    no_intercept_train_metrics = compute_metrics(y_train, yhat_train_no)
    no_intercept_test_metrics = compute_metrics(y_test, yhat_test_no)

    # ------------- Dump metrics -------------

    metrics = {
        "standard_ols": {
            "train": standard_train_metrics,
            "test": standard_test_metrics,
        },
        "outlier_ols": {
            "train": outlier_train_metrics,
            "test": outlier_test_metrics,
        },
        "no_intercept_ols": {
            "train": no_intercept_train_metrics,
            "test": no_intercept_test_metrics,
        },
    }

    with open("metrics.json", "w") as f:
        json.dump(metrics, f, indent=4)