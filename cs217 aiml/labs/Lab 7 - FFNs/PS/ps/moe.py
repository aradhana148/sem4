import numpy as np # type: ignore
from ffnn import FeedForwardNN


class MoE:

    def __init__(self, input_dim, hidden_dim, num_experts, expert_layers, learning_rate=0.01, router_reg=0.01):
        learning_rate = 0.25
        router_reg = 0.00001
        self.num_experts = num_experts
        self.learning_rate = learning_rate
        self.router_reg = router_reg

        # Router network
        self.router = FeedForwardNN(
            layer_sizes=[input_dim, hidden_dim, num_experts],
            hidden_activation='relu',
            output_activation='softmax',
            learning_rate=learning_rate
        )

        # Experts
        self.experts = [
            FeedForwardNN(
                layer_sizes=expert_layers,
                hidden_activation='relu',
                output_activation='linear',
                learning_rate=learning_rate
            )
            for _ in range(num_experts)
        ]
        self.gates = None
        self.expert_outputs = None


    


    def forward(self, X: np.ndarray):
        """
        Run forward passes on all the models

        populate self.gates (N, K) and self.expert_outputs (N, K, D)
        here N = number of rows in data
             K = number of experts
             D = number of columns in data


        return the final prediction of the model

        """


        #TODO 1
        self.gates = self.router.forward_propagation(X)
        expert_as_list = []
        for k in range(self.num_experts):
            out_for_kth = self.experts[k].forward_propagation(X)
            expert_as_list.append(out_for_kth)
        self.expert_outputs = np.stack(expert_as_list, axis=1)
        y_pred = np.sum(self.gates[:, :, np.newaxis]*self.expert_outputs, axis=1)
        return y_pred

    def backward(self, grad_output: np.ndarray):
        """
        For each model calculate the gradient of the loss with respect to the model outputs.
        Add regularization in the case of the router (router_grad -= self.router_reg * entropy_grad)

        Run backward propogation on each model.

        After that update the paramters of each model as well. (We will not have a seperate update parameters function like the ffnn)


        """


        # TODO 2

        for k in range(self.num_experts):
            grad = grad_output*self.gates[:, k:k+1]
            gw,gb = self.experts[k].backward_propagation(grad)
            self.experts[k].update_parameters(gw, gb)

        tempo = grad_output[:, np.newaxis, :]*self.expert_outputs
        router_grad = np.sum(tempo, axis=2)
        g = self.gates
        entropy_grad = -(np.log(g+1e-10)+1)
        router_grad = router_grad - self.router_reg*entropy_grad
        gw, gb = self.router.backward_propagation(router_grad)
        self.router.update_parameters(gw, gb)


    def loss_grad(self, y_pred: np.ndarray, y: np.ndarray):
        """
        Return how the loss changes with the output of the model. (Ignore the regularization term here).

        """

        # TODO 3
        return (y_pred-y) / y_pred.shape[0]


    def train(self, X: np.ndarray, y: np.ndarray, epochs=1000, print_freq=1000):

        for epoch in range(epochs):
            y_pred = self.forward(X)
            grad_output = self.loss_grad(y_pred, y)
            self.backward(grad_output)
            if epoch % print_freq == 0:
                loss = np.mean((y_pred-y)**2)
                print(f"Epoch {epoch} | Loss {loss:.6f}")