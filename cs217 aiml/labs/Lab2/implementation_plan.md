# Lab 2 Implementation Plan

## Goal Description
Complete the implementation of optimization algorithms and analysis tools for Lab 2. The tasks involve:
1.  **Q1**: Random search for hyperparameters in Ridge Regression.
2.  **Q2**: Implementing function evaluations and standard Gradient Descent (GD) for Rosenbrock and Rotated Anisotropic functions.
3.  **Q3**: Implementing Least Squares Linear Regression (LSLR) solvers and algorithms: pseudo-inverse, GD, Randomized Coordinate Descent (RCD), and SVRG-Coordinate Descent. Also generating datasets to demonstrate algorithm performance differences.

## User Review Required
> [!IMPORTANT]
> **Algorithm Identification**:
> Based on the code structure (specifically `stoch_grad` docstrings requiring sparse updates and `optim.py` implementing coordinate gradients), I interpret the algorithms as:
> *   **Algo 1**: Full Batch Gradient Descent (GD).
> *   **Algo 2**: Randomized Coordinate Descent (RCD).
> *   **Algo 3**: Variance Reduced Coordinate Descent (SVRG-CD).
> 
> This differs from the mapping in `B.py` (which mentions Kaczmarz/SVRG), but aligns with the strict requirements of the provided function signatures and docstrings.

## Proposed Changes

### Q1: Ridge Regression
#### [MODIFY] [q1_solve.py](file:///home/suhas/cs_courses/cs240/lab2/q1/q1_solve.py)
*   Implement `random_search_lambdas` to sample lambdas in log-space and evaluate using CV.

### Q2: Optimization Landscape
#### [MODIFY] [func.py](file:///home/suhas/cs_courses/cs240/lab2/functions/func.py)
*   Implement `rot_anisotropic`:
    *   `eval`: $f(x) = x^T Q x - b^T x$ where $Q = U S V^T$ (Wait, $Q$ must be symmetric for pure quadratic form? The readme says $Q = V S V^T$ where V is rotation? Let me follow the `q2.py` docstring `Q = V S V^T` if symmetric, or $Q = U S V^T$ if general? I will check `q2.py` again. `q2.py`: `f(x) = x^T Q x - b^T x where Q = V S V^T`. But `rot_anisotropic` init takes U, V, S. I will implement based on `q2.py` description: $Q = V S V^T$.
    *   `grad`: $\nabla f(x) = (Q + Q^T)x - b$.
    *   `hessian`: $\nabla^2 f(x) = Q + Q^T$.

#### [MODIFY] [grad_descent.py](file:///home/suhas/cs_courses/cs240/lab2/algos/grad_descent.py)
*   Implement `step`: $x_{t+1} = x_t - \eta \nabla f(x_t)$.

### Q3: LSLR Algorithms
#### [MODIFY] [A.py](file:///home/suhas/cs_courses/cs240/lab2/q3/A/A.py)
*   Implement `solve_func`: Use `np.linalg.pinv` to solve $Xw = y$.
*   Implement `exact_solve_function`: Wrapper returning solution and time.

#### [MODIFY] [C.py](file:///home/suhas/cs_courses/cs240/lab2/q3/C/C.py)
*   Implement `compute_dataset_properties`: Calculate L, mu, kappa, stable rank.
*   Implement `generate_gd_victory_dataset`: Low dimension, well-conditioned? Or appropriate conditions.
*   Implement `generate_sgd_victory_dataset`: High dimension/large N, maybe redundant info or specific spectral properties where stochastic methods converge faster early on?

#### [MODIFY] [LSLR_algo1.py](file:///home/suhas/cs_courses/cs240/lab2/algos/LSLR_algo1.py) (Algo 1: GD)
*   Implement `step`: Full batch GD update.
*   Implement `eval_lslr`: MSE.
*   Implement `full_grad`: Full gradient.
*   Implement `stoch_grad`: (Optional/Unused for GD) Coordinate gradient.

#### [MODIFY] [LSLR_algo2.py](file:///home/suhas/cs_courses/cs240/lab2/algos/LSLR_algo2.py) (Algo 2: RCD)
*   Implement `step`: Pick random coordinate $\gamma$, update $w_\gamma$.
*   Implement `stoch_grad`: Compute coordinate gradient.

#### [MODIFY] [LSLR_algo3.py](file:///home/suhas/cs_courses/cs240/lab2/algos/LSLR_algo3.py) (Algo 3: SVRG-CD)
*   Implement `step`: SVRG-CD logic.
    *   Keep snapshots $w_{tilde}$.
    *   Compute full gradient at snapshot.
    *   Update steps using variance reduced coordinate gradient.

## Verification Plan

### Automated Tests
*   Run `q1/q1_main.py` (if exists) or create a test script for Q1.
*   Run `q2/q2.py` and check output JSONs/plots.
*   Run `q3/A/A.py` to verify Exact and GD.
*   Run `q3/B/B.py` to verify Algo 1, 2, 3 comparison.
*   Run `q3/C/C.py` to generate datasets.

### Manual Verification
*   Inspect plots generated in `outputs/` folders.
*   Check convergence messages in terminal output.
