% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calculate_variance_explained.R
\name{plot_variance_explained_per_feature}
\alias{plot_variance_explained_per_feature}
\title{Plot variance explained by the model for a set of features

Returns a tile plot with a group on the X axis and a feature along the Y axis}
\usage{
plot_variance_explained_per_feature(
  object,
  view,
  features = 10,
  split_by_factor = FALSE,
  group_features_by = NULL,
  groups = "all",
  factors = "all",
  min_r2 = 0,
  max_r2 = NULL,
  legend = TRUE,
  return_data = FALSE,
  ...
)
}
\arguments{
\item{object}{a \code{\link{MOFA}} object.}

\item{view}{a view name or index.}

\item{features}{a vector with indices or names for features from the respective view, 
or number of top features to be fetched by their loadings across specified factors. 
"all" to plot all features.}

\item{split_by_factor}{logical indicating whether to split R2 per factor or plot R2 jointly}

\item{group_features_by}{column name of features metadata to group features by}

\item{groups}{a vector with indices or names for sample groups (default is all)}

\item{factors}{a vector with indices or names for factors (default is all)}

\item{min_r2}{minimum variance explained for the color scheme (default is 0).}

\item{max_r2}{maximum variance explained for the color scheme.}

\item{legend}{logical indicating whether to add a legend to the plot  (default is TRUE).}

\item{return_data}{logical indicating whether to return the data frame to plot instead of plotting}

\item{...}{extra arguments to be passed to \code{\link{calculate_variance_explained}}}
}
\value{
ggplot object
}
\description{
Plot variance explained by the model for a set of features

Returns a tile plot with a group on the X axis and a feature along the Y axis
}
\examples{
# Using an existing trained model
file <- system.file("extdata", "model.hdf5", package = "MOFA2")
model <- load_model(file)
plot_variance_explained_per_feature(model, view = 1)
}
