from torchvision import datasets, models, transforms
import torchvision
import torch
import torch.nn as nn
import torch.optim as optim
from torch.optim import lr_scheduler
import numpy as np

torch.manual_seed(3)
torch.cuda.manual_seed_all(3)
np.random.seed(3)

# Transformers for test function
#my_transforms = transforms.Compose([
#        transforms.Resize(256),
#        transforms.CenterCrop(224),
#        transforms.ToTensor(),
#        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
#    ])

# Transforms for 20200405 water model

my_transforms = transforms.Compose([
        transforms.RandomResizedCrop(224),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize([0.4818, 0.4898, 0.4858, 0.5001], [0.2259, 0.2370, 0.2261, 0.2043])
    ])

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(device)

# test model
#model = torch.load("/app/resources/models/test_model_save.pt", map_location=device)
model = torch.load("app/resources/models/20200405-water-model.pt", map_location=device)

model.eval()

with rasterio.open('test_img.tif') as f:
    dataset = f.read().astype(np.uint8)
    dataset = reshape_as_image(dataset)

    image = Image.fromarray(dataset, 'RGBA')

tensor = self.my_transforms(image).unsqueeze(0)
tensor = tensor.to(self.device)

with torch.no_grad():
    outputs = model(tensor)
    
print(outputs)
