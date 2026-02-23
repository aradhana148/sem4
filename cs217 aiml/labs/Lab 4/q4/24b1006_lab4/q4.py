"""
q4.py
=====
Task: Implement multi-class generative classifiers trained using

(1) Exact Normalization (Softmax)
(2) Importance Sampling (IS)
(3) Noise Contrastive Estimation (NCE)

Training is performed using mini-batch gradient descent
with on-the-fly sampling where required.

You are expected to fill in the TODOs only.
Do NOT change function signatures.
"""

import numpy as np


# ======================================================
# METRICS
# ======================================================

def accuracy(y_true, y_pred):
    """
    Compute overall classification accuracy.

    Args:
        y_true (np.ndarray): True labels, shape (N,)
        y_pred (np.ndarray): Predicted labels, shape (N,)

    Returns:
        float
    """
    # TODO
    if y_true.size == 0:
        return 0.0
    return np.sum(y_true==y_pred)/y_true.shape[0]

def precision(y_true, y_pred, cls):
    """
    Precision for class cls (one-vs-rest).

    Args:
        y_true (np.ndarray): shape (N,)
        y_pred (np.ndarray): shape (N,)
        cls (int)

    Returns:
        float
    """
    # TODO
    tp = np.sum((y_true == cls) & (y_pred == cls))
    fp = np.sum((y_true != cls) & (y_pred == cls))
    if tp + fp == 0:
        return 0.0
    return float(tp / (tp + fp))


def recall(y_true, y_pred, cls):
    """
    Recall for class cls (one-vs-rest).

    Args:
        y_true (np.ndarray): shape (N,)
        y_pred (np.ndarray): shape (N,)
        cls (int)

    Returns:
        float
    """
    # TODO
    tp = np.sum((y_true == cls) & (y_pred == cls))
    fn = np.sum((y_true == cls) & (y_pred != cls))
    if tp + fn == 0:
        return 0.0
    return float(tp / (tp + fn))


def f1_score(y_true, y_pred, cls):
    """
    F1 score for class cls.

    Args:
        y_true (np.ndarray): shape (N,)
        y_pred (np.ndarray): shape (N,)
        cls (int)

    Returns:
        float
    """
    # TODO
    p = precision(y_true, y_pred, cls)
    r = recall(y_true, y_pred, cls)
    if p + r == 0:
        return 0.0
    return float(2 * p * r / (p + r))


# ======================================================
# COMMON UTILITIES
# ======================================================

def sigmoid(z):
    """
    Sigmoid nonlinearity (used in NCE).

    Args:
        z (np.ndarray)

    Returns:
        np.ndarray: same shape as z, values in (0,1)
    """
    # TODO: use np.clip for numerical stability
    return 1/(1+np.exp(-np.clip(z,-100,100)))


def softmax(scores):
    """
    Numerically stable softmax (row-wise).

    Args:
        scores (np.ndarray): shape (B, K)

    Returns:
        np.ndarray: probabilities, shape (B, K)
    """
    # TODO
    B,K=scores.shape
    maxs=np.reshape(np.max(scores,axis=1),(B,1))
    scores=scores-maxs
    exp_sc=np.exp(scores)
    sums=np.reshape(np.sum(exp_sc,axis=1),(B,1))
    prb=exp_sc/sums
    return prb


# ======================================================
# GENERIC SAMPLER INTERFACE
# ======================================================

class Sampler:
    """
    Generic sampler interface.

    Students are encouraged to subclass this class to implement
    any proposal or noise distribution they want.
    """

    def sample(self, num_samples):
        """
        Draw samples from q.

        Args:
            num_samples (int)

        Returns:
            np.ndarray
        """
        raise NotImplementedError

    def prob(self, samples):
        """
        Evaluate q(samples).

        Args:
            samples (np.ndarray)

        Returns:
            np.ndarray: densities, shape (num_samples,)
        """
        raise NotImplementedError


