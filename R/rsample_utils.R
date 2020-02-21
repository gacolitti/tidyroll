#' Rolling Origin Forecast Resampling with Irregular Timeslices
#'
#' Wrapper around \code{rsample::rolling_origin()} used to facilitate resampling of irregular time
#' slices.
#'
#' @param data Data to use for training and prediction.
#' @param time_var A character. Name of date/time variable in \code{data}.
#' @param start A character. Minimum date/time for which predictions will be generated.
#'  If \code{NULL}, then \code{min(data[[time_var]]) + assess}
#' @param end A character. Maximum date/time for which predictions will be generated. If \code{NULL}
#'   then \code{end = max(data[[time_var]])}.
#' @param unit A character string specifying a time unit or a multiple of a unit to nest the data.
#' Valid base units are \code{second, minute, hour, day, week, month, and year}.
#' Arbitrary unique English abbreviations as in the \code{period()} constructor
#' are allowed. Rounding to multiple of units (except weeks) is supported.
#' @param assess The number of nested date/times used for each assessment resample.
#' @param skip A integer indicating how many (if any) additional resamples to skip to thin the
#' total amount of data points in the analysis resample.
#' @param extend A logical. If \code{TRUE}, when \code{assess > 1} then all observations will be
#' predicted \code{assess} number of times. For example, if \code{data} has 10 unique observations
#' after nesting by \code{time_var},
#' \code{assess = 2}, all observations will be predicted 2 times when \code{extend = TRUE}, whereas
#' when \code{extend = FALSE} observations 10 and 3 (the default \code{start}) will be predicted only once.
#' @param ... Other arguments passed to \code{rsample::rolling_origin()}.
#'
#' @importFrom rsample rolling_origin
#' @importFrom lubridate period
#' @importFrom lubridate round_date
#' @importFrom dplyr sym
#' @importFrom tidyr complete
#' @importFrom tidyr nest
#'
#' @details
#'
#' Observations missing \code{time_var} are preserved and predicted last.
#'
#' @export
rolling_origin_nested <- function(data,
                                  time_var,
                                  start = NULL,
                                  end = NULL,
                                  unit = "day",
                                  extend = FALSE,
                                  assess = 1,
                                  skip = 0,
                                  ...) {

  if(inherits(data[[time_var]], 'Date')) data[[time_var]] <- as.POSIXct(data[[time_var]])
  stopifnot(inherits(data[[time_var]], 'POSIXt'))

  # If start is NULL use minimum time_var plus assess
  if (is.null(start)) {
    start <- min(data[[time_var]], na.rm = TRUE)
    start <- as.POSIXct(start) + assess
  }

  # If end is NULL use max time_var
  if (is.null(end)) {
    end <- max(data[[time_var]], na.rm = TRUE)
  }

  start <- as.POSIXct(start)
  end <- as.POSIXct(end)

  if (start > max(data[[time_var]], na.rm = TRUE)) {
    stop("start > max(time_var)", call. = FALSE)
  } else if (start < min(data[[time_var]], na.rm = TRUE)) {
    stop("start < min(time_var)", call. = FALSE)
  }

  if (end < start) {
    stop("end must be greater than start")
  }

  if (extend) {
    start <- start - period(assess, units = unit)
    end <- end + period(assess, units = unit)
  }

  data <- data[data[[time_var]] <= end | is.na(data[[time_var]]), ]

  data <- complete(
    data = data, !!sym(time_var) := seq(
      start,
      end,
      by = unit
    )
  )

  data <- data[order(data[[time_var]]), ]

  data$.date <- round_date(data[[time_var]], unit = unit)
  data <- nest(.data = data, data = -c(.date))
  initial <- which(data$.date == round_date(start, unit = unit))[1]

  rolling_origin(data = data, initial = initial, assess = assess, skip = skip, ...)
}

#' Wrapper function for preparing recipes with nested resampling
#'
#' Makes it easier to prepare recipes using training data from nested resamples created with
#' \link{rolling_origin_nested}.
#'
#' @param split An \code{rsplit} object created with \link{rolling_origin_nested}.
#' @param recipe An untrained \code{recipe} object.
#' @param strings_as_factors A logical: should character columns be converted to factors? This
#'   affects the preprocessed training set (when retain = TRUE) as well as the results of
#'   bake.recipe. Unlike \code{prep()}, the default is \code{FALSE}.
#' @param ... Other arguments passed to \code{prep}.
#'
#' @importFrom recipes prep
#' @importFrom dplyr bind_rows
#' @importFrom rsample analysis
#'
#' @details
#'
#' Sets the underlying \code{prep()} argument \code{fresh} to TRUE.
#'
#' @export
prepper_nested <- function(split, recipe, strings_as_factors = FALSE, ...) {
  prep(recipe, bind_rows(analysis(split)$data), fresh = TRUE, strings_as_factors = strings_as_factors, ...)
}


