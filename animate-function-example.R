install.packages("rnaturalearth")
install.packages("countrycode")
install.packages("tidyverse")

library(tidyverse)
library(sf)
library(rnaturalearth)
library(countrycode)
library(gganimate)
library(transformr)

world <- ne_countries(scale = "medium", returnclass = "sf")
eurovision <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-05-17/eurovision.csv')

to_plot <- 
  eurovision |> 
  select(year, artist_country, section, winner) |> 
  mutate(winnings = case_when(
    str_detect(section, "^grand-final$|^final$") & winner == TRUE ~ 1,
    TRUE ~ 0)) |>
  rename(admin = artist_country) |> 
  left_join(world) |> 
  select(year, admin, winnings, geometry) |>
  arrange(year) |> 
  group_by(admin) |> 
  mutate(winnings = lag(cumsum(winnings), default = 0)) |> 
  ungroup()

to_plot |> 
  ggplot() + 
  geom_sf(aes(fill = winnings, geometry = geometry)) +
  coord_sf(xlim = c(-25, 50), ylim = c(30, 80), expand = FALSE) +
  scale_fill_viridis_c(option = 1) + 
  labs(title = "{frame_time}") + 
  transition_time(year)


get_map <- function(y) {
  to_plot |> filter(year == y) %>% 
    ggplot() + 
    geom_sf(aes(fill = winnings, geometry = geometry)) +
    coord_sf(xlim = c(-25, 50), ylim = c(30, 80), expand = FALSE) +
    scale_fill_viridis_c(option = 1, 
                         limits = c(0, 7)
    ) + 
    labs(title = y) 
}

y_list <- to_plot$year %>% sort %>% unique
my_maps <- file.path(getwd(), "image", paste0("m_", seq_along(y_list), ".png"))
for (i in seq_along(y_list)){
  get_map(y = y_list[i])
  ggsave(my_maps[i], width = 4, height = 4)
}


