#' Cancer Prevention Dietary Assessment Function
#'
#' Evaluates dietary patterns based on the American Cancer Society diet
#' recommendations (2020). Implements sex-stratified quartile ranking
#' methodology with composite scoring across six dietary domains.
#'
#' @param INTAKE_DATA Dataframe containing participant dietary intake records
#' @param PARTICIPANT_ID Column name for unique participant identifier
#' @param SEX Column name indicating sex (1=male, 2=female)
#' @param VEG_DS Daily servings of vegetables excluding white potatoes (numeric).
#'   Should include: tomatoes (including V8 juice, tomato sauce), tofu/soybeans,
#'   string beans, broccoli, cabbage/coleslaw, cauliflower, brussels sprouts,
#'   carrots (raw and cooked), corn, peas/lima beans, mixed vegetables/stir-fry/
#'   vegetable soup, beans/lentils, yams/sweet potatoes, winter squash, eggplant/
#'   zucchini/summer squash, spinach (cooked and raw), kale/mustard/chard greens,
#'   lettuce (iceberg and romaine), celery, peppers, onions, mushrooms
#' @param VEG_VARIETY Count of distinct vegetable items consumed (integer).
#'   Combine items from the same vegetable family: tomatoes/V8 juice/tomato sauce,
#'   raw carrots/cooked carrots, cooked spinach/raw spinach, onions as garnish/
#'   onions as vegetable.
#' @param FRUIT_DS Daily servings of whole fruits (excluding juice).
#'   Should include: raisins/grapes, prunes, bananas, cantaloupe, avocado, apples/
#'   pears, applesauce, oranges, grapefruit, strawberries, blueberries, peaches/
#'   apricots/plums
#' @param FRUIT_VARIETY Count of distinct fruit items consumed (integer).
#'   Combine items from the same fruit family: raisins/grapes, apples/pears/
#'   applesauce, peaches/apricots/plums.
#' @param WGRAIN_DS Daily servings of whole grain (numeric).
#'   Should include: whole grain cereal, cooked oatmeal/oat bran, dark bread,
#'   brown rice, oat bran added to food, other bran added to food, wheat germ,
#'   popcorn, plus 1/2 of "other grains" category
#' @param RPMEAT_DS Daily servings of red/processed meat (numeric).
#'   Should include: bacon, hot dogs (beef/pork/chicken/turkey), salami/bologna/
#'   other processed meat sandwiches, processed meats (kielbasa/sausage), hamburger
#'   (regular and lean), beef/pork/lamb as sandwich or main dish, liver (beef/calf/
#'   pork/chicken/turkey)
#' @param HPFRG_PCT Percentage of calories from highly-processed foods and refined
#'   grains (numeric 0-100). Highly-processed foods include: non-dairy creamer,
#'   ice cream, frozen yogurt, flavored yogurt, margarine, breaded fish, French
#'   fries, chips, crackers, pizza, diet sodas, candy, cookies, brownies, doughnuts,
#'   jams/jellies/syrups, cakes, pies, pastries, pretzels, cream soups, ketchup,
#'   mayonnaise, salad dressing, cream cheese, peanut butter (processed). Refined
#'   grains include: refined grain cereal, white bread, bagels/English muffins/rolls,
#'   muffins/biscuits, white rice, pancakes/waffles, pasta, tortillas
#'   Calculate as (kcal from HPF/RG / total kcal) * 100.
#' @param SSB_DS Daily servings of sugar-sweetened beverages including non-100%
#'   fruit juice (numeric). Should include: cola with sugar (Coke/Pepsi), other
#'   carbonated beverages with sugar (Mt Dew, 7-Up), punch/lemonade/non-carbonated
#'   fruit drinks, sugar-sweetened iced tea
#'
#' @return Dataframe with participant IDs, sex, overall score, and six component
#'   sub-scores:
#' \itemize{
#'   \item `TOTAL_DIETSC` - Total diet score; range 0-12
#'   \item `SUBSC_VEGTOT` - Total vegetables (amount + variety): 0-1.5
#'   \item `SUBSC_FRUITTOT` - Total fruits (amount + variety): 0-1.5
#'   \item `SUBSC_WGRAIN` - Whole grains: 0-3
#'   \item `SUBSC_RPMEAT` - Red/processed meat: 0-3 (reverse scored)
#'   \item `SUBSC_HPFRG` - Highly-processed foods and refined grains (HPFRG): 0-1.5 (reverse scored)
#'   \item `SUBSC_SSB` - Sugar-sweetened beverages (SSBs): 0-1.5 (reverse scored)
#' }
#'
#' @details
#' Scoring methodology uses sex-specific quartile distributions for most components.
#' Higher scores indicate better adherence to the 2020 ACS Guidelines for Diet for Cancer Prevention.
#' Total score ranges from 0-12 points across six evaluated domains.
#'
#' Component point allocations:
#' - Total vegetables (amount + variety): 0-1.5
#' - Total fruits (amount + variety): 0-1.5
#' - Whole grains: 0-3
#' - Red/processed meat: 0-3 (reverse scored)
#' - Highly-processed foods and refined grains (HPFRG): 0-1.5 (reverse scored)
#' - Sugar-sweetened beverages (SSBs): 0-1.5 (reverse scored)
#'
#' Scoring details by component:
#'
#' **Vegetables & Fruits:** Sex-specific quartiles assign 0, 0.25, 0.5, or 0.75
#' points for both amount and variety, then sum to create total scores (0-1.5 each).
#'
#' **Whole grains:** Sex-specific quartiles assign 0, 1, 2, or 3 points, with
#' higher intake receiving higher scores.
#'
#' **Red/processed meat:** Sex-specific quartiles assign 3, 2, 1, or 0 points
#' (reverse scored), with lower intake receiving higher scores.
#'
#' **Sugar-sweetened beverages:** Uses absolute thresholds (not sex-stratified):
#' - 0 servings/day = 1.5 points (optimal)
#' - More than 0 to <3×/week (>0 to <0.428/day) = 1.0 point
#' - ≥3×/week to <1/day (0.428 to <1/day) = 0.5 points
#' - ≥1 serving/day = 0 points
#'
#' **Highly-processed foods/refined grains:** Sex-specific quartiles based on
#' percentage of total calories assign 1.5, 1.0, 0.5, or 0 points (reverse scored),
#' with lower percentages receiving higher scores.
#'
#' Important notes on food categorization:
#' - When combining related items for variety counts, bracket items together
#'   (e.g., raw and cooked versions of the same vegetable count as one variety)
#' - Do NOT double-count foods: processed meats and sugar-sweetened beverages
#'   should not also be included in the highly-processed foods calculation
#'
#' @note Quartile-based scoring produces population-specific results that may not
#' be directly comparable across different study cohorts.
#'
#' @examples
#' \dontrun{
#' RESULT <- calculate_acs_diet_score(
#'   INTAKE_DATA = MY_DATA,
#'   PARTICIPANT_ID = ID,
#'   SEX = GENDER,
#'   VEG_DS = VEGETABLES,
#'   VEG_VARIETY = VEGETABLE_COUNT,
#'   FRUIT_DS = FRUITS,
#'   FRUIT_VARIETY = FRUIT_COUNT,
#'   WGRAIN_DS = WHOLEGRAINS,
#'   RPMEAT_DS = RED_PROC_MEAT,
#'   HPFRG_PCT = RATIO_HPF_REFGRAINS,
#'   SSB_DS = SUGAR_BEVS
#' )
#' }
#'
#' @import dplyr
#' @importFrom rlang enquo
#'
#' @export
#' @md

