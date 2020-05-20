library(shiny)


shinyUI(fluidPage(
    
    
    # Application title -------------------------------------------------------
    titlePanel(textOutput(outputId = "dateTitle")),
    # -------------------------------------------------------------------------
    
    sidebarLayout(
        # Sidebar - usually containing inputs -------------------------------------
        
        sidebarPanel(
            
            textInput(inputId = "title", 
                      label = "Plot Title", 
                      value = "Comparing cars"),
            
            checkboxInput(inputId = "ci",
                          label = "Show confidence intervals"),
            
            dateInput(inputId = "date",
                      label = "date",
                      value = "2020-03-01"),
            
            numericInput(inputId = "bins",
                         label = "Histogram bins",
                         value = 30),
            
            radioButtons(inputId = "col",
                         label = "Colour", 
                         choices = c("darkgoldenrod", "red", "orchid2")),
            
            selectInput(inputId = "comparator",
                        label = "comparator", 
                        choices = c("mpg", "disp", "hp", "drat", "wt", "qsec", "am", "gear", "carb"))
            
        ),
        
        
        # Main panel - usually containing outputs ---------------------------------
        
        mainPanel(
            column(8,
                   plotOutput(outputId = "distPlot"),
                   plotOutput(outputId = "dotPlot")
            ),
            column(4,
                   DT::dataTableOutput(outputId = "data")
            )
        )
        
        
        
        # -------------------------------------------------------------------------
    )
))
