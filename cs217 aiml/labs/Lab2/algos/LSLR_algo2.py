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
        
        ## TODO Use this for any pre-computations you need
        # Coordinate-wise Lipschitz constants L_i = (1/n) ||X_{:,i}||^2
        n, d = X.shape
        self.L_coords = np.sum(X**2, axis=0) / n
        
        # Ensure no division by zero
        self.L_coords = np.maximum(self.L_coords, 1e-10)

    def lr(self) -> float:
        ## TODO learning rate schedule
        # RCD usually uses 1/L_i for the chosen coordinate.
        # But this method returns a scalar. 
        # If the step method handles coordinate-wise LR, this can just return 1.
        return 1.0
    def step(self, params: np.ndarray) -> np.ndarray:
        ## TODO Implement the step method
        # Randomized Coordinate Descent
        d = self.n_features
        gamma = np.random.randint(0, d)
        
        # Gradient with respect to w_gamma: (1/n) X_{:,gamma}^T (Xw - y)
        w = params.copy()
        
        # Standard RCD update: w_gamma = w_gamma - (1/L_gamma) * grad_gamma
        # Efficient implementation would maintain residuals, but here we do simple way first.
        
        # But stoch_grad(w, gamma) assumes it returns a sparse vector G with only gamma component.
        # Let's use stoch_grad helper.
        grad_sparse = self.stoch_grad(w, gamma)
        grad_gamma = grad_sparse[gamma]
        
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
        """
        Compute stochastic gradient G(w, γ) = e_γ * (∇f(w))_γ
        Returns a sparse vector with only the γ-th component non-zero.
        """
        ## TODO Implement stochastic gradient computation
        # (∇f(w))_γ = (1/n) X_{:,gamma}^T (Xw - y)
        residuals = self.X @ w - self.y
        grad_val = (self.X[:, gamma].T @ residuals) / self.n_samples
        
        g = np.zeros_like(w)
        g[gamma] = grad_val
        return g

