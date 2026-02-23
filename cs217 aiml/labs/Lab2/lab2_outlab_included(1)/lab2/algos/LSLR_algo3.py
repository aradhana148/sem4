import numpy as np
from typing import Callable, Optional, Tuple, List
from functions.func import func
from .optim import LSLROptimiser


class LSLRAlgo3(LSLROptimiser):
    def __init__(self, X: np.ndarray, y: np.ndarray, inner_iterations: int = None) -> None:
        super().__init__(X, y)
        self.N = 2 * self.n_samples
        n, d = X.shape
        XTX = X.T @ X / n
        eigenvalues = np.linalg.eigvalsh(XTX)
        if len(eigenvalues) > 0:
            L = float(np.max(eigenvalues))
            if L > 1e-10:
                self.eta = 1.0 / (10*L)
            else:
                self.eta = 0.01
        else:
            self.eta = 0.01

    def lr(self) -> float:
        return self.eta

    def step(self, params: np.ndarray) -> np.ndarray:
        w_snapshot = params.copy()
        full_gradient_snapshot = self.full_grad(w_snapshot)
        w_inner = w_snapshot.copy()
        for t in range(self.N):
            i_t = np.random.randint(0, self.n_samples)
            G = self.svrg_gradient(w_inner, w_snapshot, full_gradient_snapshot, i_t)
            w_inner = w_inner - self.lr() * G
        
        self.epochs_done += 1
        return w_inner

    def svrg_gradient(self, w: np.ndarray, w_snapshot: np.ndarray, full_grad_snapshot: np.ndarray, i: int) -> np.ndarray:
        grad_i_w = self.sample_grad(w, i)
        grad_i_snapshot = self.sample_grad(w_snapshot, i)
        G = grad_i_w - grad_i_snapshot + full_grad_snapshot
        return G

    def sample_grad(self, w: np.ndarray, i: int) -> np.ndarray:
        X_i = self.X[i, :]
        y_i = self.y[i]
        residual = np.dot(X_i, w) - y_i
        grad = X_i * residual
        return grad

    def eval_lslr(self, w: np.ndarray) -> float:
        residuals = self.X @ w - self.y
        return 0.5 * np.mean(residuals ** 2)

    def full_grad(self, w: np.ndarray) -> np.ndarray:
        residuals = self.X @ w - self.y
        return (self.X.T @ residuals) / self.n_samples