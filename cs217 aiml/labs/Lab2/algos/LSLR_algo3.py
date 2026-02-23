import numpy as np
from typing import Callable, Optional, Tuple, List
from functions.func import func
from .optim import LSLROptimiser


class LSLRAlgo3(LSLROptimiser):
    """
    Gradient Descent for LSLR with optimal learning rate.
    
    Uses η = 1/L where L is the Lipschitz constant (largest eigenvalue of Hessian).
    For f(w) = (1/2n)||Xw - y||^2, Hessian = (1/n) X^T X
    """
    
    def __init__(self, X: np.ndarray, y: np.ndarray) -> None:
        super().__init__(X, y)
        
        ## TODO Use this for any pre-computations you need
        # Greedy Coordinate Descent
        # We need efficient gradient updates.
        # Grad = (1/n) X^T (Xw - y)
        # We maintain residuals or full gradient?
        # Let's precompute X^T X for fast gradient updates if d is small.
        # But if d is large, maybe not. Here d <= 100.
        
        n, d = X.shape
        self.XTX = X.T @ X / n
        self.Xy = X.T @ y / n
        
        # Lipschitz constants
        self.L_coords = np.diag(self.XTX)
        self.L_coords = np.maximum(self.L_coords, 1e-10)

    def lr(self) -> float:
        ## TODO learning rate schedule
        return 1.0
    def step(self, params: np.ndarray) -> np.ndarray:
        ## TODO Implement the step method
        # Greedy Selection: Pick coordinate with largest gradient magnitude
        
        # Calculate full gradient
        # Since we precomputed XTX and Xy, grad = XTX w - Xy
        grad = self.XTX @ params - self.Xy
        
        # Find index with max absolute gradient
        gamma = np.argmax(np.abs(grad))
        
        w = params.copy()
        grad_gamma = grad[gamma]
        
        step_size = 1.0 / self.L_coords[gamma]
        w[gamma] -= step_size * grad_gamma
        
        return w

    def eval_lslr(self, w: np.ndarray) -> float:
        ## TODO Evaluate LSLR objective: (1/n)||Xw - y||^2
        residuals = self.X @ w - self.y
        return 0.5 * np.mean(residuals ** 2)

    def full_grad(self, w: np.ndarray) -> np.ndarray:
        ## TODO 
        residuals = self.X @ w - self.y
        return (self.X.T @ residuals) / self.n_samples

    def stoch_grad(self, w: np.ndarray, gamma: int) -> np.ndarray:
        ## TODO Implement stochastic gradient computation
        residuals = self.X @ w - self.y
        grad_val = (self.X[:, gamma].T @ residuals) / self.n_samples
        
        g = np.zeros_like(w)
        g[gamma] = grad_val
        return g

