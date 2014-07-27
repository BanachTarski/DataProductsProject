# Markus Gesmann, February 2013
require(googleVis)
require(shiny)
require(RCurl)

## Prepare data to be displayed

x <- getURL("https://raw.githubusercontent.com/BanachTarski/DataProductsProject/master/PaymentsAndCharges_ByState.csv")
aggDatState <- read.csv(text = x, stringsAsFactors=TRUE)

#aggDatState <- read.csv("PaymentsAndCharges_ByState.csv", stringsAsFactors=TRUE)
aggDatState$Total.Payments <- round(aggDatState$Total.Payments,2)
aggDatState$Medicare.Payments <- round(aggDatState$Medicare.Payments)
aggDatState$Covered.Charges <- round(aggDatState$Covered.Charges)

shinyServer(function(input, output) {
  
  myDRG <- reactive({
    input$DRG
  })
  
  mytype <- reactive({
    switch(input$type,
           "Total Payments" = "Total.Payments",
           "Medicare Payments" = "Medicare.Payments",
           "Covered Charges" = "Covered.Charges")
  })
  
  output$DRG <- renderText({
    paste(input$type," for ",myDRG())
  })

  output$gvis <- renderGvis({
    myData <- subset(aggDatState,DRG.Definition == myDRG())
    gvisGeoChart(myData,
                 locationvar="Provider.State", colorvar=mytype(),
                 options=list(region="US", displayMode="regions", 
                              resolution="provinces",
                              width=500, height=400,
                              colorAxis="{colors:['#FFFF00', '#FF0000']}"
                 ))  
  })
})