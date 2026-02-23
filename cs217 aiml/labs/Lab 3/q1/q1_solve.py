"""
q1_solve.py
============
Students must implement the following functions and classes:
- load_data
- train_test_split_custom
- OLSClassifier
- LogisticRegressionGD
"""
import numpy as np

# ============================================
# TASK 0: DATA LOADING
# ============================================

def load_data(file_path: str):
    """
    Load dataset from a given CSV file.

    Parameters
    ----------
    file_path : str
        Path to CSV file. Last column should be the label (y in {-1, +1})

    Returns
    -------
    X : np.ndarray
        Features of shape (N, d)
    y : np.ndarray
        Labels of shape (N,), values in {-1, +1}
    """
    # TODO: Implement CSV loading
    stuff=np.loadtxt(file_path,dtype=float,delimiter=",")
    X=stuff[:,:-1]
    y=stuff[:,-1]
    return X,y



# ============================================
# TASK 0.5: TRAIN TEST SPLIT
# ============================================

def test_train_split(X: np.ndarray, y: np.ndarray, test_size=0.2):
    """
    Split dataset into train and test sets.

    Parameters
    ----------
    X : np.ndarray
        Features (N, d)
    y : np.ndarray
        Labels (N,)
    test_size : float
        Fraction of dataset to assign to test set

    X_train must have shape (N_train, d)
    Where N_train = floor(N * (1 - test_size))
    and N_test = N - N_train

    Returns
    -------
    X_train, X_test, y_train, y_test : np.ndarrays
        Split datasets
        X_train : (N_train, d)
        X_test : (N_test, d)
        y_train : (N_train,)
        y_test : (N_test,)
    
    DO NOT alter the order of samples in X and y
    """
    # TODO: Split according to test_size
    N,d=X.shape
    N_train = (int) (np.floor(N * (1 - test_size)))
    X_train=X[:N_train,:]
    y_train=y[:N_train]
    X_test=X[N_train:,:]
    y_test=y[N_train:]
    return X_train, X_test, y_train, y_test



def normalized_test_train_split(X: np.ndarray, y: np.ndarray, test_size=0.2, test_train_split_func=test_train_split):
    """
    Split dataset into train and test sets and normalize features.

    Parameters
    ----------
    X : np.ndarray
        Features (N, d)
    y : np.ndarray
        Labels (N,)
    test_size : float
        Fraction of dataset to assign to test set
    test_train_split_func : function to use for splitting
        Function that takes in X, y, test_size and returns X_train, X_test, y_train, y_test
        
    Returns
    -------
    X_train, X_test, y_train, y_test : np.ndarrays
        Split datasets
        X_train : (N_train, d)
        X_test : (N_test, d)
        y_train : (N_train,)
        y_test : (N_test,)
    """
    # TODO
    X_train, X_test, y_train, y_test=test_train_split_func(X, y, test_size)
    x_mean=np.mean(X_train,axis=0)
    x_std=np.std(X_train,axis=0)
    X_train=(X_train-x_mean)/x_std
    X_test=(X_test-x_mean)/x_std
    return X_train, X_test, y_train, y_test


# ============================================
# TASK 1: LEAST SQUARES CLASSIFICATION
# ============================================

class OLSClassifier:
    """
    Ordinary Least Squares classifier using gradient descent.
    Predicts labels {-1, +1}.
    lr: learning rate
    max_iter: maximum number of iterations
    tol: tolerance for stopping criterion, (If the norm of the change in weights is less than tol, stop)
    """

    def __init__(self, lr=0.01, max_iter=1000, tol=1e-6):
        self.lr = lr
        self.max_iter = max_iter
        self.tol = tol
        self.w = None
        self.mse_loss_history = []

    def linear_gradient(self, w: np.ndarray, X: np.ndarray, y: np.ndarray) -> np.ndarray:
        """
        Compute gradient of MSE loss.

        Parameters
        ----------
        w : np.ndarray
            Weights (d,)
        X : np.ndarray
            Feature matrix (N, d)
        y : np.ndarray
            Labels {-1, +1} (N,)

        Returns
        -------
        grad : np.ndarray
            Gradient of shape (d,)
        """

        # TODO: Compute linear gradient
        N,d=X.shape
        grad = (1/N)*(X.T)@(X@w-y)
        # grad = (1/N)*X.T@(X@w-np.reshape(y,(y.shape[0],1)))
     
        return grad


    def compute_mse_loss(self, w: np.ndarray, X: np.ndarray, y: np.ndarray) -> float:
        """
        Compute MSE loss.

        Parameters
        ----------
        w : np.ndarray
            Weights (d,)
        X : np.ndarray
            Feature matrix (N, d)
        y : np.ndarray
            Labels {-1, +1} (N,)

        Returns
        -------
        loss : float
            MSE loss
        """
        l=X@w-y
        l=l**2
        loss=np.mean(l)
        return loss
        # TODO: Compute MSE loss
        pass

    def fit(self, X: np.ndarray, y: np.ndarray):
        """
        Fit the linear model using gradient descent.

        Parameters
        ----------
        X : np.ndarray
            Feature matrix (N, d)
        y : np.ndarray
            Labels {-1, +1}
        """
        # TODO: Implement batch gradient descent for MSE
        
        N,d=X.shape
        w=np.zeros((d,))
        self.mse_loss_history.append(self.compute_mse_loss(w,X,y))
        for i in range(self.max_iter):
            w_old=w.copy()
            w-=self.lr*self.linear_gradient(w,X,y)
            self.mse_loss_history.append(self.compute_mse_loss(w,X,y))
            if(np.linalg.norm(w-w_old)<self.tol):
                break

        self.w=w
        pass


    def predict(self, X: np.ndarray) -> np.ndarray:
        """
        Predict labels {-1, +1}.

        Parameters
        ----------
        X : np.ndarray
            Feature matrix (N, d)

        Returns
        -------
        y_pred : np.ndarray 
            Predicted labels (N,)
        """ 
        # TODO: Return the predictied labels
        py=X@self.w
        pys=np.where(py>=0,1,-1)
        return pys
        pass