class GaussianSampler(Sampler):
    """
    Example sampler: multivariate Gaussian q(x).
    """

    def __init__(self, mean, cov):
        """
        Args:
            mean (np.ndarray): shape (D,)
            cov (np.ndarray): shape (D, D)
        """
        self.mean = mean
        self.cov = cov
        self._D = mean.shape[0]
        self._chol = np.linalg.cholesky(cov)
        self._logdet = 2.0 * np.sum(np.log(np.diag(self._chol)))
        self._log_norm = 0.5 * (self._D * np.log(2.0*np.pi) + self._logdet)

    def sample(self, num_samples):
        """
        Returns:
            np.ndarray: samples, shape (num_samples, D)
        """
        # TODO
        return np.random.multivariate_normal(self.mean,self.cov,num_samples)

    def prob(self, samples):
        """
        Args:
            samples (np.ndarray): shape (num_samples, D)

        Returns:
            densities (np.ndarray): shape (num_samples,)
        """
        # TODO
        diff = (samples - self.mean)
        sol = np.linalg.solve(self._chol, diff.T)
        maha = np.sum(sol * sol, axis=0)
        logp = -0.5 * maha - self._log_norm
        return np.exp(logp)

class CategoricalSampler(Sampler):
    """
    Example sampler: categorical distribution q(y).
    """

    def __init__(self, probs):
        """
        Args:
            probs (np.ndarray): shape (K,)
        """
        self.probs = probs

    def sample(self, num_samples):
        """
        Returns:
            np.ndarray: sampled labels, shape (num_samples,)
        """
        # TODO
        return np.random.choice(len(self.probs),num_samples,p=self.probs)

    def prob(self, samples):
        """
        Args:
            samples (np.ndarray): shape (num_samples,)

        Returns:
            densities (np.ndarray) : shape (num_samples,)
        """
        # TODO
        return self.probs[samples]


# ======================================================
# SOFTMAX GENERATIVE CLASSIFIER (EXACT NORMALIZATION)
# ======================================================

class SoftmaxGenerativeClassifier:
    """
    Multi-class generative classifier trained using
    exact normalization (softmax).
    """

    def __init__(self, num_classes, lr=1e-2, batch_size=64, max_epochs=50):
        """
        Args:
            num_classes (int): K
            lr (float)
            batch_size (int)
            max_epochs (int)
        """
        self.K = num_classes
        self.lr = lr
        self.batch_size = batch_size # also referred to as B in a lot of places
        self.max_epochs = max_epochs

        # Discriminative parameters
        self.W = None  # shape (K, D)
        self.b = None  # shape (K,)

        # Recovered generative parameters
        self.mu = None     # shape (K, D)
        self.Sigma = None # shape (D, D)
        self.pi = None    # shape (K,)

    def score(self, X):
        """
        Compute unnormalized scores p(x,y).

        Args:
            X (np.ndarray): shape (B, D)

        Returns:
            np.ndarray: shape (B, K)
        """
        # TODO
        return (X@self.W.T+np.reshape(self.b,(1,-1)))

    def gradients(self, X, y):
        """
        Gradients of conditional log-likelihood.

        Args:
            X (np.ndarray): shape (B, D)
            y (np.ndarray): shape (B,)

        Returns:
            tuple W,b
                'W': np.ndarray, shape (K, D)
                'b': np.ndarray, shape (K,)
        """
        B,D=X.shape
        K=self.K
        h=softmax(self.score(X))
        ty=np.eye(K)
        ty=ty[y]
        diff=(h-ty)
        W=(diff.T@X)/B
        b=np.sum(diff,axis=0)/B
        return W,b

    def fit(self, X, y):
        """
        Train using mini-batch gradient descent.

        Args:
            X (np.ndarray): shape (N, D)
            y (np.ndarray): shape (N,)
        """
        # TODO
        N,D=X.shape
        K=self.K
        self.W=np.zeros((K,D))
        self.b=np.zeros((K,))

        for i in range(self.max_epochs):
            rando=np.random.permutation(N)
            Xr=X[rando]
            yr=y[rando]
            for j in range(0,N,self.batch_size):
                X_batch=Xr[j:j+self.batch_size]
                y_batch=yr[j:j+self.batch_size]
                dw,db=self.gradients(X_batch,y_batch)
                self.W-=self.lr*dw
                self.b-=self.lr*db

    def predict_proba(self, X):
        """
        Compute p(y|x) using exact softmax.

        Args:
            X (np.ndarray): shape (N, D)

        Returns:
            np.ndarray: shape (N, K)
        """
        # TODO
        return softmax(self.score(X))

    def predict(self, X):
        """
        Returns the actual prediction on the basis of predicted probabilities

        Args:
            X (np.ndarray): shape (N, D)

        Returns:
            np.ndarray: shape (N,)
        """
        # TODO 
        return np.argmax(self.predict_proba(X), axis=1)

    def recover_parameters(self):
        """
        Recover Gaussian parameters from trained W and b.


        Stores the parameters pi_k and Sigma into the class variables, note that self.mu
        will be populated by the main code by this point, so assume that self.mu contains the correct value
        """
        # TODO
        Sigma_inv = np.linalg.inv(self.mu.T @ self.mu) @ self.mu.T @ self.W
        self.Sigma = np.linalg.inv(Sigma_inv)
        K = self.K
        pi = np.zeros(K)
        for k in range(K):
            mu_k = self.mu[k]
            term = 0.5 * mu_k.T @ Sigma_inv @ mu_k
            pi[k] = np.exp(self.b[k] + term)
        self.pi = pi / np.sum(pi)


