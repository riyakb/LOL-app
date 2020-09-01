#conda activate pytorch_p37
#jupyter notebook

import pandas as pd
import numpy as np

import torch
from torch.utils import data
from torch.utils.data import Dataset, DataLoader
from torch.autograd import Variable

import torch.optim as optim
import torch.nn as nn
import torch.nn.functional as F

from torchvision import models

import random
import math 
min_val_loss=10

#reference: https://github.com/danielgrzenda/CF-Netflix/blob/master/combined-collab-netflix.ipynb, 
#https://github.com/groverpr/Machine-Learning/blob/master/notebooks/02_Collaborative_Filtering.ipynb

def proc_col(col, train_col=None):
    """Encodes a pandas column with continous ids. 
    """
    if train_col is not None:
        uniq = train_col.unique()
    else:
        uniq = col.unique()
    name2idx = {o:i for i,o in enumerate(uniq)}
    return name2idx, np.array([name2idx.get(x, -1) for x in col]), len(uniq)

def encode_data(df, train=None):
    """ Encodes rating data with continous user and movie ids. 
    If train is provided, encodes df with the same encoding as train.
    """
    df = df.copy()
    for col_name in ["user_id", "meme_id"]:
        train_col = None
        if train is not None:
            train_col = train[col_name]
        _,col,_ = proc_col(df[col_name], train_col)
        df[col_name] = col
        df = df[df[col_name] >= 0]
    return df

def rearrange(actual_y,tensr_y,predicted_tensor_y):
    rearranged_y=[]
    for i in range(len(tensr_y)):
        element=actual_y[i]
        idx=tensr_y.index(element)
        rearranged_y=np.append(rearranged_y, predicted_tensor_y[idx])
    return rearranged_y

class my_Dataset(data.Dataset):
    def __init__(self, df, transform=None):
        self.length = len(df)
        self.y = torch.FloatTensor(df['rating'].values)
        self.x = torch.LongTensor(df.drop('rating',axis=1).values)
        self.transform = transform
        
    def __len__(self):
        return self.length
    
    def __getitem__(self,index):
        sample = {'x':self.x[index], 'y':self.y[index]}
        return sample

class CollabFNet(nn.Module):
    def __init__(self, num_users, num_items, emb_size=100, n_hidden=500):
        super().__init__()
        self.embs = nn.ModuleList([nn.Embedding(num_users, emb_size), nn.Embedding(num_items, emb_size)])
        self.lin1 = nn.Linear(emb_size*2, n_hidden)
        self.lin2 = nn.Linear(n_hidden, 1)
        self.drop1 = nn.Dropout(0.1)
        self.drop2 = nn.Dropout(0.2)
        self.bn1 = nn.BatchNorm1d(emb_size*2)
        self.bn2 = nn.BatchNorm1d(n_hidden)
        
    def forward(self, u, v):
        U = self.embs[0](u)
        V = self.embs[1](v)
        x = self.bn1(torch.cat([U, V], dim=1))
        x = F.relu(x)
        x = self.drop1(x)
        x = self.lin1(x)
        x = F.relu(self.bn2(x))
        x = self.drop2(x)
        x = self.lin2(x)
        return x

def get_optimizer(model, lr = 0.01, wd = 0.0):
    parameters = filter(lambda p: p.requires_grad, model.parameters())
    optim = torch.optim.Adam(parameters, lr=lr, weight_decay=wd)
    return optim
        
def train(model, epochs, train_dl, device, actual_y, lrs=None, verbose=False):
    idx=0
    for i in range(epochs): 
        model.train()
        total = 0
        sum_loss = 0
        for sample in train_dl:
            optim = get_optimizer(model, lr = lrs[idx], wd = 0.00001)
            x = sample['x'].to(device)
            y = sample['y'].unsqueeze(1).to(device)
            batch = y.shape[0]
            y_hat = model(x[:,0], x[:,1])
            
            loss = F.mse_loss(y_hat, y)
            optim.zero_grad()
            loss.backward()
            optim.step()
            total += batch
            sum_loss += batch*(loss.item())
            if verbose: print(sum_loss/total)
