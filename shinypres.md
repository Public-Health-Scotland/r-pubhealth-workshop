shinypres
========================================================
author: Jaime Villacampa and Andrew Baxter
date: 28 May 2020
autosize: true

What is Shiny?
========================================================

- A package that makes websites.
- Translates R code into web code: HTML, CSS and JavaScript.
- Works well with data.

Why use Shiny?
========================================================

- Price
- Flexibility
- Potential
- Public engagement
- Reproducibility and open research

Advantages
========================================================

- Mapping and modelling
- Extremely flexible
- Develop a new skill set


Disadvantages
========================================================

- Potentially not widely used in your organisation
- Easy for public-facing data, not as easy for confidential information
- Time of development


Differences with normal R code
========================================================

- Code divided in three parts: global, ui and server
- The code can respond to user input
- Ability to integrate CSS/HTML/Javascript
- Differences in the order of things run

The parts of an app
========================================================

- Global
- Server
  - Does all the hard work! Where the R code goes
- UI (user interface)
  - Builds the html page

How to build a shiny app
========================================================

- ui.R
  - `*Input(inputId = "a")` - passes input "a" to server
  - `*Output(outputId = "b")` - gets output "b" from server

***
- server.R
  - `input$a` - gets input "a" from ui
  - `output$b <- render*(...)` - passes output "b" to ui
  
Input functions - some examples
========================================================
- `textInput()`
- `checkboxInput()`
- etc.
  
Each assigns an 'inputId' and passes to `input$id` in the server

Ouput funcions - some examples
========================================================
**Rendered** in server.R
- `output$x <- renderText()`
- `output$y <- renderPlot()`
- `output$z <- renderDataTable()`

***
...**outputed** in ui.R by:
- `textOutput(outputId = 'x')`
- `plotOutput(outputId = 'y')`
- `dataTableOutput(outputId = 'z')`

The app flow
========================================================

*intype*Input(InputId = "a", ...)

output$x <- render*Outtype*()

*outtype*Output(outputId = "x")
  
========================================================
<!-- Static first, adding interactivity later -->
<!-- Introduce static chart, then introduce the dropdowns, then explain reactivity -->
<!-- Explain things like the run app button -->
<!-- Explain the UI setup and how add widgets -->
<!-- What parts of the app run first and in what order -->

Exercise: building a simple Shiny app
========================================================

Building app from visualisations from first part


Exercise: app with public health inequalities
========================================================

Introduce something a bit more complex that they need to build from scratch
Perhaps if first is visualisation for rates of morbidity, next is visualising 
rii/sii trends and par – range? Other indexes?


How to publish an app
========================================================

- shinyapps.io - cloud server
- Shiny Server
- Shiny Proxy

There is more than code to Shiny apps
========================================================

- Version control
- User testing, over and over
- Different skill set: design, visual, creative


Add-ons
========================================================

Lots of options to customise your app, some easier than others:
- Packages: shinyWidgets, shinythemes and shinycssloaders
- Packages: shinyjs, shinyBS
- Create your own HTML, CSS or JavaScript


Tricks for debugging a Shiny app
========================================================

- Start static add reactivity later
- observeEvent trick
- Add links to useful resources on this
- Jaime has presentation on this. I can quickly summarise.


Extra exercises
========================================================

Some more complex things, or how to do specific things


Gallery of public health Shiny apps
========================================================

There are many examples of Shiny apps presenting public health data.
A good place to start looking for examples is the official gallery:
<https://shiny.rstudio.com/gallery/>


SIH ethnicity
========================================================

<iframe src="https://mirjamallik.shinyapps.io/SIH_ethnicity/" width="900" height="780" style="border: none;"></iframe>

<https://mirjamallik.shinyapps.io/SIH_ethnicity/>

ScotPHO profiles tool
========================================================

<iframe src="https://scotland.shinyapps.io/ScotPHO_profiles_tool/" width="900" height="780" style="border: none;"></iframe>

<https://scotland.shinyapps.io/ScotPHO_profiles_tool/>
<https://github.com/ScotPHO/scotpho-profiles-tool>


Scottish burden of disease
========================================================

<iframe src="https://scotland.shinyapps.io/scotpho-burden-disease/" width="900" height="780" style="border: none;"></iframe>


<https://scotland.shinyapps.io/scotpho-burden-disease/>

End
========================================================

Any questions?

<!-- END -->



