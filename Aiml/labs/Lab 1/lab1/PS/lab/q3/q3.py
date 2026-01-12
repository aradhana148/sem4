import numpy as np
import sklearn as sk

def ols(x_train,y):
    N,d=np.shape(x_train)
    x_t=np.c_[np.ones((N,1)),x_train]
    w=np.linalg.inv(x_t.T@x_t)@x_t.T@y
    return w

def standardise(x_t):
    means=x_t.mean(axis=1)
    std=

def load_data():
    train=np.loadtxt("q1_train.csv",skiprows=1,delimiter=',')
    X_train=train[:802,:-1]
    y_train=train[:802,-1]
    test=np.loadtxt("q1_test.csv",skiprows=1,delimiter=',')
    X_test=test[802:,:-1]
    y_test=test[802:,-1]

    return X_train, y_train,X_test,y_test

if __name__ == "__main__": 
    X_train, y_train, X_test, y_test= load_data()
    std_X_train=standardise(X_train)