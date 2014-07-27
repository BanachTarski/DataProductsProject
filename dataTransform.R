library(data.table)
library(Hmisc)

dat <- read.csv("Inpatient_Prospective_Payment_System__IPPS__Provider_Summary_for_the_Top_100_Diagnosis-Related_Groups__DRG__-_FY2011.csv", stringsAsFactors=TRUE)
dat$Average.Total.Payments <- as.numeric(substring(as.character(dat$Average.Total.Payments),2)) 
dat$Average.Covered.Charges <- as.numeric(substring(as.character(dat$Average.Covered.Charges),2))
dat$Average.Medicare.Payments <- as.numeric(substring(as.character(dat$Average.Medicare.Payments),2))

head(dat)
class(dat$Total.Discharges)

DT <- data.table(dat)

aggDTZip <- DT[,list(Discharges = sum(Total.Discharges),Total.Payments = weighted.mean(Average.Total.Payments, Total.Discharges), Medicare.Payments = weighted.mean(Average.Medicare.Payments, Total.Discharges), Covered.Charges = weighted.mean(Average.Covered.Charges, Total.Discharges)), by = list(Provider.State, Provider.Zip.Code,DRG.Definition)]
wtd.quantile(aggDTZip$Total.Payments,weights=aggDTZip$Total.Discharges)

unique(aggDTZip$DRG.Definition)

DRGQuantiles <- function(data,DRG) {
  data <- subset(data, DRG.Definition == DRG)
  Total.Payments <- c(DRG = DRG,metric = 'Total.Payments',wtd.quantile(aggDTZip$Total.Payments,weights=aggDTZip$Total.Discharges,probs=seq(0,1,.1)))
  Medicare.Payments <- c(DRG = DRG,metric = 'Medicare.Payments',wtd.quantile(aggDTZip$Medicare.Payments,weights=aggDTZip$Total.Discharges,probs=seq(0,1,.1)))
  Covered.Charges <- c(DRG = DRG,metric = 'Covered.Charges',wtd.quantile(aggDTZip$Covered.Charges,weights=aggDTZip$Total.Discharges,probs=seq(0,1,.1)))
  ret <- rbind(Total.Payments,Medicare.Payments,Covered.Charges)
  colnames(ret) <- make.names(colnames(ret))
  ret
}

quantiles <- data.frame(DRG = factor(),
                 metric=factor(), 
                 X0=numeric(),X10=numeric(),X20=numeric(),X30=numeric(),X40=numeric(),X50=numeric(),X60=numeric(),X70=numeric(),X80=numeric(),X90=numeric(),X100=numeric()
)

for (DRG in unique(aggDTZip$DRG.Definition)) {
  quantiles <- rbind(quantiles, DRGQuantiles(aggDTZip,DRG))
}

write.table(aggDTZip,file="PaymentsAndCharges_ByZip.csv",sep=",",row.names=F)
write.table(aggDTState,file="PaymentsAndCharges_ByState.csv",sep=",",row.names=F)
write.table(aggDTDRG,file="PaymentsAndCharges_ByDRG.csv",sep=",",row.names=F)

write.table(quantiles,file="DRGQuantiles.csv",sep=",",row.names=F)

aggDatZip <- read.csv("PaymentsAndCharges_ByZip.csv", stringsAsFactors=TRUE)
aggDatZip$Provider.Zip.Code <- factor(aggDatZip$Provider.Zip.Code)

DRGQuantiles <- read.csv("DRGQuantiles.csv", stringsAsFactors=TRUE)

getQuantileData <- function(drg,m) {
  subset(DRGQuantiles, DRG == drg & metric == m)[,3:13]
}

aggDatZip <- within(aggDatZip, Total.Payments.quantile <- as.integer(cut(Total.Payments, getQuantileData(DRG,'Total.Payments'), include.lowest=TRUE)))
aggDatZip <- within(aggDatZip, Medicare.Payments.quantile <- as.integer(cut(Medicare.Payments, getQuantileData(DRG,'Medicare.Payments'), include.lowest=TRUE)))
aggDatZip <- within(aggDatZip, Covered.Charges.quantile <- as.integer(cut(Covered.Charges, getQuantileData(DRG,'Covered.Charges'), include.lowest=TRUE)))

aggDatState <- read.csv("PaymentsAndCharges_ByState.csv", stringsAsFactors=TRUE)
aggDatState$Provider.State <- factor(aggDatState$Provider.State)

aggDatState <- within(aggDatState, Total.Payments.quantile <- as.integer(cut(Total.Payments, getQuantileData(DRG,'Total.Payments'), include.lowest=TRUE)))
aggDatState <- within(aggDatState, Medicare.Payments.quantile <- as.integer(cut(Medicare.Payments, getQuantileData(DRG,'Medicare.Payments'), include.lowest=TRUE)))
aggDatState <- within(aggDatState, Covered.Charges.quantile <- as.integer(cut(Covered.Charges, getQuantileData(DRG,'Covered.Charges'), include.lowest=TRUE)))

write.table(aggDatZip,file="PaymentsAndCharges_ByZip.csv",sep=",",row.names=F)
write.table(aggDatState,file="PaymentsAndCharges_ByState.csv",sep=",",row.names=F) 

gvis <- renderGvis({
  
  myData <- subset(aggDatState,DRG.Definition == '039 - EXTRACRANIAL PROCEDURES W/O CC/MCC')
  gvisGeoChart(myData,
               locationvar="Provider.State", colorvar="Total.Payments.quantile",
               options=list(region="US", displayMode="regions", 
                            resolution="provinces",
                            width=500, height=400,
                            colorAxis="{colors:['#FFFFFF', '#0000FF']}"
               ))        
})

makePlot <- function(drg,loc,type) {
  myData <- subset(aggDatState,DRG.Definition == drg)
  gvisGeoChart(myData,
               locationvar=loc, colorvar=type,
               options=list(region="US", displayMode="regions", 
                            resolution="provinces",
                            width=500, height=400,
                            colorAxis="{colors:['#00FF00', '#B0171F']}"
               ))  
}

unique(aggDatState$DRG.Definition)

plot(makePlot(unique(aggDatState$DRG.Definition)[2],"Provider.State","Total.Payments"))

plot(
  myData <- subset(aggDatState,DRG.Definition == drg)
  gvisGeoChart(myData,
               locationvar=loc, colorvar=type,
               options=list(region="US", displayMode="regions", 
                            resolution="provinces",
                            width=500, height=400,
                            colorAxis="{colors:['#00FF00', '#B0171F']}"
               ))  
  )