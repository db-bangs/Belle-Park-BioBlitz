## Belle Island Bioblitz - Data Preparation
## This script creates the inat_obs_df dataframe used by the Shiny app
##
## Querying data from iNaturalist is performed through the get_inat_obs() function
## from the package rinat

## Initialize
library(rinat)
library(sf)
library(dplyr)
library(tmap)
library(leaflet)


## Load the conflicted package and set preferences
library(conflicted)
conflict_prefer("filter", "dplyr", quiet = TRUE)
conflict_prefer("count", "dplyr", quiet = TRUE)
conflict_prefer("select", "dplyr", quiet = TRUE)
conflict_prefer("arrange", "dplyr", quiet = TRUE)



# Bounding Box
sw <- c(44.24732617607908, -76.4857988368853)
se <- c(44.24662820519569, -76.46566209212664)
ne <- c(44.25190155787377, -76.46537339327705)
nw <- c(44.25501623280483, -76.4834351150543)

ymin <- 44.24732617607908
xmax <- -76.4834351150543
ymax <- 44.25501623280483
xmin <- -76.46537339327705


## Query May 23
df_23 <- get_inat_obs(bounds = c(ymin, xmax, ymax, xmin), 
                            taxon_name = NULL,
                            year = 2022,
                            month = 05,
                            day = 23,
                            maxresults = 1000)

## Query May 24
df_24 <- get_inat_obs(bounds = c(ymin, xmax, ymax, xmin), 
                      taxon_name = NULL,
                      year = 2022,
                      month = 05,
                      day = 24,
                      maxresults = 1000)

## Query May 25
df_25 <- get_inat_obs(bounds = c(ymin, xmax, ymax, xmin), 
                      taxon_name = NULL,
                      year = 2022,
                      month = 05,
                      day = 25,
                      maxresults = 1000)

## Query May 26
df_26 <- get_inat_obs(bounds = c(ymin, xmax, ymax, xmin), 
                      taxon_name = NULL,
                      year = 2022,
                      month = 05,
                      day = 26,
                      maxresults = 1000)

## Query May 27
df_27 <- get_inat_obs(bounds = c(ymin, xmax, ymax, xmin), 
                      taxon_name = NULL,
                      year = 2022,
                      month = 05,
                      day = 27,
                      maxresults = 1000)

## Query May 28
df_28 <- get_inat_obs(bounds = c(ymin, xmax, ymax, xmin), 
                      taxon_name = NULL,
                      year = 2022,
                      month = 05,
                      day = 28,
                      maxresults = 1000)

## Query May 26
df_29 <- get_inat_obs(bounds = c(ymin, xmax, ymax, xmin), 
                      taxon_name = NULL,
                      year = 2022,
                      month = 05,
                      day = 29,
                      maxresults = 1000)

inat_obs_df <- rbind(df_23, df_24, df_25, df_26, df_27, df_28, df_29)



#### Iconic Taxon Name ####
load("C:/Belle Island/RShiny/Belle_Island_BioBlitz/inat_obs_df.rds")
## Empty Iconic Taxon Name to 'Unidentified'
for (i in 1:nrow(inat_obs_df)) {
  if (inat_obs_df$iconic_taxon_name[i] == "") {
    inat_obs_df$iconic_taxon_name[i] = "Unidentified"
  }
}


## Relevel Iconic Taxon Name
inat_obs_df$iconic_taxon_name <- as.factor(inat_obs_df$iconic_taxon_name)


## Convert dataframe to sf object - for leaflet mapping in this script
## The dataframe will be loaded into the Shiny app
inat_obs_sf <- inat_obs_df %>% 
  select(longitude, latitude, observed_on, common_name, 
         scientific_name, image_url, user_login, iconic_taxon_name) %>% 
  st_as_sf(coords=c("longitude", "latitude"), crs=4326)


## HTML Popup:
inat_obs_popup_sf <- inat_obs_sf %>% 
  mutate(popup_html = paste0("<p><b>", common_name, "</b><br/>",
                             "<i>", scientific_name, "</i><br/>",
                             "<i>", iconic_taxon_name, "</i></p>",
                             "<p>Observed: ", observed_on, "<br/>",
                             "User: ", user_login, "<br/>",
                             "Licence: ", inat_obs_df$license, "</p",
                             "<p><img src='", image_url, "' style='width:100%;'/></p>")
  )

#### Save Data to .rds ####
save(inat_obs_popup_sf, file = "inat_obs_popup_sf.rds")
save(inat_obs_df, file = "inat_obs_df.rds")

## Map the Results:

## Colour Palette
pal <- colorFactor(
  palette = c("Red", "Green", "Blue",
              "Yellow", "Purple", "cornflowerblue",
              "Orange", "coral4", "Black",
              "DarkGreen", "Darkgoldenrod3", "olivedrab"),
  domain = inat_obs_popup_sf$iconic_taxon_name)


htmltools::p("Belle Park Bioblitz",
             htmltools::br(),
             inat_obs_popup_sf$datetime %>% 
               as.Date() %>% 
               range(na.rm = TRUE) %>% 
               paste(collapse = " to "),
             style = "font-weight:bold; font-size:110%;")

leaflet() %>% 
  addTiles() %>% 
  addCircleMarkers(data = inat_obs_popup_sf,
                   popup = ~popup_html,
                   color = ~pal(iconic_taxon_name),
                   radius = 5)
