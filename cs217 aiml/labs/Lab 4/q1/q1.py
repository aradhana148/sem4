"""
q1.py
=====
Task: Implement Naive and Weighted Logistic Regression.
      Handle Covariate Shift where Train and Test distributions differ.
"""

import numpy as np

# ============================================
# PART 1: METRICS
# ============================================

def get_true_positives(y_true, y_pred):
    """ Count samples where y_true=1 and y_pred=1 
    Args:
        y_true (np.ndarray): True labels.
        y_pred (np.ndarray): Predicted labels.
    Returns:
        Float/Int
    """
    # TODO
    y=np.zeros((y_pred.shape[0],))
    y=np.where(y_true==1,1,0)
    z=np.where(y_pred==1,1,0)
    y=y*z
    sum=np.sum(y)
    return sum
    pass

def get_false_positives(y_true, y_pred):
    """ Count samples where y_true=0 and y_pred=1 
    Args:
        y_true (np.ndarray): True labels.
        y_pred (np.ndarray): Predicted labels.
    Returns:
        Float/Int
    """
    # TODO
    y=np.zeros((y_pred.shape[0],))
    y=np.where(y_true==0,1,0)
    z=np.where(y_pred==1,1,0)
    y=y*z
    sum=np.sum(y)
    return sum
    pass

def get_false_negatives(y_true, y_pred):
    """ Count samples where y_true=1 and y_pred=0 
    Args:
        y_true (np.ndarray): True labels.
        y_pred (np.ndarray): Predicted labels.
    Returns:
        Float/Int
    """
    # TODO
    y=np.zeros((y_pred.shape[0],))
    y=np.where(y_true==1,1,0)
    z=np.where(y_pred==0,1,0)
    y=y*z
    sum=np.sum(y)
    return sum
    pass

def get_true_negatives(y_true, y_pred):
    """ Count samples where y_true=0 and y_pred=0 
    Args:
        y_true (np.ndarray): True labels.
        y_pred (np.ndarray): Predicted labels.
    Returns:
        Float/Int
    """
    # TODO
    y=np.zeros((y_pred.shape[0],))
    y=np.where(y_true==0,1,0)
    z=np.where(y_pred==0,1,0)
    y=y*z
    sum=np.sum(y)
    return sum
    pass

def get_precision(y_true, y_pred):
    """
    Args:
        y_true (np.ndarray): True labels.
        y_pred (np.ndarray): Predicted labels.
    Returns:
        float: Precision score.
    """
    # TODO

    return (get_true_positives(y_true,y_pred)/(get_true_positives(y_true,y_pred)+get_false_positives(y_true,y_pred)))

def get_recall(y_true, y_pred):
    """
    Args:
        y_true (np.ndarray): True labels.
        y_pred (np.ndarray): Predicted labels.
    Returns:
        float: Recall score.
    """
    # TODO
    return (get_true_positives(y_true,y_pred)/(get_true_positives(y_true,y_pred)+get_false_negatives(y_true,y_pred)))


def get_f1_score(y_true, y_pred):
    """
    Args:
        y_true (np.ndarray): True labels.
        y_pred (np.ndarray): Predicted labels.
    Returns:
        float: F1 score.
    """
    # TODO
    pre=get_precision(y_true,y_pred)
    rec=get_recall(y_true,y_pred)
    f1=2*pre*rec
    f1=f1/(pre+rec)
    return f1

def get_multiclass_accuracy(y_true, y_pred):
    """
    Args:
        y_true (np.ndarray): True labels.
        y_pred (np.ndarray): Predicted labels.
    Returns:
        float: Fraction of correctly classified samples.
    """
    # TODO. Ensure this function works for multi-class as well.
    y=np.zeros((y_pred.shape[0],))
    y=np.where((y_true==y_pred),1,0)
    sum=np.sum(y)
    sum=sum/y_pred.shape[0]
    return sum


# ============================================
# PART 2: THE CLASS-WEIGHTED BINARY CLASSIFIER 
# ============================================

