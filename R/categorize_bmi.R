#' Clean and categorize BMI at two time-points
#'
#' @description
#' This function cleans body mass index variables from two time points
#' used in the creation of the BMI subcomponent score in the total
#' American Cancer Society Guideline Score
#'
#' @param BMI a numeric vector of BMI values
#'
#' @returns a numeric vector of categorized BMI:
#' \itemize{
#'   \item `1` = Normal weight (18.5-25 kg/m^2)
#'   \item `2` = Overweight (25-<30 kg/m^2)
#'   \item `3` = Obese (>=30 kg/m^2)
#'   \item `9` = Missing
#' }
#'
#' @examples
#' # Create sample vector
#' bmi <- round(rnorm(n = 100, mean = 27, sd = 10), digits = 1)
#'
#' bmi_cat <- categorize_bmi(bmi)
#' table(bmi_cat)
#'
#' @importFrom dplyr case_when
#'
#' @export
#' @md

categorize_bmi <- function(BMI) {

  #categorize BMI
  dplyr::case_when(
    is.na(BMI) | BMI < 18.5 ~ 9, #underweight are excluded
    BMI >= 18.5 & BMI < 25.0 ~ 1, #normal weight
    BMI >= 25.0 & BMI < 30.0 ~ 2, #overweight
    BMI >= 30.0 ~ 3, #obese
    TRUE ~ 9
  )

}