#' Fit models using nested split and recipe
#'
#' This function makes it easy to fit a model using a nested split and a recipe object. A nested
#'   split is one created with \code{rolling_origin_nested}, where each split is nested by a
#'   time variable.
#'
#' @param split An \code{rsplit} object created with \link{rolling_origin_nested}. If \code{recipe}
#'   is trained with \code{prep(..., retain = TRUE)}, this argument is not needed and will not be
#'   used.
#' @param recipe A trained or untrained recipe object. If not trained, \code{split} must be
#'   included.
#' @param model_func A model function (ex: \code{lm} or \code{glm}). Must include arguments
#'   \code{formula} and \code{data}.
#' @param strings_as_factors A logical: should character columns be converted to factors? This
#'   affects the preprocessed training set (when retain = TRUE) as well as the results of
#'   bake.recipe. Unlike \code{prep()}, the default is \code{FALSE}.
#' @param ... Other arguments passed to \code{model_func}.
#'
#' @importFrom dplyr bind_rows
#' @importFrom rsample analysis
#' @importFrom recipes prep
#' @importFrom recipes juice
#' @importFrom recipes fully_trained
#' @importFrom Gmisc fastDoCall
#'
#' @details
#'
#' If \code{...} does not include \code{formula}, the formula will be extracted from \code{recipe}
#'   using \code{formula(recipe)}.
#'
#' @export
fit_rsample_nested <- function(split = NULL, recipe, model_func, strings_as_factors = FALSE, ...) {

  if (fully_trained(recipe)) {
    prepped_rec <- recipe
  } else {
    if (is.null(split)) stop("split cannot be missing because recipe is not trained")
    train <- bind_rows(analysis(split)$data)
    prepped_rec <- prep(recipe, train = train, fresh = TRUE, strings_as_factors = strings_as_factors)
  }
  args <- list(...)
  if (!"formula" %in% names(args)) args$formula <- formula(prepped_rec)
  args$data <- juice(prepped_rec)
  fastDoCall(model_func, args)
}

#' Predict assessment data from nested split using recipe and model fit
#'
#' This function facilitates extracting, baking, and predicting \code{assessment} data from a nested
#' split object created with \code{rolling_origin_nested}. Baking requires a \code{recipe} object
#' and predicting requires a fitted model object.
#'
#' @param split An \code{rsplit} object created with \link{rolling_origin_nested}.
#' @param recipe An untrained recipe object.
#' @param fit A fitted model object.
#' @id_vars A character vector of variables names to be returned along with the predictions. Default
#'   is to keep all variables.
#' @predict_options A named list of arguments passed to \code{predict}. For example, if the fitted
#'   model is of class \code{merMod} \code{list(allow.new.levels = TRUE)} may be appropriate.
#' @add_steps Add steps to end of \code{recipe}.
#' @param strings_as_factors A logical: should character columns be converted to factors? This
#'   affects the preprocessed training set (when retain = TRUE) as well as the results of
#'   bake.recipe. Unlike \code{prep()}, the default is \code{FALSE}.
#'
#' @importFrom rsample analysis
#' @importFrom rsample assessment
#' @importFrom dplyr bind_rows
#' @importFrom recipes bake
#' @importFrom recipes prep
#' @importFrom dplyr as_tibble
#' @importFrom dplyr tibble
#' @importFrom Gmisc fastDoCall
#'
#'@export
predict_rsample_nested <- function(split,
                                   recipe,
                                   fit,
                                   id_vars = "all",
                                   predict_options = NULL,
                                   add_steps = NULL,
                                   strings_as_factors = FALSE) {

  # Get prediction date using the maximum date from the analysis data
  .pred_date <- max(analysis(split_obj)$.date, na.rm = TRUE)

  baked_assessment <- tryCatch({

    # Impute sample data if sample date is greater than pred date
    rec <- recipe %>%
      step_mutate_at(
        contains("_per"),
        contains("sample"),-sample_date,
        fn = ~ ifelse(sample_date < .pred_date, ., as.numeric(NA))
      ) %>%
      step_meanimpute(contains("_per"), sample_weight, contains("sample_dbh")) %>%
      check_missing(all_predictors())

    bake(prep(rec, training = bind_rows(analysis(split)$data),
                       strings_as_factors = strings_as_factors),
                  new_data = bind_rows(assessment(split)$data))
  },
  error = function(cond) {
    return(tibble())
  })

  if (nrow(baked_assessment) == 0) return()

  if (is.null(predict_options)) {
    .pred <- predict(object = fit_obj, newdata = baked_assessment)
  } else {
    .pred <-
      fastDoCall(predict, c(
        list(object = fit_obj, newdata = baked_assessment),
        predict_options
      ))
  }


  if (is.null(id_vars)) {
    res <- tibble(.pred_date, .pred)
  } else if (id_vars[1] == "all") {
    res <-
      as_tibble(
        cbind(
          baked_assessment,
          .pred_date = .pred_date,
          .pred = .pred,
          stringsAsFactors = FALSE
        )
      )
  } else {
    res <-
      as_tibble(
        cbind(
          baked_assessment[, id_vars],
          .pred_date = .pred_date,
          .pred = .pred,
          stringsAsFactors = FALSE
        )
      )
  }
  return(res)
}