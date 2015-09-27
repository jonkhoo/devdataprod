library(shiny)

shinyUI(pageWithSidebar(
    headerPanel('Course Project - Developing Data Products'),
    
    sidebarPanel(
        h3('Instructions'),
        p('Enter your selection below.'),
        
        dateRangeInput('daterange', 
                       'Date Range:', 
#                       start  = "1995-01-01",
                       start  = "2015-08-25",
                       end    = "2015-09-25",                       
                       min    = "1987-02-02",
                       max    = "2015-09-25",
                       format = "mm/dd/yyyy",
                       separator = " to ",
                       startview = "decade"),
                       
        radioButtons('graphtype', 
                     'Graph Type:', 
                     c('Bar Chart' = "bar", 'Line Graph' = "line"), 
                     selected = 'line'), 
        
        checkboxGroupInput('fields', 
                           'Data to include:',
                           choices = c("Open" = "Open", 
                             "High" = "High",
                             "Low" = "Low",
                             "Close" = "Close"),
                           selected = c("Open", "Close")),

        sliderInput('prediction', 
                    'Number of Predictions:', 
                    min=10, max=50, value=10)

    ),
    
    mainPanel(
        h3('Values entered:'),
        verbatimTextOutput("inputdate"),
        verbatimTextOutput("inputgraph"),
        verbatimTextOutput("inputfields"),
        verbatimTextOutput("inputprediction"),

        plotOutput('plots'),
        h3('Method'),
        p('This shiny application presents the DJIA index value. Based on the data, 
          we attempt to predict the index value for the next n days. n is prediction value.
          We also plot the different graphs for the different information type (High, Open,
          Low, Close). '),
        br(),
        h3('References'),
        p('The Dow Jones Industrial Average (DJIA) from Feb 1987 to Sep 2015. The data 
          comes from the site http://quotes.wsj.com/index/DJIA/historical-prices.')
    )
))