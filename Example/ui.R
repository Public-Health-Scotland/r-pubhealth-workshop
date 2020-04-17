library(shiny)


shinyUI(fluidPage(

    # Application title
    titlePanel("Examples of inputs and outputs"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput(inputId = "bins",
                        label = "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30),
            
            textInput(inputId = "gtitle",
                      label = "Graph title",
                      value = "Histogram of BMI"),
            
            checkboxInput(inputId = "checks",
                          label = "Check boxes"),
            
            dateInput("date",
                      "My birthday",
                      value = "1987-05-17",
                      format = "d MM yyyy")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("distPlot")
        )
    )
))