#         print("train loss ", sum_loss/total)
        
    return val_loss(model, train_dl, device, actual_y)

def val_loss(model, valid_dl, device, actual_y):
    model.eval()
    total = 0
    sum_loss = 0
    correct = 0
    for sample in valid_dl:
        x = sample['x'].to(device)
        y = sample['y'].unsqueeze(1).to(device)
        batch = y.shape[0]
        y_hat = model(x[:,0], x[:,1])
        loss = F.mse_loss(y_hat, y)
        sum_loss += batch*(loss.item())
        total += batch
        
        global min_val_loss
        global final_scores
                
        input_list=y.cpu().detach().numpy()
        tensor_y=np.concatenate(input_list).ravel()
        input_list1=y_hat.cpu().detach().numpy()
        predicted_y=np.concatenate(input_list1).ravel()
        scores=rearrange(actual_y.tolist(),tensor_y.tolist(), predicted_y.tolist())
    val_loss=sum_loss/total
    min_val_loss=min(min_val_loss,val_loss)
    if min_val_loss==val_loss:
        final_scores=scores
#     print(final_scores, val_loss)
    return final_scores


def sltr(num_epochs, train_size, eta_max=0.01, cut_frac=0.1, ratio=32):
    training_iterations = num_epochs * train_size
    cut = math.floor(training_iterations * cut_frac)
    lr = [None for _ in range(training_iterations)]
    for t in range(training_iterations):
        if t<cut: 
            p=t/cut
        else: 
            p=1-((t-cut)/(cut*(1/cut_frac-1)))
        lr[t] = eta_max * (1+p*(ratio-1))/ratio
    return lr

def learning_rate_range(model, train_dl, device, lr_high=0.1, epochs=2):
    save_model(model, str(PATH/"model_tmp.pth"))
    losses = []
    iterations = len(train_dl) * epochs
    delta = (lr_high / iterations)
    lrs = [i*delta for i in range(iterations)]
    model.train()
    ind = 0
    for i in range(epochs):
        for sample in train_dl:
            optim = get_optimizer(model, lr=lrs[ind])
            y = sample['y'].unsqueeze(1).to(device)
            x = sample['x'].to(device)
            batch = y.shape[0]
            y_hat = model(x[:,0],x[:,1])
            loss = F.mse_loss(y_hat, y)
            optim.zero_grad()
            loss.backward()
            optim.step()
            losses.append(loss.item())
            ind+=1
    load_model(model, str(PATH/"model_tmp.pth"))
    return lrs, losses

def save_model(model, location):
    torch.save(model.state_dict(), location)

def load_model(model, location):
    model.load_state_dict(torch.load(location))

def get_collab_score(df):
    train_df = encode_data(df)
    train_df=train_df[['user_id', 'meme_id', 'rating']]
    train_df = train_df.astype('int32',copy=False)
    train_ds = my_Dataset(train_df)

    batch_size = 100000
    train_dl = DataLoader(train_ds, batch_size=batch_size, shuffle=True, num_workers=4)
    

    num_users = len(train_df.user_id.unique())
    num_items = len(train_df.meme_id.unique())

    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    model = CollabFNet(num_users, num_items, emb_size=100)
    if torch.cuda.device_count()>1:
        print("Let's use", torch.cuda.device_count(), "GPUs!")
        model = nn.DataParallel(model)
    model.to(device)

    valid_dl=train_dl
    actual_y=train_df['rating'].values.astype(np.float32)
    lrs = sltr(10, len(train_dl), eta_max=0.005)
    final_scores= train(model, epochs=10, train_dl=train_dl, device=device, actual_y=actual_y, lrs=lrs)
    return final_scores

