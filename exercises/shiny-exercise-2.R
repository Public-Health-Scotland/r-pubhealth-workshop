# Solved script for exercise found https://github.com/ScotPHO/r-pubhealth-workshop/wiki/Session-2-Exercise-2---More-interactivity-in-Shiny
# To run, it needs to be in its a folder that includes a subfolder called data and
# include the dataset "st_rates_by_ethnicity_age_dep_2011.csv" and "RII_SII_by_ethnicity_age_dep_2011.csv".

###############################################.
## Global ----
###############################################.
library(shiny)
library(ggplot2)
library(dplyr)
library(readr)

# Reading in the data
rii_sii_ethnicity <- read_csv("data/RII_SII_by_ethnicity_age_dep_2011.csv")
st_rates_ethnicity <- read_csv("data/st_rates_by_ethnicity_age_dep_2011.csv")

ethnicity_list <- unique(st_rates_ethnicity$ethnicity)

###############################################.
## UI ----
###############################################.
ui <- fluidPage("Inequalities in health by ethnicity in Scotland", 
                # Select box for ethnicity for first plot
                selectInput(inputId = "ethnicity", label = "Select an ethnicity", 
                            choices= ethnicity_list),
                plotOutput("rates_plot"), # plot with standard rates
                # Select box for what type of inequality measure you want
                selectInput(inputId = "ineq_measure", label = "Select a measure of inequality", 
                            choices= c("RII", "SII")),
                plotOutput("siirii_plot") # sii/rii plot
) # fluidPage bracket

###############################################.
## Server ----
###############################################.

server <- function(input, output, session) {
  
  # Filtering data based on user input and focusing on overall rates for
  # outcome "poor general health"
  st_rates_filtered <- reactive({
    st_rates_ethnicity %>% 
      filter(ethnicity == input$ethnicity &
               outcome == "poor GH" &
               age == "all")
  })
  
  # Doing a similar thing for the rii/sii dataset, but filtering by measure selected
  rii_sii_filtered <- reactive({
    rii_sii_ethnicity %>% 
      filter(outcome == "poor GH" & 
               age == "all" &
               measure == input$ineq_measure)
  })

  # Plotting rates by quintile and rate
  output$rates_plot <- renderPlot({
    ggplot(st_rates_filtered(), aes(x = ses, y = rate)) +
      geom_bar(stat = "identity") +
      # Adding error bars
      geom_errorbar(aes(ymin = CI_low, ymax = CI_high)) 
      
  })
  
  # Plotting sii/rii by ethnicity
  output$siirii_plot <- renderPlot({
    ggplot(rii_sii_filtered(), aes(x = ethnicity, y = estimate)) +
      geom_bar(stat = "identity") +
      # Adding error bars
      geom_errorbar(aes(ymin = ci_low, ymax = ci_high)) 
  })
  
} # end of server

shinyApp(ui = ui, server = server) # Running the app
