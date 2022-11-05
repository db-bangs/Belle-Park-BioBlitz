## Belle Park BioBlitz server.R
##
## Server functions for the R Shiny dashboard
##
## Leaflet map filtered by iNaturalist 'iconic_taxon_name'
##  and day-of-week slider controls
## 
## inat_obs_df.rds created from separate iNaturalist API query
##  via package 'rinat'
## 
## Created by: Donovan Bangs
## Last Updated: 08 June 2022

## Initialize Libraries
library(shiny)
library(shinyWidgets)
library(leaflet)
library(htmltools)

## Set link URLs
github_url <- a("GitHub Repo", href="https://github.com/db-bangs/Belle-Park-BioBlitz", target = "_blank")
belle_park_url <- a("Belle Park Project", href="https://belleparkproject.com/events/bioblitz", target = "_blank")

## Load iNat data RDS
load("inat_obs_df.rds")
sf <- inat_obs_df

sf$observed_on <- as.Date(sf$observed_on)


sf_table <- subset(sf,
                   select = c(
                     observed_on,
                     common_name,
                     scientific_name,
                     iconic_taxon_name,
                     user_login,
                     url,
                     license
                   ))

## Colour Palette
pal <- colorFactor(
    palette = c("Blue", # Actinopterygii
                "Dark Green",  # Amphibia
                "Brown",       # Animalia
                "Black",       # Arachnida
                "deepskyblue3", #Aves
                "goldenrod3",      # Fungi
                "lightcoral",       # Insecta
                "Brown",       # Mammalia
                "darkorange4",       # Mollusca
                "forestgreen", # Plantae
                "Darkgoldenrod3", # Protozoa
                "darkturquoise",       # Reptilia
                "Gray"),       # Unidentified
    domain = sf$iconic_taxon_name)





shinyServer(function(input, output){
  
  filteredData <- reactive({
    sf[sf$iconic_taxon_name %in% input$taxon_name & 
       sf$observed_on >= min(input$dates) &
       sf$observed_on <= max(input$dates),]
  })
    
    
    output$map <- renderLeaflet({
        leaflet(sf) %>% addTiles() %>%
        fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude))
    })
    
    ## An observer to draw the filtered points
    observe({
        leafletProxy("map") %>%
        clearMarkers() %>%
        addCircleMarkers(data = filteredData(),
                         lng = ~longitude, lat = ~latitude,
                         popup = paste0("<p><b>", filteredData()$common_name, "</b><br/>",
                                        "<i>", filteredData()$scientific_name, "</i><br/>",
                                        "<i>", filteredData()$iconic_taxon_name, "</i></p>",
                                        "<p>Observed: ", filteredData()$observed_on, "<br/>",
                                        "User: ", filteredData()$user_login, "<br/>",
                                        "Licence: ", filteredData()$license, "</p",
                                        "<p><img src='", filteredData()$image_url, "' style='width:100%;'/></p>"),
                         color = ~pal(filteredData()$iconic_taxon_name),
                         opacity = 1.0,
                         radius = 5) %>%
        clearControls() %>%
        addLegend(position = "bottomright",
                  pal = pal,
                  values = filteredData()$iconic_taxon_name)
    })
    

    output$table <- renderDataTable(sf_table)
    
    output$belle_park <- renderUI({
      tagList("Belle Park Project:", belle_park_url)
    
    })
    
    output$github <- renderUI({
      tagList("GitHub Repo:", github_url)
    
    })
}
)