# ============================================
# TASK 2: LOGISTIC REGRESSION
# ============================================

class LogisticRegressionGD:
    """
    Logistic Regression classifier using batch gradient descent.
    """

    def __init__(self, lr=0.01, max_iter=1000, tol=1e-6):
        self.lr = lr
        self.max_iter = max_iter
        self.tol = tol
        self.w = None
        self.logistic_loss_history = []


    def logistic_gradient(self, w: np.ndarray, X: np.ndarray, y: np.ndarray) -> np.ndarray:
        """
        Compute gradient of logistic loss.

        Parameters
        ----------
        w : np.ndarray
            Weights (d,)
        X : np.ndarray
            Feature matrix (N, d)
        y : np.ndarray
            Labels {-1, +1} (N,)

        Returns
        -------
        grad : np.ndarray
            Gradient of shape (d,)
        """

        # TODO: Compute logistic gradient
        # y=np.reshape(y,(y.shape[0],1))
        # N,d=X.shape
        # some=X@w
        # some=some*y*(-1)
        # # some=np.sum(some,axis=1)
        # some=np.exp(some)
        # some=some/(some+1)
        # some=some*(-1)*y
        # somes=X.T@some
        # sum=somes/N
        # return sum        
        # y=np.reshape(y,(y.shape[0],1))
        N,d=X.shape
        some=X@w
        some=some*y
        # some=np.sum(some,axis=1)
        some=np.exp(some)
        some=1/(some+1)
        some=some*(-1)*y
        somes=X.T@some
        sum=somes/N
        return sum
        pass


    def compute_logistic_loss(self, w: np.ndarray, X: np.ndarray, y: np.ndarray) -> float:
        """
        Compute logistic loss.

        Parameters
        ----------
        w : np.ndarray
            Weights (d,)
        X : np.ndarray
            Feature matrix (N, d)
        y : np.ndarray
            Labels {-1, +1} (N,)

        Returns
        -------
        loss : float
            Logistic loss
        """

        # TODO: Compute logistic loss
        # y=np.reshape(y,(y.shape[0],1))
        N,d=X.shape
        some=X@w
        some=some*y*(-1)
        some=np.sum(some,axis=1)
        some=np.log(np.exp(some)+1)
        sum=np.sum(some)/N

        return sum
        pass

    
    def fit(self, X: np.ndarray, y: np.ndarray):
        """
        Fit logistic regression using batch gradient descent, while adding logistic loss to history.

        Parameters
        ----------
        X : np.ndarray
            Feature matrix (N, d)
        y : np.ndarray
            Labels {-1, +1} (N,)
        """

        # TODO: Implement gradient descent for logistic regression
        i=0
        N,d=X.shape
        w=np.zeros((d,))
        self.logistic_loss_history.append(self.compute_logistic_loss(w,X,y))
        for i in range(self.max_iter):
            w_old=w.copy()
            w-=self.lr*np.reshape(self.logistic_gradient(w,X,y),(w.shape[0],))
            # self.logistic_loss_history.append(self.compute_logistic_loss(w,X,y))
            if(np.linalg.norm(w-w_old)<self.tol):
                break
        self.w=w
        pass

    def predict(self, X: np.ndarray) -> np.ndarray:
        """
        Predict labels {-1, +1}
        
        Parameters
        ----------
        X : np.ndarray
            Feature matrix (N, d)
        
        Returns
        -------
        y_pred : np.ndarray
            Predicted labels (N,)
        """

        # TODO: Implement predict method
        py=X@self.w
        pys=np.where(py>=0,1,-1)
        return pys
        pass
