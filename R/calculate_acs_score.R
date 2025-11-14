#' Calculate ACS Guideline Score
#'
#' @description
#' This function creates the total American Cancer Society Guideline Score by
#' creating and combining the four subcomponents (BMI, MVPA, DIET, ALC)
#'
#' @param df A `data.frame` with the required elements calculated by the
#' categorize functions and `calculate_acs_diet_score()`
#'
#' @details
#' <Add more details here about what is being done, columns that are required to be in the data, etc.>
#'
#' @returns A `data.frame` with the subcomponent scores and the total score
#' as new columns:
#' \itemize{
#'   \item `ACS_BMI` = The BMI subcomponent score
#'   \item `ACS_MVPA` = The physical activity subcomponent score
#'   \item `ACS_DIET` = The diet subcomponent score
#'   \item `ACS_ALC` = The alcohol consumption subcomponent score
#'   \item `ACS_TOTAL` = The sum of the components
#' }
#'
#' @examples
#' \dontrun{
#' score_df <- calculate_acs_score(df = my_score_data)
#' }
#'
#' @importFrom dplyr mutate case_when
#'
#' @export
#' @md

calculate_acs_score <- function(df) {

  df <- df |>
    dplyr::mutate(
      ACS_BMI = dplyr::case_when(
        BMICAT_PRE == 3 | BMICAT_BASE == 3 ~ 0, #obesity at any time point
        BMICAT_PRE == 1 & BMICAT_BASE == 1 ~ 2, #healthy weight at both time points
        BMICAT_PRE %in% c(1, 2) | BMICAT_BASE %in% c(1, 2) ~ 1, #other combination
        TRUE ~ as.numeric(NA)
      ),
      ACS_MVPA = dplyr::case_when(
        MVPACAT == 1 | MVPACAT == 2 ~ 0, #<7.5 MET-hrs/wk (does not meet PA guidelines)
        MVPACAT == 3 ~ 1, #7.5-<15.0 MET-hrs/wk (meets PA guidelines)
        MVPACAT == 4 ~ 2, #15.0+ MET-hrs/wk (exceeds PA guidelines)
        TRUE ~ as.numeric(NA)
      ),
      ACS_DIET = dplyr::case_when(
        DIETCAT == 1 ~ 0, #tertile 1 (lowest diet scores)
        DIETCAT == 2 ~ 1, #tertile 2 (mid diet scores)
        DIETCAT == 3 ~ 2, #tertile 3 (highest diet scores)
        TRUE ~ as.numeric(NA)
      ),
      ACS_ALC = dplyr::case_when(
        # Females (SEX = 0)
        SEX == 0 & ALCCAT == 0 ~ 2,    # no alcohol
        SEX == 0 & ALCCAT == 1 ~ 1,    # >0 to <=1 drinks/day
        SEX == 0 & ALCCAT > 1 ~ 0,     # >1 drinks/day
        # Males (SEX = 1)
        SEX == 1 & ALCCAT == 0 ~ 2,    # no alcohol
        (SEX == 1 & ALCCAT == 1) | (SEX == 1 & ALCCAT == 2) ~ 1,  # >0 to <=2 drinks/day
        SEX == 1 & ALCCAT > 2 ~ 0,     # >2 drinks/day
        TRUE ~ as.numeric(NA)
      ),

      ACS_TOTAL = ACS_BMI + ACS_MVPA + ACS_DIET + ACS_ALC #score range: 0-8
    )

  return(df)
}
