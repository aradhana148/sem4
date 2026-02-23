import numpy as np
from typing import Callable, Optional, Tuple, List
from functions.func import func
from .optim import LSLROptimiser


class LSLRAlgo5(LSLROptimiser):
    """
    Mini-Batch Coordinate Descent for LSLR.
    
    At iteration t, sample a subset of feature indices B_t = {γ_1, γ_2, ..., γ_b} ⊂ {1,...,d}
    of size b. The update rule is:
    
    w^(t+1) = w^(t) - η_t * (1/b) Σ_{γ ∈ B_t} G_uni(w^(t), γ)
    
    where the same unbiased estimator G_uni from uniform sampling is used.
    """
    
    def __init__(self, X: np.ndarray, y: np.ndarray, batch_size: int = None) -> None:
        super().__init__(X, y)
        
        # Batch size b (number of coordinates to sample per iteration)
        # If not specified, default to sqrt(d)
        if batch_size is None:
            self.batch_size = max(1, int(np.sqrt(self.n_features)))
        else:
            self.batch_size = min(batch_size, self.n_features)
        
        # Coordinate-wise Lipschitz constants L_i = (1/n) ||X_{:,i}||^2
        n, d = X.shape
        self.L_coords = np.sum(X**2, axis=0) / n
        
        # Ensure no division by zero
        self.L_coords = np.maximum(self.L_coords, 1e-10)
        
        # Use average of coordinate Lipschitz constants as learning rate
        self.eta = 1.0 / np.mean(self.L_coords)

    def lr(self) -> float:
        """Learning rate schedule"""
        return self.eta

    def step(self, params: np.ndarray) -> np.ndarray:
        """
        One iteration of Mini-Batch Coordinate Descent:
        1. Sample a subset B_t of coordinates of size b
        2. Compute average gradient estimator over sampled coordinates
        3. Update: w^(t+1) = w^(t) - η_t * (1/b) Σ_{γ ∈ B_t} G_uni(w^(t), γ)
        """
        # Step 1: Sample b coordinates uniformly without replacement
        B_t = np.random.choice(self.n_features, size=self.batch_size, replace=False)
        
        # Step 2: Compute average gradient over batch
        # Initialize gradient accumulator
        avg_gradient = np.zeros(self.n_features)
        
        for gamma in B_t:
            # G_uni(w, γ) is the unbiased coordinate gradient estimator
            # G_uni(w, γ) = e_γ * (∇f(w))_γ (sparse vector with only γ-th component)
            g_gamma = self.stoch_grad(params, gamma)
            avg_gradient += g_gamma
        
        # Average over batch
        avg_gradient /= self.batch_size
        
        # Step 3: Update parameters
        w_new = params - self.lr() * avg_gradient
        
        self.epochs_done += 1
        return w_new

    def stoch_grad(self, w: np.ndarray, gamma: int) -> np.ndarray:
        """
        Compute unbiased gradient estimator G_uni(w, γ) = e_γ * (∇f(w))_γ
        Returns a sparse vector with only the γ-th component non-zero.
        
        For LSLR: (∇f(w))_γ = (1/n) X_{:,γ}^T (Xw - y)
        """
        residuals = self.X @ w - self.y
        grad_val = (self.X[:, gamma].T @ residuals) / self.n_samples
        
        g = np.zeros_like(w)
        g[gamma] = grad_val
        return g

    def eval_lslr(self, w: np.ndarray) -> float:
        """Evaluate LSLR objective: (1/2n)||Xw - y||^2"""
        residuals = self.X @ w - self.y
        return 0.5 * np.mean(residuals ** 2)

    def full_grad(self, w: np.ndarray) -> np.ndarray:
        """Compute full gradient: ∇f(w) = (1/n) X^T (Xw - y)"""
        residuals = self.X @ w - self.y
        return (self.X.T @ residuals) / self.n_samples

