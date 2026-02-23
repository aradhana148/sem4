import numpy as np
from typing import Callable, Optional, Tuple, List
from functions.func import func
from .optim import LSLROptimiser


class LSLRAlgo6(LSLROptimiser):
    """
    Stochastic Variance Reduced Gradient (SVRG) for LSLR.
    
    SVRG is an epoch-based stochastic optimization method that reduces the variance 
    of stochastic gradients by periodically computing a full gradient snapshot.
    
    The SVRG gradient estimator is defined as:
    G(w; w̃, i) = ∇f_i(w) - ∇f_i(w̃) + ∇f(w̃)
    
    where w̃ is a snapshot point that is fixed within an epoch.
    """
    
    def __init__(self, X: np.ndarray, y: np.ndarray, inner_iterations: int = None) -> None:
        super().__init__(X, y)
        
        # Number of inner loop iterations N per epoch
        # If not specified, default to 2*n (twice the number of samples)
        if inner_iterations is None:
            self.N = 2 * self.n_samples
        else:
            self.N = inner_iterations
        
        # Learning rate η_t
        # For LSLR, we can use η = 1/L where L is the Lipschitz constant
        n, d = X.shape
        XTX = X.T @ X / n
        eigenvalues = np.linalg.eigvalsh(XTX)
        if len(eigenvalues) > 0:
            L = float(np.max(eigenvalues))
            if L > 1e-10:
                self.eta = 1.0 / (10 * L)  # Conservative learning rate
            else:
                self.eta = 0.01
        else:
            self.eta = 0.01

    def lr(self) -> float:
        """Learning rate schedule"""
        return self.eta

    def step(self, params: np.ndarray) -> np.ndarray:
        """
        One epoch of SVRG algorithm:
        1. Set snapshot w̃ = w^(s) and compute full gradient ∇f(w̃)
        2. Initialize w_in^0 = w̃
        3. For t = 0, ..., N-1:
           - Sample i_t ~ Uniform({1,...,n})
           - Compute G(w_in^t; w̃, i_t) = ∇f_{i_t}(w_in^t) - ∇f_{i_t}(w̃) + ∇f(w̃)
           - Update w_in^{t+1} = w_in^t - η_t * G(w_in^t; w̃, i_t)
        4. Return w^(s+1) = w_in^N
        """
        # Step 1: Set snapshot w̃ and compute full gradient
        w_snapshot = params.copy()
        full_gradient_snapshot = self.full_grad(w_snapshot)
        
        # Step 2: Initialize w_in^0 = w̃
        w_inner = w_snapshot.copy()
        
        # Step 3: Inner loop for t = 0, ..., N-1
        for t in range(self.N):
            # Sample i_t uniformly from {0, 1, ..., n-1}
            i_t = np.random.randint(0, self.n_samples)
            
            # Compute SVRG gradient estimator G(w_in^t; w̃, i_t)
            G = self.svrg_gradient(w_inner, w_snapshot, full_gradient_snapshot, i_t)
            
            # Update w_in^{t+1} = w_in^t - η_t * G
            w_inner = w_inner - self.lr() * G
        
        # Step 4: Set w^(s+1) = w_in^N
        self.epochs_done += 1
        return w_inner

    def svrg_gradient(self, w: np.ndarray, w_snapshot: np.ndarray, 
                      full_grad_snapshot: np.ndarray, i: int) -> np.ndarray:
        """
        Compute SVRG gradient estimator:
        G(w; w̃, i) = ∇f_i(w) - ∇f_i(w̃) + ∇f(w̃)
        
        Args:
            w: Current parameter vector w_in^t
            w_snapshot: Snapshot parameter vector w̃
            full_grad_snapshot: Full gradient at snapshot ∇f(w̃)
            i: Sampled data index i_t
        
        Returns:
            SVRG gradient estimator
        """
        # Compute ∇f_i(w) - gradient at current w for sample i
        grad_i_w = self.sample_grad(w, i)
        
        # Compute ∇f_i(w̃) - gradient at snapshot for sample i
        grad_i_snapshot = self.sample_grad(w_snapshot, i)
        
        # G = ∇f_i(w) - ∇f_i(w̃) + ∇f(w̃)
        G = grad_i_w - grad_i_snapshot + full_grad_snapshot
        
        return G

    def sample_grad(self, w: np.ndarray, i: int) -> np.ndarray:
        """
        Compute gradient of single sample loss:
        ∇f_i(w) = X_i^T (X_i w - y_i)
        
        For SVRG, we define individual loss as: f_i(w) = (1/2)(X_i w - y_i)^2
        So: ∇f_i(w) = X_i^T (X_i w - y_i)
        
        The full gradient is then: ∇f(w) = (1/n) Σ_i ∇f_i(w)
        
        Args:
            w: Parameter vector
            i: Sample index
        
        Returns:
            Gradient for sample i (NOT divided by n)
        """
        X_i = self.X[i, :]  # i-th row of X
        y_i = self.y[i]
        
        residual = np.dot(X_i, w) - y_i
        grad = X_i * residual  # Do NOT divide by n here
        
        return grad

    def eval_lslr(self, w: np.ndarray) -> float:
        """Evaluate LSLR objective: (1/2n)||Xw - y||^2"""
        residuals = self.X @ w - self.y
        return 0.5 * np.mean(residuals ** 2)

    def full_grad(self, w: np.ndarray) -> np.ndarray:
        """Compute full gradient: ∇f(w) = (1/n) X^T (Xw - y)"""
        residuals = self.X @ w - self.y
        return (self.X.T @ residuals) / self.n_samples

