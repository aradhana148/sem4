import numpy as np
import pandas as pd

class KNN:
    def __init__(self, k=5):
        self.k = k
        self.X_train = None
        self.y_train = None

    def fit(self, X, y):
        """
        Store the training data and labels.
        Parameters:
            X: Training features (numpy array)
            y: Training labels (numpy array)
        """
        self.X_train = X
        self.y_train = y

    def predict_L2(self, X_test, k):
        """
        Predict labels for the test set using L2 (Euclidean) distance.
        Parameters:
            X_test: Test features (numpy array)
            k: Number of neighbors
        Returns:
            y_pred: Predicted labels for X_test (numpy array of +1 or -1)
        """
        # TODO: Implement vectorized L2 distance and majority vote
        # x=np.array(self.X_train)
        diff = X_test[:,None,:]-self.X_train[None,:,:]
        diff=diff**2
        d=diff.sum(axis=2)
        top_k_index=np.argpartition(d,k-1,axis=1)[:,:k]
        k_train=self.y_train[top_k_index].sum(axis=1)
        y_pred=np.where(k_train>=0,1,-1)
        return y_pred

        
    def predict_L1(self, X_test, k):
        """
        Predict labels for the test set using L1 (Manhattan) distance.
        Parameters:
            X_test: Test features (numpy array)
            k: Number of neighbors
        Returns:
            y_pred: Predicted labels for X_test (numpy array of +1 or -1)
        """
        # TODO: Implement vectorized L1 distance and majority vote
        diff = X_test[:,None,:]-self.X_train[None,:,:]
        diff=abs(diff)
        mean=diff.sum(axis=2)
        top_k_index=np.argpartition(mean,k-1,axis=1)[:,:k]
        k_train=self.y_train[top_k_index].sum(axis=1)
        y_pred=np.where(k_train>=0,1,-1)
        return y_pred

def compute_accuracy(y_true, y_pred):
    """
    Calculate the percentage of correct predictions.
    Parameters:
        y_true: Ground truth labels
        y_pred: Predicted labels
    Returns:
        accuracy: Float representing accuracy
    """
    # TODO: Implement accuracy calculation
    diff=y_true-y_pred
    count=np.where(diff!=0,0,1)
    acc=count.mean()*100
    return acc

def standardize(X_train, X_test):
    """
    Standardize features to mean 0 and variance 1.
    Parameters:
        X_train: Raw training features
        X_test: Raw test features
    Returns:
        X_train_std, X_test_std: Standardized feature arrays
    """
    # TODO: Standardize X_test using statistics derived ONLY from X_train
    mean=X_train.mean(axis=0)
    std_dev=X_train.std(axis=0)
    std_dev=np.where(std_dev==0,1,std_dev)
    X_train_std, X_test_std=(X_train-mean)/std_dev,(X_test-mean)/std_dev
    return X_train_std,X_test_std


def get_pearson_indices(X, y, m):
    """
    Select top m features based on absolute Pearson correlation with label y.
    Parameters:
        X: Feature array
        y: Label array
        m: Number of features to select
    Returns:
        indices: Array of indices for the top m features
    """
    # TODO: Implement vectorized Pearson correlation and return top m indices
    # num_first=X-X.mean(axis=0)[None,:] #without [None,:] also works
    X=np.array(X)
    y=np.array(y)
    n=y.shape[0]

    Xc=X-X.mean(axis=0)
    yc=(y-y.mean())[:,None]


    num=(Xc*yc).mean(axis=0)*n
    Xc=Xc**2
    Xc_sum=(Xc.mean(axis=0)*n)
    yc_sum=((yc**2).mean(axis=0)*n)
    den=(Xc_sum*yc_sum)**(0.5)
    ris=num/den
    top_m_index=np.argpartition(-np.abs(ris),m-1,axis=0)[:m]
    return top_m_index
   

if __name__ == "__main__":
    # you are allowed to use loops here

    # TODO: Load data using pandas
    df_train=pd.read_csv("q2_train.csv")
    df_test=pd.read_csv("q2_test.csv")
    x_train=df_train.iloc[:,:-1].to_numpy()
    y_train=df_train.iloc[:,-1].to_numpy()
    x_test=df_test.iloc[:,:-1].to_numpy()
    y_test=df_test.iloc[:,-1].to_numpy()

    knn=KNN()
    knn.fit(x_train,y_train)
    # TODO: Execute Task A (Vary k, use L2)
    y_pred=knn.predict_L2(x_test,k=20)
    acc=compute_accuracy(y_test,y_pred)
    print(acc)

    # TODO: Execute Task B (Standardize, then vary m for Pearson selection, use k=20, L2)
    X_train_std, X_test_std = standardize(x_train, x_test)

    knn.fit(X_train_std, y_train)
    for m in [5, 10, 20, 50, 100]:
        idx = get_pearson_indices(X_train_std, y_train, m)
        Xtr_m = X_train_std[:, idx]
        Xte_m = X_test_std[:, idx]

        knn.fit(Xtr_m, y_train)                 # <-- key line
        y_pred = knn.predict_L2(Xte_m, 20)

        acc = compute_accuracy(y_test, y_pred)
        print(f"Task B | m={m:>3} | k=20 L2 acc = {acc:.2f}%")



    # ---------------- Task C: Standardize, all features, k=20, L1 ----------------
    knn.fit(X_train_std, y_train)          # <-- add this
    y_pred = knn.predict_L1(X_test_std, 20)
    acc = compute_accuracy(y_test, y_pred)
    print(f"Task C | k=20 | L1 acc = {acc:.2f}%")
    # TODO: Execute Task C (Standardize, use all features, use k=20, L1)
    