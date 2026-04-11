import torch
import torch.nn as nn
import math

class RNNCell(nn.Module):
    def __init__(self, dim):
        super().__init__()
        # TODO: Create learnable weights W, U, V, b, c
        # self.W=nn.Parameter(torch.randn((dim,dim))* 0.01)
        # self.U=nn.Parameter(torch.randn((dim,dim))* 0.01)
        self.W=nn.Parameter(torch.eye(dim)*0.01)
        self.U=nn.Parameter(torch.eye(dim)*0.01)
        self.b=nn.Parameter(torch.zeros(dim))
        self.V=nn.Parameter(torch.randn((dim,451))* 0.01)
        self.c=nn.Parameter(torch.zeros(451))


    def forward(self, x, hidden_prev):
        """
        Processes a single time step.
        x: (B, input_dim)
        hidden_prev: (B, hidden_dim)
        out: (B, hidden_dim)
        """
        h_t=(torch.tanh(hidden_prev@self.W+x@self.U+self.b))
        
        o_t=h_t@self.V+self.c
        return h_t,o_t

class RNNModel(nn.Module):
    def __init__(self, d_model=128, num_layers=1):
        super().__init__()
        self.d_model = d_model
        self.num_layers = num_layers

        # TODO: Create Token embedding 
        # assuming max tokens will be 10 (i.e. digits 0 to 9)
        self.E=nn.Embedding(10,d_model)

        # TODO: Stack Manual RNN Cells
        self.a=RNNCell(d_model)

        # TODO: Output projection (Map to Prefix-Sum vocab)
        # Assuming output vocab size is 451 (max possible sum + padding)    
        # self.O=nn.Linear(d_model,451)

    def forward(self, x):
        """
        x: (B, T) -> Integer tokens

        Return:
        
        out: (B, T, 451)
        """
        B,T=x.shape
        x_inp=self.E(x)
        h_prev=torch.zeros((B,self.d_model))
        output=[]
        for i in range(T):
            h_i,o_i=self.a.forward(x_inp[:,i,:],h_prev)
            h_prev=h_i
            output.append(o_i)
        return torch.stack(output,dim=1)