# ======================================================
# IMPORTANCE SAMPLING CLASSIFIER
# ======================================================

class ImportanceSamplingClassifier:
    """
    Multi-class generative classifier trained using
    importance sampling to approximate normalization.
    """

    def __init__(self, num_classes, lr=1e-2,
                 batch_size=64, num_samples=10, max_epochs=50,
                 class_sampler=None):
        """
        Args:
            num_classes (int)
            lr (float)
            batch_size (int)
            num_samples (int): M
            max_epochs (int)
            class_sampler (Sampler): q(y)
        """
        self.K = num_classes
        self.lr = 1e-2
        self.batch_size = batch_size
        self.M = num_samples
        self.max_epochs = 5
        self.class_sampler = class_sampler

        self.W = None  # shape (K, D)
        self.b = None  # shape (K,)

    def score(self, X):
        """
        Args:
            X (np.ndarray): shape (B, D)

        Returns:
            np.ndarray: shape (B, K)
        """
        # TODO
        return X @ self.W.T + self.b[np.newaxis, :]

    def estimate_normalizer(self, X):
        """
        Importance-sampled estimate of Z(x). Note that you should reuse the samples of y obtained for 1 batch
        Only draw new samples when you move to the next batch in training

        Args:
            X (np.ndarray): shape (B, D)

        Returns:
            np.ndarray: shape (B,)
        """
        scores_all = self.score(X)  # (B, K)
        sampled_scores = scores_all[:, self._y_samples]  # (B, M)
        q_probs = self.class_sampler.prob(self._y_samples)  # (M,)
        log_w = sampled_scores - np.log(q_probs)[np.newaxis, :]  # (B, M)
        max_log_w = np.max(log_w, axis=1, keepdims=True)  # (B, 1)
        Z_hat = (1.0 / self.M) * np.sum(np.exp(log_w - max_log_w), axis=1) * np.exp(max_log_w[:, 0])
        return Z_hat  # (B,)

    def gradients(self, X, y):
        """
        Gradients of IS objective.

        Args:
            X (np.ndarray): shape (B, D)
            y (np.ndarray): shape (B,)

        Returns:
            grad_W,grad_b
                'grad_W': np.ndarray, shape (K, D)
                'grad_b': np.ndarray, shape (K,)
        """
        B, D = X.shape
        K = self.K
        M = self.M
        one_hot_pos = np.zeros((B, K))  # (B, K)
        one_hot_pos[np.arange(B), y] = 1.0
        grad_W_pos = one_hot_pos.T @ X  # (K, D)
        grad_b_pos = one_hot_pos.sum(axis=0)  # (K,)
        scores_all = self.score(X)  # (B, K)
        sampled_scores = scores_all[:, self._y_samples]  # (B, M)
        q_probs = self.class_sampler.prob(self._y_samples)  # (M,)
        log_w = sampled_scores - np.log(q_probs)[np.newaxis, :]  # (B, M)
        max_log_w = np.max(log_w, axis=1, keepdims=True)
        w_unnorm = np.exp(log_w - max_log_w)  # (B, M)
        w_norm = w_unnorm / (w_unnorm.sum(axis=1, keepdims=True) + 1e-300)  # (B, M)
        grad_W_neg = np.zeros((K, D))
        grad_b_neg = np.zeros(K)
        np.add.at(grad_W_neg, self._y_samples, w_norm.T @ X)   # (M, D) added into K rows
        np.add.at(grad_b_neg, self._y_samples, w_norm.sum(axis=0))  # (M,) added into K rows

        grad_W = (grad_W_neg - grad_W_pos) / B
        grad_b = (grad_b_neg - grad_b_pos) / B
        return grad_W, grad_b

    def fit(self, X, y):
        """
        Train using mini-batch gradient descent.

        Args:
            X (np.ndarray): shape (N, D)
            y (np.ndarray): shape (N,)
        """
        N, D = X.shape
        K = self.K
        self.W = np.zeros((K, D))
        self.b = np.zeros(K)

        for epoch in range(self.max_epochs):
            perm = np.random.permutation(N)
            X_shuf = X[perm]
            y_shuf = y[perm]
            for start in range(0, N, self.batch_size):
                X_batch = X_shuf[start:start + self.batch_size]
                y_batch = y_shuf[start:start + self.batch_size]
                self._y_samples = self.class_sampler.sample(self.M)  # (M,)
                dW, db = self.gradients(X_batch, y_batch)
                self.W -= self.lr * dW
                self.b -= self.lr * db

    def predict_proba(self, X):
        """
        Args:
            X (np.ndarray): shape (N, D)

        Returns:
            np.ndarray: shape (N, K)
        """
        return softmax(self.score(X))

    def predict(self, X):
        """
        Returns the actual prediction on the basis of predicted probabilities

        Args:
            X (np.ndarray): shape (N, D)

        Returns:
            np.ndarray: shape (N,)
        """
        return np.argmax(self.predict_proba(X), axis=1)