calculate_acs_diet_score <- function(
    INTAKE_DATA,
    PARTICIPANT_ID,
    SEX,
    VEG_DS,
    VEG_VARIETY,
    FRUIT_DS,
    FRUIT_VARIETY,
    WGRAIN_DS,
    RPMEAT_DS,
    HPFRG_PCT,
    SSB_DS) {

  ID_VAR <- rlang::enquo(PARTICIPANT_ID)
  SEX_VAR <- rlang::enquo(SEX)
  VEG_AMT <- rlang::enquo(VEG_DS)
  VEG_VAR <- rlang::enquo(VEG_VARIETY)
  FRT_AMT <- rlang::enquo(FRUIT_DS)
  FRT_VAR <- rlang::enquo(FRUIT_VARIETY)
  WG_SERV <- rlang::enquo(WGRAIN_DS)
  MEAT_RP <- rlang::enquo(RPMEAT_DS)
  HPFRG_RATIO <- rlang::enquo(HPFRG_PCT)
  SSB_SERV <- rlang::enquo(SSB_DS)


  # DEFINE QUARTILE-BASED SCORING FUNCTIONS

  # QUARTILES FOR FRUITS AND VEGETABLES (SERVINGS AND VARIETY COMPONENTS) - POSITIVELY SCORED (HIGHER INTAKE = HIGHER SCORE), 0-0.75 POINTS
  SCORE_POS_VEGFRU <- function(VALUES) {
    BREAKS <- quantile(VALUES, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)
    dplyr::case_when(
      VALUES > BREAKS[4] ~ 0.75,
      VALUES > BREAKS[3] ~ 0.5,
      VALUES > BREAKS[2] ~ 0.25,
      TRUE ~ 0
    )
  }

  # QUARTILES FOR WHOLE GRAIN SERVINGS - POSITIVELY SCORED (HIGHER INTAKE = HIGHER SCORE), 0-3 POINTS
  SCORE_POS_WGRAIN <- function(VALUES) {
    BREAKS <- quantile(VALUES, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)
    dplyr::case_when(
      VALUES > BREAKS[4] ~ 3,
      VALUES > BREAKS[3] ~ 2,
      VALUES > BREAKS[2] ~ 1,
      TRUE ~ 0
    )
  }


  # QUARTILES FOR RED/PROCESSED MEAT SERVINGS - NEGATIVELY SCORED (LOWER INTAKE = HIGHER SCORE), 0-3 POINTS
  SCORE_NEG_RPMEAT <- function(VALUES) {
    BREAKS <- quantile(VALUES, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)
    dplyr::case_when(
      VALUES <= BREAKS[2] ~ 3,
      VALUES <= BREAKS[3] ~ 2,
      VALUES <= BREAKS[4] ~ 1,
      TRUE ~ 0
    )
  }


  # QUARTILES FOR HIGHLY-PROCESSED FOODS/REFINED GRAINS - NEGATIVELY SCORED (LOWER INTAKE = HIGHER SCORE), 0-1.5 POINTS
  SCORE_NEG_HPFRG <- function(VALUES) {
    BREAKS <- quantile(VALUES, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)
    dplyr::case_when(
      VALUES <= BREAKS[2] ~ 1.5,
      VALUES <= BREAKS[3] ~ 1.0,
      VALUES <= BREAKS[4] ~ 0.5,
      TRUE ~ 0
    )
  }


  # CALCULATE SCORES
  SCORED_DATA <- INTAKE_DATA |>
    dplyr::mutate(
      .ID = !!ID_VAR,
      .SEX = !!SEX_VAR,
      .VEG_SERVINGS = !!VEG_AMT,
      .VEG_VARIETY = !!VEG_VAR,
      .FRUIT_SERVINGS = !!FRT_AMT,
      .FRUIT_VARIETY = !!FRT_VAR,
      .WGRAIN_SERVINGS = !!WG_SERV,
      .MEAT_RP_SERVINGS = !!MEAT_RP,
      .HPF_RG_RATIO = !!HPFRG_RATIO,
      .SSB_SERVINGS = !!SSB_SERV
    ) |>
    dplyr::group_by(.SEX) |>
    dplyr::mutate(
      # SUB-SCORES FOR POSITIVELY-SCORED COMPONENTS (VEGETABLES, FRUITS, AND WHOLE GRAINS) USING SEX-STRATIFIED QUARTILES
      SUBSC_VEG = SCORE_POS_VEGFRU(.VEG_SERVINGS),
      SUBSC_VEGVAR = SCORE_POS_VEGFRU(.VEG_VARIETY),
      SUBSC_FRUIT = SCORE_POS_VEGFRU(.FRUIT_SERVINGS),
      SUBSC_FRUITVAR = SCORE_POS_VEGFRU(.FRUIT_VARIETY),
      SUBSC_WGRAIN = SCORE_POS_WGRAIN(.WGRAIN_SERVINGS),

      # SUB-SCORES FOR NEGATIVELY-SCORED COMPONENTS (RED/PROCESSED MEAT AND HIGHLY-PROCESSED FOODS/REFINED GRAINS) USING SEX-STRATIFIED QUARTILES
      SUBSC_RPMEAT = SCORE_NEG_RPMEAT(.MEAT_RP_SERVINGS),
      SUBSC_HPFRG = SCORE_NEG_HPFRG(.HPF_RG_RATIO)
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      # SUB-SCORE FOR SUGAR-SWEETENED BEVERAGES (NEGATIVELY-SCORED) USING ABSOLUTE THRESHOLDS, NOT QUARTILES
      SUBSC_SSB = dplyr::case_when(
        .SSB_SERVINGS == 0 ~ 1.5,
        .SSB_SERVINGS < 0.428 ~ 1.0,
        .SSB_SERVINGS < 1.0 ~ 0.5,
        TRUE ~ 0
      ),

      # COMBINE VEGETABLE SUB-SCORES (AMOUNT + VARIETY SUB-SCORES), 0-1.5 TOTAL POINTS
      SUBSC_VEGTOT = SUBSC_VEG + SUBSC_VEGVAR,

      # COMBINE FRUIT SUB-SCORES (AMOUNT + VARIETY SUB-SCORES), 0-1.5 TOTAL POINTS
      SUBSC_FRUITTOT = SUBSC_FRUIT + SUBSC_FRUITVAR,

      # TOTAL SCORE CALCULATED FROM SUB-SCORES
      TOTAL_DIETSC = SUBSC_VEGTOT + SUBSC_FRUITTOT +
        SUBSC_WGRAIN + SUBSC_RPMEAT +
        SUBSC_HPFRG + SUBSC_SSB
    ) |>
    dplyr::select(
      PARTICIPANT_ID = .ID,
      SEX = .SEX,
      TOTAL_DIETSC,
      SUBSC_VEGTOT,
      SUBSC_FRUITTOT,
      SUBSC_WGRAIN,
      SUBSC_RPMEAT,
      SUBSC_HPFRG,
      SUBSC_SSB
    )

  return(SCORED_DATA)
}
