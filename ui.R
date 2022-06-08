#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(DT)

load("inat_obs_df.rds")

taxons <- levels(inat_obs_df$iconic_taxon_name)

#### Shiny UI ####
shinyUI(fluidPage(
    titlePanel("Belle Park BioBlitz - May 23-29 2022"),
    
    
    sidebarLayout(
        
        sidebarPanel(
          
          p("The Belle Park Project undertook an iNaturalist BioBlitz the week of
            May 23-29, 2022. This map and table show all 560 observations of 325 unique
            species by 32 observers recorded during this week."),
          
          p("Use the slider to control the range of dates and the checkboxes to control
            the taxons to display in the map."),
          p("Use the search bar on the table to filter observations by observer, species,
            taxon, or license."),
          
          sliderInput("dates",
                      "Dates:",
                      min = as.Date("2022-05-23","%Y-%m-%d"),
                      max = as.Date("2022-05-29","%Y-%m-%d"),
                      value= c(as.Date("2022-05-23"),
                               as.Date("2022-05-29")),
                      timeFormat="%A-%d"),
            
          checkboxGroupInput("taxon_name", 
                              label = "Taxon Name:",
                              choices = taxons,
                              selected = taxons),
          br(),
          p("This dashboard was developed by Donovan Bangs using R Shiny. See the
            GitHub Repo linked below for more details."),
          
          uiOutput("belle_park"),
          uiOutput("github")

        ),
        
        
        mainPanel(
          tabsetPanel(
            tabPanel("Map",
                     leafletOutput("map", height = "640px")),
            tabPanel("Table",
                     br(),
                     h4("Table of All Observations:"),
                     p("Search by User, Species, Taxon, or License", align = "right"),
                     dataTableOutput("table")))
                     
          )

        )
        
        
    )
)