class BaseLogisticClassifier:
    """
    The Base Engine. Implements Gradient Descent.
    Sample weights are passed directly to fit().
    """
    def __init__(self, lr=0.5, max_iter=4000, tol=1e-6):
        self.lr = lr
        self.max_iter = max_iter
        self.tol = tol
        self.w = None
        self.loss_history = []

    def sigmoid(self, z):
        """
        Args:
            z (np.ndarray): Input array.
        Returns:
            np.ndarray: Values between 0 and 1.
        """
        # TODO: Implement sigmoid (use np.clip to prevent overflow)
        z=np.clip(z,-100,100)
        p=1/(1+np.exp(-z))
        return p
        pass

    def compute_loss(self, y_true, y_pred, sample_weights):
        """
        Computes the Weighted Binary Cross-Entropy Loss.
        
        Args:
            y_true (np.ndarray): True labels (0 or 1). Shape (N,).
            y_pred (np.ndarray): Predicted probabilities. Shape (N,).
            sample_weights (np.ndarray): Weights for each sample. Shape (N,).
            
        Returns:
            float: The weighted average loss.
        """
        # TODO: Implement weighted binary cross entropy.
        eps = 1e-12
        y_pred = np.clip(y_pred, eps, 1 - eps)
        diff=y_true*np.log(y_pred)+(1-y_true)*np.log(1-y_pred)
        diff=diff*sample_weights
        num=np.sum(diff)
        den=np.sum(sample_weights)
        return -num/den

    def compute_gradient(self, X, y_true, y_pred, sample_weights):
        """
        Computes the weighted gradient of the loss with respect to weights w.
        
        Args:
            X (np.ndarray): Feature matrix (N, D).
            y_true (np.ndarray): True labels (N,).
            y_pred (np.ndarray): Predicted probabilities (N,).
            sample_weights (np.ndarray): Sample weights (N,).
            
        Returns:
            np.ndarray: Gradient vector of shape (D,).
        """
        # TODO: Compute weighted gradient
        diff=y_pred-y_true
        den=np.sum(sample_weights)
        return (X.T@(sample_weights*diff))/den

    def fit(self, X, y, sample_weights):
        """
        Main optimization loop.
        """
        #TODO: Initialize self.w and self.loss_history and any other variables, initialize weights to zero
        N,d=X.shape
        w=np.zeros((d,))
        # self.loss_history.append(self.compute_loss(y,np.zeros(N,),sample_weights))

        for i in range(self.max_iter):
            # TODO: Implement the training loop
            pred_y=1/(1+np.exp(-1*np.clip(X@w,-100,100)))
            grad=self.compute_gradient(X,y,pred_y,sample_weights)
            self.loss_history.append(self.compute_loss(y,pred_y,sample_weights))
            if(np.linalg.norm(grad)<self.tol):
                break
            w-=self.lr*grad
        self.w=w

    def predict_proba(self, X):
        """
        Predict probability of class 1.
        Args:
            X (np.ndarray): Feature matrix (N, D).
        Returns:
            np.ndarray: Probabilities (N,).
        """
        # TODO

        pred_y=1/(1+np.exp(-1*np.clip(X@self.w,-100,100)))
        return pred_y


# ============================================
# PART 3: MULTI-CLASS WRAPPER (ONE-VS-REST)
# ============================================

class OneVsRestClassifier:
    """
    Single Class to handle both Naive and Weighted Multi-class Strategies.
    """
    def __init__(self, mode='naive', lr=0.5, max_iter=4000, test_ratios=None):
        """
        Args:
            mode (str): 'naive' or 'weighted'.
            lr (float): Learning rate.
            max_iter (int): Maximum iterations.
            test_ratios (dict): The target distribution for the 'weighted' mode.
                                Example: {0: 0.33, 1: 0.33, 2: 0.33}
        """
        self.mode = mode
        self.lr = lr
        self.max_iter = max_iter
        self.test_ratios = test_ratios
        self.logistic_models = {} #A dictionary with Key: class label (int), Value: an object of type BaseLogisticClassifier

    def _get_binary_weights(self, y_binary, class_label):
        """
        Helper to calculate sample weights for a specific binary problem.
        
        Args:
            y_binary (np.ndarray): Binary targets (0 or 1) for the current class.
            class_label (int/str): The current class label being trained.
            
        Returns:
            np.ndarray: Array of weights, one for each sample. shape (N,)
        """
        # TODO: Return weights based on self.mode
        N=y_binary.shape[0]
        # If mode is 'naive', return an array of 0.5's
        if(self.mode=="naive"):
            return (np.ones((N,))/2)
        # If mode is 'weighted', calculate importance weights using the scheme listed in PS.
        else:
            count=np.sum(y_binary)
            p_train1=count/N
            p_test1=self.test_ratios[class_label]
            w_pos=p_test1/p_train1
            w_neg=(1-p_test1)/(1-p_train1)
            weights=np.where(y_binary==1,w_pos,w_neg)
            return weights

    def fit(self, X, y):
        """
        Trains K binary classifiers.
        
        Args:
            X (np.ndarray): Feature matrix of shape (N, D).
            y (np.ndarray): Multiclass labels of shape (N,).
        """
        classes = np.unique(y)
        #TODO:
        
        
        for k in classes:
            #TODO:
            bin_y=np.where(y==k,1,0)
            weights=self._get_binary_weights(bin_y,k)
            b=BaseLogisticClassifier()
            b.fit(X,bin_y,weights)
            self.logistic_models[k]=b
    def predict(self, X):
        """
        Predict class with highest probability.
        
        Args:
            X (np.ndarray): Feature matrix of shape (N, D).
            
        Returns:
            np.ndarray: Predicted class labels of shape (N,).
        """
        # TODO: Iterate over self.logistic_models
        # Return the class with the maximum probability.
        # To get the keys of a dictionary dict.keys() may be helpful... Read the python docs for more
        N,d=X.shape
        k=self.logistic_models.keys()
        prob=np.zeros((X.shape[0],len(k)))
        for i in k:
           prob[:,int(i)]=self.logistic_models[i].predict_proba(X)
        return np.argmax(prob,axis=1)


        
