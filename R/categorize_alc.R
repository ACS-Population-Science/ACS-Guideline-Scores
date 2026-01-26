#' Clean and categorize alcohol consumption
#'
#' @description
#' This function cleans alcohol intake variable (in number of drinks per day)
#' used in the creation of the alcohol subcomponent score in the total
#' 2020 American Cancer Society Guideline Score
#'
#' @param ALC a numeric vector of drinks per day
#'
#' @returns a numeric vector of categorized drinks per day:
#' \itemize{
#'   \item `1` = No drinks
#'   \item `2` = 1 drink per day or less
#'   \item `3` = >1 to 2 drinks per day
#'   \item `4` = More than 2 drinks per day
#' }
#'
#' @examples
#' # Create sample vector
#' dpd <- c(
#'   floor(runif(n = 100, min = 0, max = 9)),
#'   rep(NA, 10)
#' )
#'
#' alc_cat <- categorize_alc(dpd)
#' table(alc_cat)
#'
#' @importFrom dplyr case_when
#'
#' @export
#' @md

categorize_alc <- function(ALC) {
  dplyr::case_when(
    ALC == 0 ~ 1, # none
    ALC > 0 & ALC <= 1 ~ 2, # 1 drink per day or less
    ALC > 1 & ALC <= 2 ~ 3, # >1 to 2 drinks per day
    ALC > 2 ~ 4, # more than 2 drinks per day
    TRUE ~ NA
  )
}
