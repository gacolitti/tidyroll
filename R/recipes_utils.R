#' Add Steps to Recipe
#'
#' Add one or more steps to the end of a recipe object in sequence.
#'
#' @param recipe A \code{recipe}.
#' @param new_steps A series of step expressions. Use \code{expr} or \code{exprs} from \code{rlang}
#'   to defuse steps.
#'
#' @examples
#'
#' library(recipes)
#' library(rlang)
#'
#' pred_date <- as.Date("2015-01-15")
#' mtcars2 <- mtcars %>% mutate(hp_date = as.Date("2015-01-01"))
#' mtcars2$hp_date[1:2] <- as.Date("2015-02-01")
#' rec1 <- recipe(mtcars2, mpg ~ hp + hp_date)
#' new_steps <- exprs(
#'    step_mutate(hp = ifelse(hp_date < pred_date, hp, as.numeric(NA))),
#'    step_meanimpute(hp)
#' )
#' rec2 <- add_steps(rec1, new_steps)
#'
#' @importFrom purrr map_lgl
#' @importFrom rlang eval_tidy expr is_expression caller_env env_bind
#' @importFrom dplyr "%>%"
#'
#'@export
add_steps <- function(recipe, new_steps) {
  if (is.list(new_steps)) {
    for (i in seq_along(new_steps)) {
      env_bind(caller_env(), rec_new = recipe)
      rec_new <- eval_tidy(expr(rec_new %>% !!new_steps[[i]]), env = caller_env())
    }
    return(rec_new)
  } else {
    env_bind(caller_env(), rec_new = recipe)
    rec_new <- eval_tidy(expr(rec_new %>% !!new_steps), env = caller_env())
  }
}

#' Unnormalize variable
#'
#' Unormalizes variable using standard deviation and mean from a recipe object. See \code{?recipes}.
#'
#' @param x Numeric vector to normalize.
#' @param recipe Trained recipe object.
#' @param var Variable name in the recipe object.
#'
#' @importFrom recipes fully_trained
#' @importFrom dplyr pull
#'
#' @export
unnormalize <- function(x, recipe, var) {
  if (!fully_trained(recipe)) stop("`recipe` must be trained first with `prep`.")
  var_sd <- extract_step_item(recipe, "step_normalize", "sds") %>% pull(var)
  var_mean <- extract_step_item(recipe, "step_normalize", "means") %>% pull(var)

  (x * var_sd) + var_mean
}

#' Normalize variable
#'
#' Normalizes variable using standard deviation and mean from a recipe object. See \code{?recipes}.
#'
#' @param x Numeric vector to normalize.
#' @param recipe Trained recipe object.
#' @param var Variable name in the recipe object.
#'
#' @importFrom recipes fully_trained
#' @importFrom dplyr pull
#'
#' @export
normalize <- function(x, recipe, var) {
  if (!fully_trained(recipe)) stop("`recipe` must be trained first with `prep`.")
  var_sd <- extract_step_item(recipe, "step_normalize", "sds") %>% pull(var)
  var_mean <- extract_step_item(recipe, "step_normalize", "means") %>% pull(var)

  (x - var_mean) / var_sd
}

#' Extract step item
#'
#' Returns extracted step item from prepped recipe.
#'
#' @param recipe Trained recipe object.
#' @param step Step from trained recipe.
#' @param item Item from trained recipe.
#' @param enframe_item Should the step item be enframed?
#'
#' @importFrom recipes fully_trained
#' @importFrom purrr map_chr
#' @importFrom tidyr spread
#' @importFrom tibble enframe
#'
#' @export
extract_step_item <- function(recipe, step, item, enframe_item = TRUE) {
  if (!fully_trained(recipe)) stop("`recipe` must be trained first with `prep`.")

  d <- recipe$steps[[which(map_chr(recipe$steps, ~ class(.)[1]) == step)]][[item]]

  if (enframe_item) {
    enframe(d) %>% spread(key = 1, value = 2)
  } else {
    d
  }
}

