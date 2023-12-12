rm(list = ls())

library(tidyverse)

acc <- read_csv("data/ACC_AUX_1982-2021.csv.gz") # accident-level
per <- read_csv("data/PER_AUX_1982-2021.csv.gz") # person-level

################################################################################
wi.acc <- acc |> filter(STATE == 55) # wisconsin accident-level

# wisconsin person-level
per.wi <- per |>
  # add state and time-of-day codes from the accident level-data
  inner_join(wi.acc %>% select(ST_CASE, YEAR, COUNTY, A_TOD))

wi.annual.counts <- per.wi |>
  # replace numeric codes with text labels
  mutate(
    A_PERINJ = case_when(
      A_PERINJ == 1 ~ "Fatal",
      A_PERINJ == 6 ~ "Survivor",
      TRUE ~ as.character(A_PERINJ)),
    A_PTYPE = case_when(
      A_PTYPE == 1 ~ "Driver",
      A_PTYPE == 2 ~ "Occupant",
      A_PTYPE == 3 ~ "Pedestrian",
      A_PTYPE == 4 ~ "Pedalcyclist",
      A_PTYPE == 5 ~ "Other/Unknown NonOccupant",
      TRUE ~ as.character(A_PTYPE)
    ),
    A_TOD = case_when(
      A_TOD == 1 ~ "Daytime",
      A_TOD == 2 ~ "Nighttime",
      A_TOD == 3 ~ "Unknown"
    )
  ) |>
  # just keep fatalities with known time-of-day and mode status
  filter(A_PERINJ == "Fatal",
         A_PTYPE != "Other/Unknown NonOccupant",
         A_TOD != "Unknown") |>
  # summarise by year, mode, and time-of-day
  group_by(YEAR, A_PTYPE, A_TOD) |>
  summarise(count = n())

wi.plot <- ggplot(wi.annual.counts,
                  aes(YEAR, count, color = A_TOD)) +
  geom_point(alpha = 0.25) +
  geom_smooth(se = F) +
  labs(title = "Traffic Fatalities by Time of Day and Travel Mode, 1982-2021",
       subtitle = "Wisconsin, note that y-axes are independently scaled",
       caption = "Source: National Highway Traffic Safety Administration (NHTSA) Fatality Analysis Reporting System (FARS)",
       x = NULL,
       y = "fatalities") +
  facet_wrap(facets = ~A_PTYPE, scales = "free_y") +
  theme_minimal() +
  theme(plot.title.position = "plot",
        plot.title = element_text(face = "bold", size = 16),
        panel.background = element_rect(colour = "linen", fill = "linen"),
        strip.background = element_rect(colour = "linen", fill = "linen"),
        strip.text = element_text(face = "bold"),
        legend.position = c(0.92,0.95),
        legend.title = element_blank(),
        legend.background = element_rect(colour = "black"))
ggsave("plots/WI_by_year-tod-mode.svg", width = 8, height = 5, plot = wi.plot)

################################################################################
# same table, but for national data
usa.annual.counts <- per |>
  inner_join(acc |> select(ST_CASE, YEAR, COUNTY, A_TOD)) |>
  select(ST_CASE, YEAR, COUNTY, A_PERINJ, A_PTYPE, A_TOD) |>
  mutate(
    A_PERINJ = case_when(
      A_PERINJ == 1 ~ "Fatal",
      A_PERINJ == 6 ~ "Survivor",
      TRUE ~ as.character(A_PERINJ)),
    A_PTYPE = case_when(
      A_PTYPE == 1 ~ "Driver",
      A_PTYPE == 2 ~ "Occupant",
      A_PTYPE == 3 ~ "Pedestrian",
      A_PTYPE == 4 ~ "Pedalcyclist",
      A_PTYPE == 5 ~ "Other/Unknown NonOccupant",
      TRUE ~ as.character(A_PTYPE)
    ),
    A_TOD = case_when(
      A_TOD == 1 ~ "Daytime",
      A_TOD == 2 ~ "Nighttime",
      A_TOD == 3 ~ "Unknown"
    )
  ) |>
  filter(A_PERINJ == "Fatal",
         A_PTYPE != "Other/Unknown NonOccupant",
         A_TOD != "Unknown") |>
  group_by(YEAR, A_PTYPE, A_TOD) |>
  summarise(count = n())

usa.plot <- ggplot(usa.annual.counts, aes(YEAR, count, color = A_TOD)) +
  geom_point(alpha = 0.25) +
  geom_smooth(se = F) +
  labs(title = "Traffic Fatalities by Time of Day and Travel Mode, 1982-2021",
       subtitle = "United States, note that y-axes are independently scaled",
       caption = "Source: National Highway Traffic Safety Administration (NHTSA) Fatality Analysis Reporting System (FARS)",
       x = NULL,
       y = "fatalities") +
  facet_wrap(facets = ~A_PTYPE, scales = "free_y") +
  theme_minimal() +
  theme(plot.title.position = "plot",
        plot.title = element_text(face = "bold", size = 16),
        panel.background = element_rect(colour = "linen", fill = "linen"),
        strip.background = element_rect(colour = "linen", fill = "linen"),
        strip.text = element_text(face = "bold"),
        legend.position = c(0.92,0.95),
        legend.title = element_blank(),
        legend.background = element_rect(colour = "black"))
ggsave("plots/USA_by_year-tod-mode.svg", width = 8, height = 5, plot = usa.plot)
