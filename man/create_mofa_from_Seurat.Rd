% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_mofa.R
\name{create_mofa_from_Seurat}
\alias{create_mofa_from_Seurat}
\title{create a MOFA object from a Seurat object}
\usage{
create_mofa_from_Seurat(
  seurat,
  groups = NULL,
  assays = NULL,
  slot = "data",
  features = NULL,
  save_metadata = FALSE
)
}
\arguments{
\item{seurat}{Seurat object}

\item{groups}{a string specifying column name of the samples metadata to use it as a group variable. 
Alternatively, a character vector with group assignment for every sample.
Default is \code{NULL} (no group structure).}

\item{assays}{assays to use, default is \code{NULL}, it fetched all assays available}

\item{slot}{assay slot to be used such as scale.data or data (default).}

\item{features}{a list with vectors, which are used to subset features, with names corresponding to assays; a vector can be provided when only one assay is used}

\item{save_metadata}{logical indicating whether to incorporate the metadata from the Seurat object into the MOFA object}
}
\value{
Returns an untrained \code{\link{MOFA}} object
}
\description{
Method to create a \code{\link{MOFA}} object from a Seurat object
}
