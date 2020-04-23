# This is an empty app for you to use as a starting structure

###############################################.
## Global ----
###############################################.
# Add packages, datasets and functions here.
library(shiny)

###############################################.
## UI ----
###############################################.
# User interface - layout, filters and text
ui <- fluidPage("Shiny app", 
                h3("Hello World!")
                
) # fluidPage bracket

###############################################.
## Server ----
###############################################.

server <- function(input, output, session) {
  
  
} # end of server

shinyApp(ui = ui, server = server) # Running the app