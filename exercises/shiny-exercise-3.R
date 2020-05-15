# Solved script for exercise found https://github.com/ScotPHO/r-pubhealth-workshop/wiki/Session-2-Exercise-3---Extra,-creating-map
# To run, it needs to be in its a folder that includes a subfolder called data and
# include the dataset "data/hb_alcohol_admissions.csv".

###############################################.
## Global ----
###############################################.
# Add packages, datasets and functions here.
library(shiny)
library(dplyr)
library(readr)
library(leaflet)

# Reading dataset and shapefile
alc_adm <- read_csv("data/hb_alcohol_admissions.csv")
hb_bound <- readRDS("data/HB_boundary.rds")

###############################################.
## UI ----
###############################################.
# User interface - layout, filters and text
ui <- fluidPage("Shiny app",
                # Adding a title
                h2("R for Public health and health inequalities"),
                selectInput("period", "Select a time period", choices = unique(alc_adm$period)),
                leafletOutput("map", height="550px")
                
) # fluidPage bracket

###############################################.
## Server ----
###############################################.

server <- function(input, output, session) {
  
  #Plotting map
  output$map <- renderLeaflet({
    
    alc_adm_filt <- alc_adm %>% filter(period == input$period) %>% 
      select(-area_name) # to avoid duplication of name variables
    
    # Merging data with admissions data
    map_data <- sp::merge(hb_bound, alc_adm_filt, by= "code")
    
    # Creating palette of colours, dividing in 4 groups
    pal <- colorQuantile("YlOrRd", domain = map_data$rate, n = 4)
    
    #Actual map
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>% # base tiles
      addPolygons(data=map_data,
                  color = "#444444", weight = 2, smoothFactor = 0.5,
                  #tooltip for hover over
                  label = (sprintf(
                    "<strong>%s</strong><br/>Total: %g<br/>Rate: %g",
                    map_data$area_name, map_data$numerator, map_data$rate) %>% lapply(htmltools::HTML)),
                  opacity = 1.0, fillOpacity = 0.5, fillColor = ~pal(rate), #Colours
                  # Hover over effects
                  highlightOptions = highlightOptions(color = "white", weight = 2,
                                                      bringToFront = TRUE)
      )
    
  })
  
} # end of server

shinyApp(ui = ui, server = server) # Running the app
