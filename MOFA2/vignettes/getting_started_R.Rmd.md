---
title: "MOFA+: getting started in R"
author: "Ricard Argelaguet"
date: "`r Sys.Date()`"
---

```{r}
library(data.table)
library(purrr)
library(MOFA2)
```

# Description

MOFA is a (Bayesian) factor analysis model that provides **a general framework for the unsupervised integration of multi-omic data sets**. Briefly, MOFA aims at disentangling the sources of variation in a multi-omics data set, and detect the ones which are shared between assays from the ones that are driven by a single assay.

In our new model design (MOFA+) we generalise this strategy to also enable **the integration of multiple groups of data**, where groups are typically different cohorts, time points, experiments, etc. When using the multi-group functionality, the model will quantify the variance explained by each latent factor in each group. See for example the following figure:

<p align="center"> 
<img src="../../images/fig1_getting_started_vignette.png" style="width: 100%; height: 100%"/>​
</p>

(EXAMPLE) The input data consists of three views and three groups. The model has detected 4 latent factors. Factor 1 drives a lot of signal in view 2 and view 3, but no variance in view 1. However, this variation is only captured in group A and B, not in group C. Hence, whatever Factor 1 is (let's say cell cycle variation), MOFA indicates that all samples in group 3 do not manifest such variation.

In conclusion, MOFA+ provides a principled approach to decompose the modes of variation in complex and structured data sets.

# Implementation
The core of the model is implemented in Python (mofapy2 package), but the first steps of data processing and model training can be done either in R. After the model is trained, we only provide downstream analysis functionalities in R.  

To continue with the getting started tutorial, now you need to choose the [python path](XXX) or the [R path](XXX). 

<!--  (see [this template script](https://github.com/bioFAM/MOFA2/blob/master/template_run.py)) or in R (see [this template script](https://github.com/bioFAM/MOFA2/blob/master/template_run.R)). -->

# Input formats

To create a MOFA+ object you need to specify four dimensions: samples (cells), features, view(s) and group(s). 

MOFA objects can be created from a wide range of input formats, This depends on whether you follow the R path or the Python path:

## R

**List of matrices**:
This is the format inherited from MOFA v1. 

```{r }
# Set dimensionalities
N = 100
D1 = 250
D1 = 500

# view1 and view2 are matrices with dimensions (N,D1) and (N,D2) where
# N are the samples, D1 and D2 are the number of features in view 1 and 2, respectively
view1 = matrix(rnorm(N*D1),nrow=N, ncol=D1)
view2 = matrix(rnorm(N*D2),nrow=N, ncol=D2)

# groups is a character or factor vector that indicates the group ID for each sample
groups = c(rep("A",N/2), rep("B",N/2))

# create MOFA object with two views, no groups (MOFA v1)
create_mofa(list("view1" = view1), groups=groups)

# create MOFA object with one view, two groups
create_mofa(list("view1" = view1, "view2" = view2))

# create MOFA object with two views, two groups
MOFAobject <- create_mofa(list("view1" = view1, "view2" = view2), groups=groups)

print(MOFAobject)
```
 

**Long data.frame**
A long data.frame with columns ["sample","group","feature","view","value"].  
This is personally my favourite format. It summarises all omics/groups in a single data structure:

```{r }
# data.frame for view 1
dt1 <- view %>% melt() %>% 
  setnames("sample","feature","value") %>%
  .[,view:="view1"]

# concatenate
dt <- rbind(dt1,dt2)

MOFAobject <- create_mofa(dt)
print(MOFAobject)
```

**Seurat**
Seurat is a popular tool for the analysis of single-cell omics. 

```{r }
MOFAobject <- create_mofa(seurat,
  groups = pbmc@meta.data$data_batch, # Groups can be extracted from the metadata
  features = VariableFeatures(pbmc),  # select features from the seurat object
  slot = "data")                      # Slot to select from each assay

```

## Python

First, you need to import the mofa2py library 
```{python }
import mofa2py

# initialise the entry point
ent = mofa2py.run.entry_point()
```


```{python }

```

**Long data.frame format**  
A pandas data.frame with columns ["sample","group","feature","view","value"].  
This is personally my favourite format. It summarises all omics/groups in a single data structure:
```{python }
ent.set_data_df(data)
```

**Nested list of matrices**:  
A nested list of numpy arrays, where the first index refers to the view and the second index refers to the group. Samples are stored in the rows and features are stored in the columns. All views for a given group G must have the same samples in the rows. If there is any sample that is missing a particular view, the column needs to be filled with NAs.
```{python }

N = [50, 100] # first group has 50 samples, second group has 100 samples
D = [250, 500] # first view has 250 features, second view has 500 features

data = [ [norm.rvs(size=[N[i],D[j]]) for j in range(len(N))] for i in range(len(D)) ]

ent.set_data_matrix(data)
```

**AnnData (scanpy)**
```{r }
# groups_label (optional): a column name in adata.obs for grouping the samples
# use_raw (optional): use raw slot of AnnData as input values
set_data_from_anndata(anndata, groups_label=None, use_raw=False)
```


# Data processing

### Normalisation
Proper normalisation of the data is critical for the model to work. 
For count-based data such as scRNA-seq or scATAC-seq we recommend size factor normalisation + variance stabilisation. 

### Filtering
It is strongly recommended that you filter highly variable features (HVGs) per assay.
Importantly, when doing multi-group inference, you have to regress out the group effect before selecting HVGs, otherwise you will enrich for features that show differences in their mean between groups.

Also, it is recommended that data sets have similar dimensionalities. Bigger data modalities will tend to be overrepresented in the output. Sometimes this is just unavoidable, but it is good practice to filter features in order to have similar number of features per view (or as similar as possible).

### Batch effect corrections
If you have variation that you don't want MOFA to capture, you should regress it out before fitting the model. We provide the function `regress_covariates` to regress out covariates in the data.


# Model fitting
Once the data has been prepared, there are a few model and training options that needs to be provided:
- **likelihoods**: character vector with data likelihoods per view: 'gaussian' for continuous data, 'bernoulli' for binary data and 'poisson' for count data. By default, they are guessed internally.
- **number of factors**: numeric value indicating the (initial) number of factors. They can be trimmed down after fitting the model
- **convergence_mode**: character indicating the convergence criteria, either "slow" (not recommended), "medium" or "fast".
- GPU inference?

## Fast Stochastic variational inference
If the number of samples is very large (at the order of >1e4), you may want to try the stochastic inference scheme. If combined with GPUs, it makes inference significantly faster. However, it requires some additional hyperparameters that in some data sets may need to be optimised (vignette in preparation).

in R
```r
# batch_size: numeric value indicating the batch size (as a fraction of the full data set). 
# learning_rate: numeric value indicating the learning rate.
# forgetting_rate: numeric value indicating the forgetting rate.
stochastic_opts <- get_default_stochastic_options()
```

in Python
```python
ent.set_stochastic_options(
  batch_size=0.5,
  learning_rate=0.5, 
  forgetting_rate=0.25
)
```


# Downstream analysis
