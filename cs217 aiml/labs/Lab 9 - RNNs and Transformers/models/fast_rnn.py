import torch
import torch.nn as nn

class FastRNNModel(nn.Module):
    def __init__(self, d_model=128, num_layers=1):
        super().__init__()
        self.d_model = d_model
        self.num_layers = num_layers

        # token embedding: digits 0..9
        self.E = nn.Embedding(10, d_model)

        # linear recurrence parameters
        self.W = nn.Parameter(torch.eye(d_model) * 0.01)
        self.U = nn.Parameter(torch.eye(d_model) * 0.01)
        self.b = nn.Parameter(torch.zeros(d_model))

        # output parameters
        self.V = nn.Parameter(torch.randn(d_model, 451) * 0.01)
        self.c = nn.Parameter(torch.zeros(451))

    def forward(self, x):
        """
        x: (B, T) integer tokens

        returns:
            out: (B, T, 451)
        """
        B, T = x.shape

        # (B, T, d_model)
        x_embed = self.E(x)

        h_prev = torch.zeros(B, self.d_model, device=x.device)
        outputs = []

        for t in range(T):
            x_t = x_embed[:, t, :]                     # (B, d_model)
            h_t = torch.tanh(h_prev @ self.W + x_t @ self.U + self.b)
            o_t = h_t @ self.V + self.c               # (B, 451)

            outputs.append(o_t)
            h_prev = h_t

        return torch.stack(outputs, dim=1)            # (B, T, 451)