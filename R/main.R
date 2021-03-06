#' Non-parametric analysis of response curves
#'
#' Wrapper function for melting curve fitting and hypothesis testing.
#'
#' @param x numeric vector of the independent variables (typically temperature)
#' @param y numeric vector of the dependent variables (typically relative abundance measurements)
#' @param id character vector with the protein ID to which each each data point belongs.
#' @param control list of parameters used to control specific parts of the analyse
#' @param BPPARAM BiocParallel parameter object to invoke curve fitting in parallel. Default: BiocParallel::SerialParam()
#' @param dfType character value indicating the method for degrees of freedom computation for the F-test. 
#'  Theoretical yields the text-book solution. Empirical yields estimates derived from the distribution moments of the RSS.
#' @param groupsNull one or more vectors with grouping variables for the null models. See details.
#' @param groupsAlt one or more vectors with grouping variables for the alternative models. See details.
#' @return data frame with fitted model parameters and additional columns listing e.g. residuals sum of squares of
#'  null and alterantive model
#' @details
#' \code{groupsNull} or \code{groupsAlt} can either be a single vector each, or data.frames of the same length as \code{x} and \code{y} with one column per factor
#'
#' @export
#'
#' @examples
#' data(stauro_TPP_data_tidy)
#' df <- dplyr::filter(stauro_TPP_data_tidy, grepl("CDK|GTP|CRK", uniqueID))
#' testResults <- runNPARC(x = df$temperature,
#'                      y = df$relAbundance,
#'                      id = df$uniqueID,
#'                      groupsAlt = df$compoundConcentration,
#'                      dfType = "empirical")
runNPARC <- function(x,
                     y,
                     id,
                     groupsNull = NULL,
                     groupsAlt,
                     BPPARAM = BiocParallel::SerialParam(progressbar = TRUE),
                     dfType = c("theoretical", "empirical"),
                     control = getParams()){

  fits <- NPARCfit(x = x,
                   y = y,
                   id = id,
                   groupsNull = groupsNull,
                   groupsAlt = groupsAlt,
                   BPPARAM = BPPARAM,
                   returnModels = FALSE,
                   control = control)

    modelMetrics <- fits$metrics

    testRes <-  NPARCtest(modelMetrics, dfType = dfType)

  return(testRes)
}
