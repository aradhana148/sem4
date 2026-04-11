import numpy as np

class FeedForwardNN:

    def __init__(self, layer_sizes, hidden_activation='relu', output_activation='sigmoid', learning_rate=0.01):
        self.layer_sizes = layer_sizes 
        self.hidden_act = hidden_activation
        self.output_act = output_activation
        self.learning_rate = learning_rate

        self.L = len(layer_sizes) - 1 
        self.weights = []
        self.biases = []

        self.pre_activations = []
        self.activations = []

        self.initialize_parameters()


    def initialize_parameters(self):
        """
        Initialize all the parameters of the neural network.
        All the weights with appropriate shapes
        Do random initialization using standard normal distribution
        and all the biases.
        For weigths initialize them with a scale of  2 / sqrt(in) (To mantain variance)
        """

        # DO NOT REMOVE
        np.random.seed(42)

        #TODO 1
        for l in range(self.L):
            in_dim = self.layer_sizes[l]
            out_dim = self.layer_sizes[l+1]
            W = np.random.randn(in_dim, out_dim)*(2/np.sqrt(in_dim))
            b = np.zeros((1, out_dim))
            self.weights.append(W)
            self.biases.append(b)


    def relu(self, z: np.ndarray):
        """
        Implement reLu on z
        z: np.ndarray
        output: np.ndarray with relu applied to it (Same shape as z)
        """

        # TODO 2
        return np.where(z>=0,z,0)


    def relu_derivative(self, z: np.ndarray):
        """
        Implement the derivative of relu on z
        z: np.ndarray
        output: np.ndarray with relu's derivative (Same shape as z)
        """

        # TODO 3
        return np.where(z>0,1,0)


    def sigmoid(self, z: np.ndarray):
        """
        Implement sigmoid on z
        z: np.ndarray
        output: np.ndarray with sigmoid applied to it (Same shape as z)
        don't forget to clip
        """

        #TODO 4
        return (1/(1+np.exp(-np.clip(z,-100,100))))


    def sigmoid_derivative(self, z: np.ndarray):
        """
        Implement sigmoid derivative on z
        z: np.ndarray
        output: np.ndarray with sigmoid derivative applied to it (Same shape as z)
        don't forget to clip
        """

        #TODO 5
        s=self.sigmoid(z)
        return s*(1-s)


    def softmax(self, z: np.ndarray):
        """
        Implement softmax on Z: np.ndarray (N, d)
        Output: np.ndarray with softmax taken on each row (N, d)
        don't forget to make it numerically stable
        """

        # TOOD 6
        z = z - np.max(z, axis=1, keepdims=True)
        exp=np.exp(z)
        sum=np.sum(exp,axis=1,keepdims=True)
        return exp/sum

    def activate(self, z: np.ndarray, activation_type: str):
        """
        Handle the correct activation function for z.

        Return the value of applying said activation function to z

        """


        #TODO 7
        if(activation_type=="relu"):
            return self.relu(z)
        elif(activation_type=="sigmoid"):
            return self.sigmoid(z)
        elif(activation_type=="softmax"):
            return self.softmax(z)
        else:
            return z

    def forward_propagation(self, X: np.ndarray):
        """
        Implement Forward propogation.

        Fill in the activations and pre-activations arrays appropriately. 

        return the final output of the neural net (after the output layer activation)

        """
        # TODO 8
        self.activations = []
        self.pre_activations = []
        inp=X
        self.activations.append(inp)
        for l in range(self.L-1):
            prep=inp@self.weights[l]+self.biases[l]
            inp=self.activate(prep,activation_type=self.hidden_act)
            self.activations.append(inp)
            self.pre_activations.append(prep)
        prep=inp@self.weights[self.L-1]+self.biases[self.L-1]
        out=self.activate(prep,activation_type=self.output_act)
        self.activations.append(out)
        self.pre_activations.append(prep)
        return out

    def backward_propagation(self, grads: np.ndarray):
        """
        Implement backward propogation

        grads is the gradient of the loss with respect to the output of the final layer. (It is slightly different in semantics from delta so keep that in mind)

        propogate the grad_weights and grad_biases arrays appropriately

        return grad_weights, grad_biases

        """

        grad_weights = [np.zeros_like(w) for w in self.weights]
        grad_biases  = [np.zeros_like(b) for b in self.biases]

        u=grads
        if(self.output_act=="softmax"):
            diff=self.activations[-1]
            dot = np.sum(grads*diff, axis=1, keepdims=True)
            u = diff*(grads-dot)
        elif(self.output_act=="sigmoid"):
            u=self.sigmoid_derivative(self.pre_activations[-1])*u

        grad_weights[self.L-1]=self.activations[self.L-1].T@u
        grad_biases[self.L-1]=
        for l in range(self.L -1):
            grad_weights[l]=
            if(self.hidden_act=="sigmoid"):


    def update_parameters(self, grad_weights: list, grad_biases: list):
        """
        Update all the paramters according to grad_weights and grad_biases (with learning rate)

        """

        # TODO 10
        for l in range(self.L):
            self.weights[l] -= self.learning_rate*grad_weights[l]
            self.biases[l] -= self.learning_rate*grad_biases[l]

    def train(self, X: np.ndarray, y: np.ndarray, epochs=10000):
        """
        Train the neural network. For now no need to implement any batching etc. In each epoch run forward backward and update on the whole dataset.
        Assume that we will only do regression with MSE loss.
        """
        n = X.shape[0]
        for epoch in range(epochs):
            # TODO 11
            y_pred = self.forward_propagation(X)
            grads = (1/n) * (y_pred-y)
            grad_weights, grad_biases = self.backward_propagation(grads)
            self.update_parameters(grad_weights, grad_biases)
            if epoch % 1000 == 0:
                loss = np.mean((y_pred-y) ** 2)
                print(f"Epoch {epoch} Loss {loss}")