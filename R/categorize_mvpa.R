#' Clean and categorize physical activity
#'
#' @description
#' This function cleans moderate-vigorous physical activity (MVPA) variables
#' (in MET-hrs/week) used in the creation of the MVPA subcomponent score in the
#' total 2020 American Cancer Society Guideline Score
#'
#' @param MVPA a numeric vector of MVPA values
#'
#' @returns a numeric vector of categorized MVPA:
#' \itemize{
#'   \item `1` = None
#'   \item `2` = >0 - <7.5 MET-hrs/week
#'   \item `3` = 7.5 - <15.0 MET-hrs/week
#'   \item `4` = >=15.0 MET-hrs/week
#' }
#'
#' @examples
#' # Create sample vector
#' mvpa <- c(
#'   round(rnorm(n = 100, mean = 8, sd = 3), digits = 1),
#'   rep(NA, 10)
#' )
#'
#' mvpa_cat <- categorize_mvpa(mvpa)
#' table(mvpa_cat)
#'
#' @importFrom dplyr case_when
#'
#' @export
#' @md


categorize_mvpa <- function(MVPA) {

  dplyr::case_when(
    MVPA == 0 ~ 1, # none
    MVPA > 0 & MVPA < 7.5 ~ 2, # >0-<7.5 MET-hrs/week (less than PA guidelines)
    MVPA >= 7.5 & MVPA < 15.0 ~ 3, # 7.5-<15.0 MET-hrs/week (meeting PA guidelines)
    MVPA >= 15.0 ~ 4, # >=15.0 MET-hrs/week (exceeding PA guidelines)
    TRUE ~ NA
  )
}
