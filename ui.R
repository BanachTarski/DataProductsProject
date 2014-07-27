require(shiny)
require(RCurl)

x <- getURL("https://raw.githubusercontent.com/BanachTarski/DataProductsProject/master/PaymentsAndCharges_ByState.csv")
aggDatState <- read.csv(text = x, stringsAsFactors=TRUE)

shinyUI(pageWithSidebar(
  headerPanel("Payments and Charges by DRG"),
  sidebarPanel(
    p('Use the selection boxes below to indicate what information you would like to see displayed.'),
    selectInput("DRG", "Choose a DRG:", 
                choices = unique(aggDatState$DRG.Definition),width = "150%"),
    selectInput("type", "What type of data would you like to see?", 
                choices = c("Total Payments","Medicare Payments", "Covered Charges")),
    helpText(a("Data from CMS",href="https://data.cms.gov/Medicare/Inpatient-Prospective-Payment-System-IPPS-Provider/97k6-zzx3"))
  ),
  mainPanel(
    h3(textOutput("DRG")), 
    htmlOutput("gvis"),
    p(a("Diagnosis-related groups (DRGs)",     href="http://en.wikipedia.org/wiki/Diagnosis-related_group"), 
      'are used by hospitals to classify encounters.  The average charges posted by hospitals, as well as the payments received by the government, insurance companies, and patients vary from state to state.')
  )
)
)