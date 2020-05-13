# Solved script for exercise found https://github.com/jvillacampa/r-pubhealth-workshop/wiki/Session-2-Exercise-1---simple-Shiny-app
# To run, it needs to be in its a folder that includes a subfolder called data and
# include the dataset "st_rates_by_ethnicity_age_dep_2011.csv".

###############################################.
## Global ----
###############################################.
# Add packages, datasets and functions here.
library(shiny)
library(dplyr)
library(readr)

# Reading dataset
st_rates_ethnicity <- read_csv("data/st_rates_by_ethnicity_age_dep_2011.csv")

###############################################.
## UI ----
###############################################.
# User interface - layout, filters and text
ui <- fluidPage("Shiny app",
                # Adding a title
                h2("R for Public health and health inequalities"),
                h2(textOutput("table_title")), 
                tableOutput("table")
                
) # fluidPage bracket

###############################################.
## Server ----
###############################################.

server <- function(input, output, session) {
  
  ethnicity_chosen <- "Mixed" # selecting an ethnicity
  
  # Filtering dataset based on ethnicity selected
  ethinicity_filtered <- st_rates_ethnicity %>% 
    filter(ethnicity == ethnicity_chosen)
  
  
  # Creating table to show structure of data
  output$table <- renderTable({ head(ethinicity_filtered ) })
  
  # Title for the table
  output$table_title<- renderText({ paste0("Data for the ethnicity ", ethnicity_chosen ) })
  
} # end of server

shinyApp(ui = ui, server = server) # Running the app
