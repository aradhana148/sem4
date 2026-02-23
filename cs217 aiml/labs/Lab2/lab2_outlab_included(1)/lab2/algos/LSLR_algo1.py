import numpy as np
from .optim import LSLROptimiser


class LSLRAlgo1(LSLROptimiser):
    def __init__(self, X: np.ndarray, y: np.ndarray) -> None:
        super().__init__(X, y)
        self.n = self.X.shape[0]
        XTX = X.T @ X / self.n
        eigenvalues = np.linalg.eigvalsh(XTX)
        self.rng = np.random.default_rng(0)
        if len(eigenvalues) > 0:
            L = float(np.max(eigenvalues))
            if L > 1e-10:
                self.eta = 1.0 / L

    def lr(self) -> float:
        return float(self.eta)

    def step(self, params: np.ndarray) -> np.ndarray:
        i = int(self.rng.integers(0, self.n))
        g = self.stoch_grad(params, i)
        return params - self.lr() * g

    def eval_lslr(self, w: np.ndarray) -> float:
        residuals = self.X @ w - self.y
        return 0.5 * np.mean(residuals ** 2)

    def stoch_grad(self, w: np.ndarray, gamma: int) -> np.ndarray:
        xi = self.X[gamma]
        ri = float(xi @ w - self.y[gamma])
        return xi * ri