import numpy as np
from typing import Callable, Optional, Tuple, List, Any, Union

class func:
    def __init__(self):
        pass
    def __call__(self, x: np.ndarray) -> np.ndarray: # type: ignore
        return self.eval(x)
    def eval(self, x: np.ndarray) -> np.ndarray:# type: ignore
        pass
    def grad(self, x: np.ndarray) -> np.ndarray: # type: ignore
        pass
    def hessian(self, x: np.ndarray) -> np.ndarray: # type: ignore
        pass 


class LSLR (func):
    def __init__(self, X: np.ndarray, y: np.ndarray) -> None:
        self.X = X
        self.y = y
        self.n_samples, self.n_features = X.shape
        super().__init__()

    def eval(self, x: np.ndarray) -> np.ndarray: #type: ignore
        w = x
        residuals = self.X @ w - self.y
        return 0.5 * np.mean(residuals ** 2)
    
    def grad(self, x: np.ndarray) -> np.ndarray: # type: ignore
        w = x
        residuals = self.X @ w - self.y
        return (self.X.T @ residuals) / self.n_samples
    
    def hessian(self, x: np.ndarray) -> np.ndarray:  # type: ignore
        return (self.X.T @ self.X) / self.n_samples


class rosenbrock(func):
    def __init__(self, a: float = 1.0, b: float = 100.0) -> None:
        self.a = a
        self.b = b
        super().__init__()

    def eval(self, x: np.ndarray) -> np.ndarray: # type: ignore
        return np.array([(self.a - x[0])**2 + self.b*((x[1]-(x[0]**2))**2)])
    
    def grad(self, x: np.ndarray) -> np.ndarray: # type: ignore
        return np.array([2*x[0]-2*self.a+4*self.b*(x[0]**3)-4*self.b*x[1]*x[0], 2*self.b*x[1]-2*self.b*x[0]*x[0]])

    def hessian(self, x: np.ndarray) -> np.ndarray: # type: ignore
        return np.array([np.array([2+12*self.b*(x[0]**2), -4*self.b*x[0]]), np.array([-4*self.b*x[0], 2*self.b])])

class rot_anisotropic(func):
    def __init__(self, U: np.ndarray, V: np.ndarray, S: np.ndarray, b: np.ndarray) -> None:
        self.U = U
        self.V = V
        self.S = S
        self.b = b
        super().__init__()

    def eval(self, x: np.ndarray) -> np.ndarray: # type: ignore
        Q = self.U @ self.S @ self.V.T
        return x.T @ Q @ x - self.b.T @ x

    def grad(self, x: np.ndarray) -> np.ndarray: # type: ignore
        Q = self.U @ self.S @ self.V.T
        return (Q + Q.T) @ x - self.b

    def hessian(self, x: np.ndarray) -> np.ndarray: # type: ignore
        Q = self.U @ self.S @ self.V.T
        return Q + Q.T

if __name__ == "__main__":
    pass