# ======================================================
# NOISE CONTRASTIVE ESTIMATION CLASSIFIER
# ======================================================

class NCEClassifier:
    """
    Multi-class generative classifier trained using
    Noise Contrastive Estimation.
    """

    def __init__(self, num_classes, lr=1e-2,
                 batch_size=64, noise_ratio=5, max_epochs=500,
                 x_sampler=None, y_sampler=None):
        """
        Args:
            num_classes (int)
            lr (float)
            batch_size (int)
            noise_ratio (int): k
            max_epochs (int)
            x_sampler (Sampler): q(x)
            y_sampler (Sampler): q(y)
        """
        self.K = num_classes
        self.lr = 9*(1e-2)
        self.batch_size = batch_size
        self.k = noise_ratio
        self.max_epochs = 15
        self.x_sampler = x_sampler
        self.y_sampler = y_sampler

        self.W = None  # shape (K, D)
        self.b = None  # shape (K,)
        self.c = None  # scalar

    def score(self, X, y):
        """
        Compute log p_theta(x,y) = f_theta(x,y) - c = w_{y}^T x + b_{y} - c.

        Args:
            X (np.ndarray): shape (B, D)
            y (np.ndarray): shape (B,)

        Returns:
            np.ndarray: shape (B,)  — one score per sample
        """
        return np.einsum('bd,bd->b', X, self.W[y]) + self.b[y] - self.c

    def sample_noise(self, num_samples):
        """
        Sample noise pairs from q(x,y) = q(x) * q(y).

        Args:
            num_samples (int)

        Returns:
            tuple:
                X_noise (np.ndarray): shape (num_samples, D)
                y_noise (np.ndarray): shape (num_samples,)
        """
        X_noise = self.x_sampler.sample(num_samples)   # (num_samples, D)
        y_noise = self.y_sampler.sample(num_samples)   # (num_samples,)
        return X_noise, y_noise

    def gradients(self, X, y):
        """
        Gradients of NCE objective (minimizing loss).

        NCE loss (for a mini-batch of B data + B*k noise samples):
          L = -sum_i log sigma(f(x_i,y_i) - c - log(k*q(x_i,y_i)))
            - sum_i sum_j log sigma(-(f(x_noise,y_noise) - c - log(k*q(x_noise,y_noise))))

        Args:
            X (np.ndarray): shape (B, D)
            y (np.ndarray): shape (B,)

        Returns:
            grad_W, grad_b, grad_c
        """
        B, D = X.shape
        K = self.K
        k = self.k  # noise ratio

        # --- data samples ---
        log_qx_data = np.log(self.x_sampler.prob(X) + 1e-300)    # (B,)
        log_qy_data = np.log(self.y_sampler.prob(y) + 1e-300)    # (B,)
        log_q_data = log_qx_data + log_qy_data                    # (B,)

        f_data = self.score(X, y)                                  # (B,)
        u_data = f_data - np.log(k) - log_q_data                  # (B,)
        sig_data = sigmoid(u_data)                                 # (B,)  = P(D=1|data)

        X_n, y_n = self.sample_noise(B * k)                        # (B*k, D), (B*k,)
        log_qx_noise = np.log(self.x_sampler.prob(X_n) + 1e-300)  # (B*k,)
        log_qy_noise = np.log(self.y_sampler.prob(y_n) + 1e-300)  # (B*k,)
        log_q_noise = log_qx_noise + log_qy_noise                  # (B*k,)

        f_noise = self.score(X_n, y_n)                             # (B*k,)
        u_noise = f_noise - np.log(k) - log_q_noise               # (B*k,)
        sig_noise = sigmoid(u_noise)                               # (B*k,)  = P(D=1|noise)

        delta_data = sig_data - 1.0   # (B,)   positive = sig - 1 (for loss minimization)
        delta_noise = sig_noise        # (B*k,)

        grad_W = np.zeros((K, D))
        grad_b = np.zeros(K)

        np.add.at(grad_W, y,   (delta_data[:, np.newaxis] * X))   # (K, D)
        np.add.at(grad_b, y,    delta_data)

        np.add.at(grad_W, y_n, (delta_noise[:, np.newaxis] * X_n))
        np.add.at(grad_b, y_n,  delta_noise)

        grad_c = float(np.sum(1.0 - sig_data) - np.sum(sig_noise))

        total = B + B * k
        grad_W /= total
        grad_b /= total
        grad_c /= total
        return grad_W, grad_b, grad_c

    def fit(self, X, y):
        """
        Train using mini-batch gradient descent.

        Args:
            X (np.ndarray): shape (N, D)
            y (np.ndarray): shape (N,)
        """
        N, D = X.shape
        K = self.K
        self.W = np.zeros((K, D))
        self.b = np.zeros(K)
        self.c = 0.0  # log normalizer parameter

        for epoch in range(self.max_epochs):
            perm = np.random.permutation(N)
            X_shuf = X[perm]
            y_shuf = y[perm]
            for start in range(0, N, self.batch_size):
                X_batch = X_shuf[start:start + self.batch_size]
                y_batch = y_shuf[start:start + self.batch_size]
                dW, db, dc = self.gradients(X_batch, y_batch)
                self.W -= self.lr * dW
                self.b -= self.lr * db
                self.c -= self.lr * dc

    def predict_proba(self, X):
        """
        Args:
            X (np.ndarray): shape (N, D)

        Returns:
            np.ndarray: shape (N, K)
        """
        scores = X @ self.W.T + self.b[np.newaxis, :]  # (N, K), c cancels in softmax
        return softmax(scores)

    def predict(self, X):
        """
        Returns the actual prediction on the basis of predicted probabilities

        Args:
            X (np.ndarray): shape (N, D)

        Returns:
            np.ndarray: shape (N,)
        """
        return np.argmax(self.predict_proba(X), axis=1)