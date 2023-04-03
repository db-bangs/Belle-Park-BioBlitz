## Belle Park BioBlitz ui.R
##
## User Interface controls for the R Shiny dashboard
##
## Leaflet map filtered by iNaturalist 'iconic_taxon_name'
##  and day-of-week slider controls
##
## Data table of all observations on separate tab
## 
## Created by: Donovan Bangs
## Last Updated: 08 June 2022

library(shiny)
library(shinyWidgets)
library(leaflet)
library(DT)

load("inat_obs_df.rds")

taxons <- levels(inat_obs_df$iconic_taxon_name)

#### Shiny UI ####
shinyUI(fluidPage(
    titlePanel("Belle Park BioBlitz - May 23-29 2022"),
    
    
    sidebarLayout(
        
      sidebarPanel(
        
        ### Header ####
        h1("Belle Park BioBlitz"),
        
        ### Introduction Text ####
        p(HTML(paste0(
          "The ",
          tags$a("Belle Park Project", 
                 href="https://belleparkproject.com/events/bioblitz",
                 target = "_blank"),
          " undertook an iNaturalist BioBlitz the week of
                            May 23-29, 2022. This map and table show all 560 observations of 325 unique
                            species by 32 observers recorded during this week."
        ))),
        
        p("Use the slider to control the range of dates and the dropdown menu to control
                          the taxons to display in the map. Add and remove taxons to explore the observations."),
        p("Use the search bar on the table to filter observations by observer, species,
                           taxon, or license."),
        
        ### Controls ####
        #### Dates Slider ####
        sliderInput("dates",
                    "Dates:",
                    min = as.Date("2022-05-23","%Y-%m-%d"),
                    max = as.Date("2022-05-29","%Y-%m-%d"),
                    value= c(as.Date("2022-05-23"),
                             as.Date("2022-05-29")),
                    timeFormat="%A-%d"),
        #### Taxon Picker Input ####
        pickerInput("taxon_name", 
                    label = "Taxon Name:",
                    choices = taxons,
                    selected = taxons,
                    options = list(`actions-box` = TRUE), multiple = T),
        br(),
        
        ### Credit Text ####
        p(HTML(paste0(
          "This dashboard was developed by Donovan Bangs using R Shiny. See the ",
          tags$a("GitHub Repo",
                 href="https://github.com/db-bangs/Belle-Park-BioBlitz",
                 target = "_blank"),
          " for code and more details."
        )))
        
      ),
      
      
      mainPanel(
        tabsetPanel(
          tabPanel("Belle Park Map",
                   leafletOutput("belle.map", height = "640px")),
          tabPanel("Belle Park Table",
                   br(),
                   h4("Table of All Observations:"),
                   p("Filter by Participant, Species, Taxon, or License", align = "right"),
                   dataTableOutput("belle.table")))
        
      )

        )
        
        
    )
)
