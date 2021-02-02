# UI
# Keaton Wilson & Noah Giebink
# keatonwilson@me.com
# 2021-02-02


# packages ----------------------------------------------------------------

library(shiny)
library(bslib)


# Shiny UI ---------------------------------------------------------------
# Define UI for application that draws a histogram
shinyUI(
    fluidPage(
        theme = bs_theme(bootswatch = 'spacelab'),
        navbarPage(title = "Ecostructure Larval Dispersal",
                   id = "navbar", 
                   

# Front Mapping Panel -----------------------------------------------------

                   tabPanel("Mapping", 
                            value = "tab1", 
                            fluid = TRUE
                       
                   )
                   )
    )
)
