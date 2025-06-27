

#' Estimate genetic gain for selected traits
#'
#' @param data data frame with columns for traits and first year of evaluation
#' @param traits character vector of trait names
#' @param first_year character vector of column names for first year of evaluation.
#' The first year will be subtracted by the minimal first year for the estimation of the intercept and percentage of change
#'
#' @returns data frame with columns for trait, intercept, slope, R2.adj, pvalue and percentage of change
#' @author Charlotte Brault
GGAIN <- function(data, traits, first_year){
  stopifnot(all(traits %in% colnames(data)),
            all(first_year %in% colnames(data)))
  ## subtract the minimum first year to the calculation of the percentage of change
  data$FIRST_YEAR0 <- data[[first_year]] - min(data[[first_year]], na.rm=T) +1

  df.fit <- data.frame(trait=traits, intercept=NA, slope=NA,
                       slope.min=NA, slope.max=NA, R2.adj=NA, pvalue=NA)
  for(tr in traits){
    fit <- lm(paste0(tr, "~ 1 + FIRST_YEAR0"), data = data)
    idx <- which(df.fit$trait %in% tr)
    ## add intercept and slope
    df.fit[idx,c("intercept","slope")] <- round(c(coef(fit)[c(1,2)]),3)
    ## get confidence interval
    df.fit[idx,c("slope.min","slope.max")] <- round(confint(fit, "FIRST_YEAR0", level = 0.95)[,1:2],3)
    ## get R2
    df.fit[idx,"R2.adj"] <- round(summary(fit)$adj.r.squared,3)
    ## get p-value
    df.fit[idx,"pvalue"] <-  formatC(summary(fit)$coefficients[2,4], format="e", digits=2)
  }
  ## estimate the percentage of change
  df.fit$percChange <- round((df.fit$slope/df.fit$intercept)*100,2)


  return(df.fit)
}


### ----- Print table ------
## from R metan package
# Function to make HTML tables
print_table <- function(table, rownames = FALSE, digits = 3, ...){
  require(DT)
  df <- DT::datatable(table, rownames = rownames, extensions = 'Buttons',
                      options = list(scrollX = TRUE,
                                     dom = '<<t>Bp>',
                                     buttons = c('copy','csv', 'excel', 'pdf', 'print')), ...)
  num_cols <- c(as.numeric(which(sapply(table, class) == "numeric")))
  if(length(num_cols) > 0){
    DT::formatSignif(df, columns = num_cols, digits = digits)
  } else{
    df
  }
}


