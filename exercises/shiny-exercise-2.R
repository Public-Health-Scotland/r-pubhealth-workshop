
###############################################.
## Global ----
###############################################.
source("packages.R") # load packages

# Reading in the data
rii_sii_ethnicity <- read_csv("data/RII_SII_by_ethnicity_age_dep_2011.csv")
st_rates_ethnicity <- read_csv("data/st_rates_by_ethnicity_age_dep_2011.csv")

age_grps <- unique(st_rates_ethnicity$age)
depr_grps <- unique(st_rates_ethnicity$ses)


###############################################.
## UI ----
###############################################.
ui <- fluidPage("Scotland Test", 
                h3("Hello World!"),
                br(),
                selectInput("age", "Select age group", choices = age_grps),
                selectInput("depr", "Select deprivation group", choices = depr_grps),
                plotOutput("barplot")
                
) # fluidPage bracket

###############################################.
## Server ----
###############################################.

server <- function(input, output, session) {
  
  # Filtering data based on user input
st_rates_filtered <- reactive({
  st_rates_ethnicity %>% 
    filter(age == input$age &
             ses == input$depr)
})

  output$barplot <- renderPlot({
    ggplot(st_rates_filtered(), aes(x = ethnicity, y = rate)) +
      geom_bar(stat = "identity")
  })
  
} # end of server

shinyApp(ui = ui, server = server) # Running the app
