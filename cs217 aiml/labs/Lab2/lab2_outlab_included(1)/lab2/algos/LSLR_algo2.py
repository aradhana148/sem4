import numpy as np
from typing import Callable, Optional, Tuple, List
from functions.func import func
from .optim import LSLROptimiser


class LSLRAlgo2(LSLROptimiser):
    """
    Gradient Descent for LSLR with optimal learning rate.
    
    Uses η = 1/L where L is the Lipschitz constant (largest eigenvalue of Hessian).
    For f(w) = (1/2n)||Xw - y||^2, Hessian = (1/n) X^T X
    """
    
    def __init__(self, X: np.ndarray, y: np.ndarray) -> None:
        super().__init__(X, y)
        n,d=X.shape
        self.XTX = X.T @ X / n
        self.Xy = X.T @ y / n
        self.L_coords = np.diag(self.XTX)
        self.L_coords = np.maximum(self.L_coords, 1e-10)

    def lr(self) -> float:
        return 1.0
    
    def step(self, params: np.ndarray) -> np.ndarray:
        grad = self.XTX @ params - self.Xy
        gamma = np.argmax(np.abs(grad))
        w = params.copy()
        grad_gamma = grad[gamma]
        step_size = 1.0 / self.L_coords[gamma]
        w[gamma] -= step_size * grad_gamma
        return w

    def eval_lslr(self, w: np.ndarray) -> float:
        residuals = self.X @ w - self.y
        return 0.5 * np.mean(residuals ** 2)

    def stoch_grad(self, w: np.ndarray, gamma: int) -> np.ndarray:
        residuals = self.X @ w - self.y
        grad_val = (self.X[:, gamma].T @ residuals) / self.n_samples
        g = np.zeros_like(w)
        g[gamma] = grad_val
        return g

