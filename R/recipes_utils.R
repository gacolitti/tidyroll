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
#' \dontrun{
#'  .pred_date <- as.Date("2015-01-15")
#'  mtcars2 <- mtcars %>% mutate(hp_date = as.Date("2015-01-01"))
#'  mtcars2$hp_date[1:2] <- as.Date("2015-02-01")
#'  rec1 <- recipe(mtcars2, mpg ~ hp + hp_date)
#'  new_steps <- exprs(
#'    step_mutate(hp = ifelse(hp_date < .pred_date, hp, as.numeric(NA))),
#'    step_meanimpute(hp)
#'   )
#'  rec2 <- add_steps_to_recipe(rec1, new_steps)
#' }
#'
#'@importFrom rlang eval_tidy expr
#'@importFrom dplyr "%>%"
#'
#'@export
add_steps <- function(recipe, new_steps) {
  rec_new <- recipe
  for (i in seq_along(new_steps)) {
    rec_new <- eval_tidy(expr(rec_new %>% !!new_steps[[i]]))
  }
  return(rec_new)
}
