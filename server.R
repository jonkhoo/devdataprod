library(shiny)
library(ggplot2)
library(quantmod)
library(forecast)
library(lubridate)

# The data comes from the site http://quotes.wsj.com/index/DJIA/historical-prices.
# We downloaded the data from 1987 Feb to 2015 Sep. We can't find more data exceeding those periods.
dowdata <- read.csv("HistoricalPrices.csv")
dowdata$Date <- as.Date(dowdata$Date, "%m/%d/%y")
dowdata <- dowdata[order(dowdata$Date),]

shinyServer(
  

    function(input, output) {

      observe({
        v <- renderText({input$fields})
        f <- unlist(strsplit(v(), split=" "))
        print(f)        
      })
      
      
      # We manipulate the data frame to contain the data for the selected dates.
      # We also attempt to perform server calculation to predict the index value for the next n days.
      
      myData <- reactive({
        start <- as.Date(input$daterange[1])
        end <- as.Date(input$daterange[2])
        
        # Data for the selected dates
        data <- dowdata[dowdata$Date>=start & dowdata$Date<=end,]
        
        sensor <- ts(data$High, frequency=5)
        fit <- auto.arima(sensor)
        fcast <- forecast(fit, h=input$prediction)
        high_pred <- as.numeric(fcast$mean)
        
        sensor <- ts(data$Open,frequency=1)
        fit <- auto.arima(sensor)
        fcast <- forecast(fit, h=input$prediction)
        open_pred <- as.numeric(fcast$mean)
        
        sensor <- ts(data$Low,frequency=1)
        fit <- auto.arima(sensor)
        fcast <- forecast(fit, h=input$prediction)
        low_pred <- as.numeric(fcast$mean)
        
        sensor <- ts(data$Close,frequency=1)
        fit <- auto.arima(sensor)
        fcast <- forecast(fit, h=input$prediction)
        close_pred <- as.numeric(fcast$mean)

        n <- nrow(data)
        for (i in seq(1:input$prediction)){
          data[n+i,]$Date <- end+i
          data[n+i,]$High <- high_pred[i]
          data[n+i,]$Open <- open_pred[i]
          data[n+i,]$Low <- low_pred[i]
          data[n+i,]$Close <- close_pred[i]
        }
        
        data
                        
      })

      myFields <- reactive({
        input$fields
      })

      
      
      # Plot the graph based on the input selections      
      plt <- reactive ({
        g <- ggplot() +
          xlab("Date") + 
          ylab("Index") +
          ggtitle(paste("DJIA from ", input$daterange[1], " to ", input$daterange[2]))

        fields <- myFields()
        for (i in fields) {
          
          # Plot a line graph
          if (input$graphtype == "line") {
            if (i == "High") {
              g <- g + geom_line(data=myData(), aes(x=Date, y=High), colour="green")
            }
            if (i == "Open") {
              g <- g + geom_line(data=myData(), aes(x=Date, y=Open), colour="blue")
            }
            if (i == "Low") {
              g <- g + geom_line(data=myData(), aes(x=Date, y=Low), colour="red")
            }
            if (i == "Close") {
              g <- g + geom_line(data=myData(), aes(x=Date, y=Close), colour="black")
            }
          }

          
          # Plot a bar chart
          if (input$graphtype == "bar") {
            if (i == "High") {
              g <- g + geom_bar(data=myData(), aes(x=Date, y=High), fill="#00ff00", colour="black", stat = 'identity', position = 'dodge')
            }
            if (i == "Open") {
              g <- g + geom_bar(data=myData(), aes(x=Date, y=Open), fill="#0000ff", colour="black", stat = 'identity', position = 'dodge')
            }
            if (i == "Low") {
              g <- g + geom_bar(data=myData(), aes(x=Date, y=Low), fill="#ff0000", colour="black", stat = 'identity', position = 'dodge')
            }
            if (i == "Close") {
              g <- g + geom_bar(data=myData(), aes(x=Date, y=Close), fill="#cccccc", colour="black", stat = 'identity', position = 'dodge')
            }
          }
        }
        g
      })
      

      # Feedback the inputs to ui.R for printing
      output$inputdate <- renderPrint({paste("Date Range = ", input$daterange[1], " to ", input$daterange[2])})
      output$inputgraph <- renderPrint({paste("Graph Type = ", input$graphtype)})      
      output$inputfields <- renderPrint(paste("Fields = ", input$fields))
      output$inputprediction <- renderPrint({paste("Prediction = ", input$prediction)})


      # Plot the graph
      output$plots <- renderPlot({
        plt()
      })
        

          
   }
)