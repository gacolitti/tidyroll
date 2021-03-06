% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/recipes_utils.R
\name{extract_step_item}
\alias{extract_step_item}
\title{Extract step item}
\usage{
extract_step_item(recipe, step, item, index = 1, enframe_item = TRUE)
}
\arguments{
\item{recipe}{Trained recipe object.}

\item{step}{Step from trained recipe.}

\item{item}{Item from trained recipe.}

\item{index}{If multiple steps of the same class, which step do you want to extract
the item from? For example, if \code{step_normalize} is called twice, you will
need to specify \code{index = 2} to extract the information from the second
\code{step_normalize}.}

\item{enframe_item}{Should the step item be enframed?}
}
\description{
Returns extracted step item from prepped recipe.
}
