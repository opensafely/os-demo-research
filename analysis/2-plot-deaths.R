
## open log connection to file
sink(here::here("output", "logs", "log-2-plot-deaths.txt"))


## import libraries
library('tidyverse')

## import measures data
df_input <- read_csv(
  here::here("output", "cohorts", "input_2_deaths.csv"), 
  col_types = cols(
    patient_id = col_integer(),
    age = col_double(),
    sex = col_character(),
    date_death = col_date(format="%Y-%m-%d"),
    death_category = col_character()

  )
)

df_cleaned <- df_input %>%
  mutate(
    sex = case_when(
      sex=="F" ~ "Female",
      sex=="M" ~ "Male",
      TRUE ~ sex
    ),
    age_group = cut(
      age,
      breaks = c(0,18,40,50,60,70,80, Inf),
      #labels = ,
      dig.lab = 2,
    ),
    week_death = date_death,
    time_to_coviddeath = if_else(is.na(date_death), as.Date("2020-10-01") - as.Date("2020-01-01"), as.Date(date_death) - as.Date("2020-01-01")),
    event = (!is.na(date_death)) & (death_category == "covid-death")
  )

df_deathsperday <- df_cleaned %>%
  filter(!is.na(date_death)) %>%
  group_by(date_death, death_category, sex, age_group) %>%
  summarise(n=n(), .groups="drop")

plot_deaths <- df_deathsperday %>%
ggplot() +
  geom_area(aes(x=date_death, y=n, fill=age_group), stat="identity", colour="transparent") +
  facet_grid(cols=vars(sex), rows=vars(death_category))+
  labs(x=NULL, y=NULL, fill=NULL, title="Daily deaths, covid versus non-covid")+
  scale_x_date(date_breaks = "1 month", labels = scales::date_format("%Y-%m"))+
  scale_y_continuous(expand = c(0, 0))+
  scale_fill_viridis_d()+#(palette="Set2")+
  coord_cartesian(clip = 'off') +
  theme_minimal()+
  theme(
    axis.line.x = element_line(colour = "black"),
    axis.text.x = element_text(angle = 70, vjust = 1, hjust=1),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )

ggsave(
  plot= plot_deaths, 
  filename="plot_deaths.png", path=here::here("output", "plots"), 
  units = "cm",
  height = 10,
  width = 15
)


deaths_tte <- survival::survfit(
    survival::Surv(time=time_to_coviddeath, event=event) ~ age_group, 
    data = df_cleaned %>% filter()
  ) %>% 
  broom::tidy() %>%
  group_by(strata) %>%
  nest() %>%
  mutate(data = map(data, ~add_row(., time=0, estimate=1, std.error=0, conf.high=1, conf.low=1, .before=1))) %>%
  unnest(data) %>%
  mutate(
    age_group = stringr::str_remove(strata, "age_group="),
    leadtime = lead(time, n=1, default = NA)
  )

plot_cmlcoviddeaths_age <- deaths_tte %>%
  ggplot()+
  geom_step(aes(x=time, y=1-estimate, group=age_group, colour=age_group))+
  geom_rect(aes(xmin=time, xmax= leadtime, ymin=1-conf.high, ymax=1-conf.low, group=age_group, fill=age_group), alpha=0.1, colour=NA)+
  scale_fill_viridis_d(guide=FALSE)+
  scale_colour_viridis_d()+
  scale_y_continuous(expand = c(0,0))+
  labs(x="Days since 1 Jan 2020", y="Death rate", colour="Age",
       title="Cumulative covid death rate",
       subtitle = "by age group")+
  theme_minimal()+
  theme(
    axis.line.x = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )

ggsave(
  plot= plot_cmlcoviddeaths_age, 
  filename="plot_cmlcoviddeaths_age.png", path=here::here("output", "plots"), 
  units = "cm",
  height = 10,
  width = 15
)

## close log connection
sink()
