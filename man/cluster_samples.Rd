% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cluster_samples.R
\name{cluster_samples}
\alias{cluster_samples}
\title{K-means clustering on samples based on latent factors}
\usage{
cluster_samples(object, k, factors = "all", ...)
}
\arguments{
\item{object}{a trained \code{\link{MOFA}} object.}

\item{k}{number of clusters (integer).}

\item{factors}{character vector with the factor name(s), or numeric vector with the index of the factor(s) to use. 
Default is 'all'}

\item{...}{extra arguments  passed to \code{\link{kmeans}}}
}
\value{
output from \code{\link{kmeans}} function
}
\description{
MOFA factors are continuous in nature but they can be used to predict discrete clusters of samples. \cr
The clustering can be performed in a single factor, which is equivalent to setting a manual threshold.
More interestingly, it can be done using multiple factors, where multiple sources of variation are aggregated. \cr
Importantly, this type of clustering is not weighted and does not take into account the different importance of the latent factors.
}
\details{
In some cases, due to model technicalities, samples can have missing values in the latent factor space. 
In such a case, these samples are currently ignored in the clustering procedure.
}
\examples{
# Using an existing trained model on simulated data
file <- system.file("extdata", "model.hdf5", package = "MOFA2")
model <- load_model(file)

# Cluster samples in the factor space using factors 1 to 3 and K=2 clusters 
clusters <- cluster_samples(model, k=2, factors=1:3)
}
