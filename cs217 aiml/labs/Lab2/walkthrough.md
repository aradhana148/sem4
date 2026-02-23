# Lab 2 Completion Walkthrough

I have successfully completed all tasks for Lab 2. Here is a summary of the changes and verification results.

## Implemented Components

### 1. Q1: Ridge Regression
*   **File**: [q1_solve.py](file:///home/suhas/cs_courses/cs240/lab2/q1/q1_solve.py)
*   **Task**: Implemented `random_search_lambdas` to sample hyperparameters uniformly in log-space.
*   **Result**: Random search successfully found optimal lambda comparable to grid search.

### 2. Q2: Optimization Landscape
*   **Files**:
    *   [func.py](file:///home/suhas/cs_courses/cs240/lab2/functions/func.py): Implemented `rot_anisotropic` class (eval, grad, hessian).
    *   [grad_descent.py](file:///home/suhas/cs_courses/cs240/lab2/algos/grad_descent.py): Implemented standard Gradient Descent `step`.
*   **Result**: Verified on Rosenbrock and Rotated Anisotropic functions. Fixed JSON serialization issues in `q2.py`.

### 3. Q3: LSLR Algorithms
*   **Task A**: Exact Solver
    *   [A.py](file:///home/suhas/cs_courses/cs240/lab2/q3/A/A.py): Implemented `solve_func` (using `pinv`) and `exact_solve_function`.
*   **Task C**: Dataset Generation
    *   [C.py](file:///home/suhas/cs_courses/cs240/lab2/q3/C/C.py): Implemented `compute_dataset_properties` and generation functions for GD/SGD victory scenarios.
*   **Task B**: Algorithm Comparison
    *   [LSLR_algo1.py](file:///home/suhas/cs_courses/cs240/lab2/algos/LSLR_algo1.py): Implemented **Full Batch Gradient Descent (GD)** using optimal learning rate $1/L$.
    *   [LSLR_algo2.py](file:///home/suhas/cs_courses/cs240/lab2/algos/LSLR_algo2.py): Implemented **Randomized Coordinate Descent (RCD)** using coordinate-wise steps.
    *   [LSLR_algo3.py](file:///home/suhas/cs_courses/cs240/lab2/algos/LSLR_algo3.py): Implemented **Greedy Coordinate Descent (GCD)** (Gauss-Southwell) with efficient gradient updates using precomputed $X^TX$.
    *   [B.py](file:///home/suhas/cs_courses/cs240/lab2/q3/B/B.py): Updated to correctly reference the algorithms (GD, RCD, GCD).

## Verification Results

### Q3 Comparison (Dataset D)
All algorithms converged successfully.

| Algorithm | Converged | Epochs | Time (s) | Final MSE |
| :--- | :--- | :--- | :--- | :--- |
| **GD (Algo1)** | True | 10 | 0.14 | 9.10e-02 |
| **RCD (Algo2)** | True | 173 | 0.38 | 1.09e-01 |
| **GCD (Algo3)** | True | 41 | 0.25 | 1.13e-01 |

*   **Fastest**: GD (0.14s) - likely due to efficient vectorization for this problem size.
*   **Most Efficient Epochs**: GD (10 epochs).
*   **Exact Solve Time**: 0.09s (Comparable to GD).

## Next Steps
You can explore the `outputs/` directories in q2 and q3 to view the generated plots and JSON metrics.
