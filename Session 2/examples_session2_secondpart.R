# Supporting code for presentation in Session 2 - 2nd half
###############################################.
## Packages ----
###############################################.
library(shiny)
library(readr)
library(ggplot2)

###############################################.
## Introducing the data sets ----
###############################################.
# This data has already been aggregated and calculated.
# Try to do as much of your calculations outside of Shiny:
st_rates_ethnicity <- read_csv("data/st_rates_by_ethnicity_age_dep_2011.csv")
head(st_rates_ethnicity)
View(st_rates_ethnicity)

# This one includes the rii/sii
rii_sii_ethnicity <- read_csv("data/RII_SII_by_ethnicity_age_dep_2011.csv")
head(rii_sii_ethnicity)
View(rii_sii_ethnicity)

###############################################.
## Empty app ----
###############################################.
file.edit('exercises/empty_shiny_app.R')

###############################################.
## Reactivity - before including it ----
###############################################.
# Just an static table with the first few rows of the dataset
ui <- fluidPage("Shiny app",
                tableOutput("table")
) 


server <- function(input, output, session) {
  
  output$table <- renderTable({ 
    head(st_rates_ethnicity) 
  })
  
} 

shinyApp(ui = ui, server = server) # Running the app

###############################################.
## Reactivity - adding filter ----
###############################################.

ui <- fluidPage("Shiny app",
                selectInput(inputId = "age_group", label = "Select an age group", 
                            choices = unique(st_rates_ethnicity$age)),
                tableOutput("table")
) 

server <- function(input, output, session) {
  
  output$table <- renderTable({ 
    head(st_rates_ethnicity) 
  })
  
} 

shinyApp(ui = ui, server = server) # Running the app


###############################################.
## Reactivity - making reactive ----
###############################################.

ui <- fluidPage("Shiny app",
                selectInput(inputId = "age_group", label = "Select an age group", 
                            choices = unique(st_rates_ethnicity$age)),
                tableOutput("table")
) 


server <- function(input, output, session) {
  
  output$table <- renderTable({ 
    st_rates_ethnicity %>% filter(input$age_group == age)
  })
  
} 

shinyApp(ui = ui, server = server) # Running the app


###############################################.
## Reactivity -  it helps to start static first ----
###############################################.
# Imagine you want a bar plot with rates for overall age group
# and outcome poor general health and make it vary depending on the ethnicity chosen
# You can filter your data and select one ethnicity to check that all your process work:
rates_filtered <- st_rates_ethnicity %>% 
  filter(ethnicity == "Mixed" &
           outcome == "poor GH" &
           age == "all")

# Then you can plot it
ggplot(rates_filtered, aes(x = ses, y = rate)) +
  geom_bar(stat = "identity")

# Is this the chart you wanted? Does it work? Yes? Great! Now you can put it into Shiny each bit inside
# a reactive/render function and substitute the "Mixed" ethnicity by "input$ethnicity"

# User interface - layout, filters and text
ui <- fluidPage("Shiny app",
                selectInput(inputId = "ethnicity", label = "Select an ethnicity", 
                            choices = unique(st_rates_ethnicity$ethnicity)),
                plotOutput("plot")
) 


server <- function(input, output, session) {
  
  output$plot <- renderPlot({ 
    rates_filtered <-  st_rates_ethnicity %>% 
      filter(ethnicity == input$ethnicity &
               outcome == "poor GH" &
               age == "all")
    
    ggplot(rates_filtered, aes(x = ses, y = rate)) +
      geom_bar(stat = "identity") 
  })
  
} 

shinyApp(ui = ui, server = server) # Running the app

###############################################.
## Reactivity -  reactive  objects ----
###############################################.
ui <- fluidPage("Shiny app",
                selectInput(inputId = "ethnicity", label = "Select an ethnicity", 
                            choices = unique(st_rates_ethnicity$ethnicity)),
                tableOutput("table"),
                plotOutput("plot")
) 


server <- function(input, output, session) {
  
  # Adding a reactive object allows us to use it in multiple renders
  rates_filtered <- reactive({
    st_rates_ethnicity %>% 
      filter(ethnicity == input$ethnicity &
               outcome == "poor GH" &
               age == "all")
    
  })
  
  output$table <- renderTable({ 
    rates_filtered() 
  })
  
  output$plot <- renderPlot({ 
    ggplot(rates_filtered(), aes(x = ses, y = rate)) +
      geom_bar(stat = "identity") 
  })
  
} 

shinyApp(ui = ui, server = server) # Running the app


##END