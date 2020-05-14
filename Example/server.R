library(shiny)
library(dplyr)
library(ggplot2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    df <- reactive({
        mtcars %>% 
            select(cyl, input$comparator)
    })
    
    output$dateTitle <- renderText({paste("Analysis on", format(input$date, "%d %B %Y"))})
    
    
    output$distPlot <- renderPlot({
        
        ggplot(df(), aes_string(x = input$comparator)) +
            geom_histogram(colour = input$col, fill = input$col,
                           bins = input$bins) +
            ggtitle(input$title)

    })
    
    output$dotPlot <- renderPlot({
        
        ggplot(df(), aes_string(x = "cyl", y = input$comparator)) +
            geom_point(colour = input$col) +
            geom_smooth(se = input$ci, colour = input$col)
        
    })
    
    output$data <- DT::renderDataTable(
        {
            df() %>% 
                mutate(Car = rownames(.)) %>% 
                select(Car, cyl, matches(input$comparator)) %>% 
                arrange(desc(get(input$comparator))) %>% 
                DT::datatable(options = list(pageLength = 25, searching = FALSE))
        }
    )
    
})
