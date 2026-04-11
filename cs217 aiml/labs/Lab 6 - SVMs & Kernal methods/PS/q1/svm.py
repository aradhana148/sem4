import numpy as np


class SMO_SVM:
    """
    Support Vector Machine trained using Sequential Minimal Optimization (SMO).

    Complete the TODO sections.
    """

    def __init__(self, C=1.0, gamma=0.5, tol=1e-3, max_passes=5):
        self.C = C
        self.gamma = gamma
        self.tol = tol
        self.max_passes = max_passes

        # model parameters
        self.alpha = None

        # training data
        self.X = None
        self.y = None

        # kernel matrix
        self.K = None

        # error cache
        self.errors = None

    # =========================================================
    # RBF Kernel
    # =========================================================
    def kernel(self, X, Z):
        """
        TODO:
        Compute the RBF kernel matrix

            K(x,z) = exp(-gamma ||x - z||^2)

        Hint:
            Use vectorized distance computation.
        """
        sub=np.sum((X[None,:,:]-Z[:,None,:])**2,axis=2)
        sub=-self.gamma*sub
        return np.exp(sub)

    # =========================================================
    # Decision function
    # =========================================================
    def decision_function(self, i):
        """
        TODO:
        Compute f(x_i) = sum_j alpha_j y_j K(x_j, x_i)
        """
        return np.sum(self.alpha*self.y*(self.K[:,i]))

    # =========================================================
    # Select second multiplier (Platt heuristic)
    # =========================================================
    def select_j(self, i, Ei):
        """
        TODO:
        Choose j ≠ i that maximizes |Ei - Ej|.

        Steps:
        1. Consider non-bound multipliers (0 < alpha < C).
        2. Choose index maximizing |Ei - Ej|.
        3. If none found, choose random j ≠ i.
        """
        E=self.errors
        diff_E=np.abs(E-Ei)
        diff_E=np.where(self.alpha<self.C,diff_E,-np.inf)
        diff_E=np.where(self.alpha>0,diff_E,-np.inf)
        diff_E[i]=-np.inf
        j=np.argmax(diff_E)
        if(diff_E[j]==-np.inf):
            candidates = np.arange(len(self.alpha))
            candidates = candidates[candidates != i]
            j = np.random.choice(candidates)
        return j
   
    

    # =========================================================
    # Training using SMO
    # =========================================================
    def fit(self, X, y):
        self.X = X
        self.y = y.astype(float)

        n = X.shape[0]

        # TODO: initialize multipliers
        self.alpha = np.zeros((n,))

        # TODO: compute kernel matrix
        self.K = self.kernel(X,X)

        # TODO: initialize error cache
        # hint: initial f(x)=0 ⇒ E_i = -y_i
        self.errors = -self.y

        passes = 0

        while passes < self.max_passes:
            num_changed = 0

            for i in range(n):

                # TODO: read error Ei
                Ei = self.errors[i]

                # =================================================
                # TODO: Check KKT violation
                # =================================================
                violates =((self.y[i]*Ei<-self.tol and self.alpha[i]<self.C) or (self.y[i]*Ei>self.tol and self.alpha[i]>0))

                if not violates:
                    continue

                # TODO: select j
                j = self.select_j(i,Ei)

                # TODO: compute Ej
                Ej = self.errors[j]

                ai_old = self.alpha[i]
                aj_old = self.alpha[j]

                # =============================================
                # TODO: compute bounds L and H
                # =============================================
                s=0
                if(self.y[i]!=self.y[j]):
                    L,H=max(0,aj_old-ai_old), min(self.C,self.C+aj_old-ai_old)
                    s=-1
                else:
                    L,H=max(0,aj_old+ai_old-self.C), min(self.C,aj_old+ai_old)
                    s=1
                if L == H:
                    continue

                # =============================================
                # TODO: compute eta (curvature)
                # =============================================
                eta =(self.K[i,i]+self.K[j,j]-2*self.K[i,j])
                if eta <= 0:
                    continue

                # =============================================
                # TODO: update alpha_j and clip to [L,H]
                # =============================================
                self.alpha[j]=np.clip((aj_old+self.y[j]*(Ei-Ej)/eta),L,H)
                # TODO: check if change is significant
                changed = abs(self.alpha[j] - aj_old) >= 1e-5
                if not changed:
                    continue

                # =============================================
                # TODO: update alpha_i
                # =============================================
                self.alpha[i]=ai_old+s*(aj_old-self.alpha[j])
                # =============================================
                # TODO: update error cache efficiently
                # =============================================
                self.errors+=self.y[i]*(self.alpha[i]-ai_old)*self.K[:,i]+self.y[j]*(self.alpha[j]-aj_old)*self.K[:,j]
                num_changed += 1

            if num_changed == 0:
                passes += 1
            else:
                passes = 0

        return self

    # =========================================================
    # Prediction
    # =========================================================
    def project(self, X):
        """
        TODO:
        Compute decision values for new inputs:

            f(x) = sum_i alpha_i y_i K(x_i, x)
        """
        return np.sum((self.kernel(self.X,X)*((self.alpha*self.y)[None,:])),axis=1)
        

    def predict(self, X):
        """
        TODO:
        Compute predicted labels for new inputs:
        """
        return(np.sign(self.project(X)))
