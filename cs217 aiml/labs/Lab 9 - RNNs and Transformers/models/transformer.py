import torch
import torch.nn as nn
import math

def scaled_dot_product_attention(Q, K, V, mask=None):
    """
    TODO:
    1. Compute attention scores
    2. Scale by sqrt(d_k)
    3. Apply mask (if provided)
    4. Apply softmax
    5. Multiply with V
    """
    _,N,d=Q.shape
    a=Q@torch.transpose_copy(K,dim0=1,dim1=2)
    a=a/(d**0.5)
    if mask is not None:
        a=mask+a
    a=torch.softmax(a,dim=-1)
    return a@V,a

class SinusoidalPE(nn.Module):
    def __init__(self, d_model, max_len=5000):
        super().__init__()
        # TODO: Create positional embeddings that you can then use in `forward()`
        x_axis=torch.arange(max_len)[:,None]
        self.pe=torch.zeros(max_len,d_model)
        self.pe+=x_axis
        y_axis=(10000**((torch.arange(d_model)//2)*2/d_model))[None,:]
        self.pe/=y_axis
        even_end=int((d_model+1)/2)
        even=torch.arange(even_end)
        odd_end=int(d_model/2)
        odd=torch.arange(odd_end)*2+1
        self.pe[:,even]=torch.sin(self.pe[:,even])
        self.pe[:,odd]=torch.cos(self.pe[:,odd])

    def forward(self, x):
        # TODO: Return positional encoding matching sequence length
        b,n,d=x.shape
        pe_for_x=(self.pe[:n,:])[None,:,:]
        return (pe_for_x+x)

class MultiHeadAttention(nn.Module):
    def __init__(self, d_model, num_heads):
        super().__init__()
        assert d_model % num_heads == 0

        self.num_heads = num_heads
        self.d_k = d_model // num_heads

        # TODO: Define linear layers for Q, K, V

        # TODO: Output projection

        self.Q=[]
        self.K=[]
        self.V=[]
        for _ in range(num_heads):
            self.Q.append(nn.Linear(d_model,self.d_k))
            self.K.append(nn.Linear(d_model,self.d_k))
            self.V.append(nn.Linear(d_model,self.d_k))
        self.Wo=nn.Linear(self.d_k*num_heads,d_model)

    def forward(self, x):
        """
        TODO:
        1. Project x → Q, K, V
        2. Split into heads
        3. Apply attention
        4. Concatenate heads
        5. Final linear layer
        """
        z=[]
        n=x.size(1)
        attns=[]
        for i in range(self.num_heads):
            mask=torch.triu(torch.full((n,n),float('-inf')),diagonal=1)
            val,attn=scaled_dot_product_attention((self.Q[i])(x),(self.K[i])(x),(self.V[i])(x),mask)
            attns.append(attn)
            z.append(val)
        z=torch.cat(z,dim=-1)
        attn=torch.cat(attns,dim=-1)
        return self.Wo(z),attn

class TransformerEncoderBlock(nn.Module):
    def __init__(self, d_model, num_heads, d_ff):
        super().__init__()

        # TODO: Define Multi-head attention module
        self.mha=MultiHeadAttention(d_model,num_heads)
        # TODO: Define LayerNorms
        self.ln1=nn.LayerNorm(d_model)
        self.ln2=nn.LayerNorm(d_model)
        # TODO: Define Feedforward network
        self.ffn=nn.Sequential(
            nn.Linear(d_model,d_ff),
            nn.Tanh(),
            nn.Linear(d_ff,d_model)
        )


    def forward(self, x):
        """
        TODO:
        1. Attention + residual + norm
        2. FFN + residual + norm
        """
        # nor=self.ln1(x)
        # after_att,att=self.mha(nor)
        # after_add=after_att+nor
        # nor2=self.ln2(after_add)
        # after_fnn=self.ffn(nor2)+nor2
        after_att,att=self.mha(x)
        add_norm=self.ln1(x+after_att)
        after_ffn=self.ffn(add_norm)
        add_norm2=self.ln2(add_norm+after_ffn)
        return add_norm2,att
        

    

class TransformerModel(nn.Module):
    def __init__(self, d_model=64, num_heads=2, num_layers=3, max_len=25, pe_type='sin'):
        super().__init__()

        # TODO: Create Token embedding
        # assuming max tokens will be 10 (i.e. digits 0 to 9)
        self.emb=nn.Embedding(10,d_model)

        # TODO: Positional encoding selection
        self.pe=SinusoidalPE(d_model,max_len)

        # TODO: Stack encoder blocks
        self.enc=nn.ModuleList(
            [TransformerEncoderBlock(d_model,num_heads,4*d_model) for _ in range(num_layers)]
        )

        # TODO: Output projection (Map to Prefix-Sum vocab)        
        # Assuming output vocab size is 451 (max possible sum + padding)
        self.out=nn.Linear(d_model,451)


    def forward(self, x, return_attn=False):
        """
        TODO:
        1. Embed tokens
        2. Add positional encoding
        3. Pass through encoder layers
        4. Project to vocab

        NOTE: If `return_attn` is true, you must return the `output` and the `attention scores`, if not return only the `output`.
        """
        emb=self.emb(x)
        outt=self.pe(emb)
        attns=[]
        for i in self.enc:
            outt,attn=i(outt)
            attns.append(attn)
        outt=self.out(outt)
        if(return_attn):
            return outt,attns
        else:
            return outt

