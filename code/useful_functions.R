




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


### ----- Plot palette ----
pal_loc <- function(){
  return(c("GLL"="#AA3939",
           "MRD"="#FFA91B",
           "LGD"="#FFE400",
           "CRK"="#2FD21E",
           "CRT"="#0C2576",
           "PRP"="#D4F74B",
           "FRG"="#FD242A",
           "BRK"="#79DCDC",
           "STP"="#7829E0",
           ## locations specific to URSN
           "SWC"="#C2AD00",
           "BRD"="#9C0058",
           "WNP"="#77B500",
           "WLT"="#3610E1",
           "SDN"="#130AAF",
           "PLM"="#FB7200",
           "BZM"="#4977E2",
           "PWL"="#02BADC",
           "HTG"="#017E95",
           "SLB"="#ED6E94",
           "MNT"="#723900",
           "TPS"="#00941A",
           "FRM"="#FFF709",
           "GRT"="#BA0038",
           "MRS"="khaki4"
  ))
}

pal_orga <- function(){
  return(c("UMN"="#ffcc33",#"#7A0018CE",#"#7a0019",
           "UMN_BP"="#ffcc33",
           "NDSU"="#2E8B57",#127A5DF8",
           "NDSU_BP"="#36BA55",
           "SDSU"="#3A5FCD",#"#0642CC",
           "MSU"="#bd9b04",#"#BAA15BE2",#"#B9975B",
           "AgriPro"="#8A42C9",
           "Syngenta"="#F5586A",
           "Trigen"="#F54954",
           "AAFC_CRC"="#46688F",
           "Limagrain"="#61393C",
           "AAFC_AAC"="#43AABA",
           "AAFC_SPARC"="#79ADF2",
           "AAFC"="dodgerblue",
           "WestBred"="lightpink2",
           "UIDO"="#d7f96e",#"#f1b300",
           "Ukn_URSN"="ivory2",#"#EEAEEE",
           "all"="grey67","Ukn"="grey67","Unknown"="grey67",
           "Check"="#1A1C23")
  )
}
