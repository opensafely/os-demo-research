
## open log connection to file
sink(here::here("output", "logs", "log-2-plot-deaths.txt"))


## import libraries
library('tidyverse')

## import measures data
data_input <- read_csv(
  here::here("output", "cohorts", "input_2_deaths.csv"), 
  col_types = cols(
    patient_id = col_integer(),
    registered = col_double(), # should be int but it doesn't like it
    died = col_double(), # should be int but it doesn't like it
    age = col_double(),
    sex = col_character(),
    date_covidany_death = col_date(format="%Y-%m-%d"),
    date_covidunderlying_death = col_date(format="%Y-%m-%d"),
    date_death = col_date(format="%Y-%m-%d"),
    death_category = col_character()

  )
)

data_cleaned <- data_input %>%
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
    time_to_death = if_else(is.na(date_death), as.Date("2020-10-01") - as.Date("2020-01-01"), as.Date(date_death) - as.Date("2020-01-01")),
    event = !is.na(date_death)
  )

death_day <- data_cleaned %>%
  filter(!is.na(date_death)) %>%
  group_by(date_death, death_category, sex) %>%
  summarise(n=n(), .groups="drop")

plot_deaths <- death_day %>%
ggplot() +
  #geom_line(aes(x=date_death, y=n, colour=death_category))+
  geom_bar(aes(x=date_death, y=n, fill=death_category), stat="identity")+
  #directlabels::geom_dl(aes(x=date_death, y=n, colour=death_category, label = death_category), method = "last.qp")+
  facet_grid(cols=vars(sex))+
  labs(x=NULL, y=NULL, fill=NULL, title="Daily deaths")+
  scale_x_date(date_breaks = "1 month", labels = scales::date_format("%Y-%m"))+
  scale_y_continuous(expand = c(0, 0))+
  scale_fill_brewer(palette="Set2")+
  coord_cartesian(clip = 'off') +
  theme_minimal()+
  theme(
    axis.line.x = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )


#not currently needed
#fs::dir_create(here::here("output", "plots"))

ggsave(
  plot= plot_deaths, 
  filename="plot_deaths.png", path=here::here("output", "plots"), 
  units = "cm",
  height = 8,
  width = 12
)


deaths_tte <- survival::survfit(
    survival::Surv(time=time_to_death, event=event) ~ age_group, 
    data = data_cleaned
  ) %>% 
  broom::tidy() %>%
  group_by(strata) %>%
  nest() %>%
  mutate(data = map(data, ~add_row(., time=0, estimate=1, std.error=0, conf.high=1, conf.low=1, .before=1))) %>%
  unnest(data) %>%
  mutate(
    age_group = stringr::str_remove(strata, "age_group="),
    leadtime = lead(time,n=1,default = Inf)
  )

plot_cmldeaths_age <- deaths_tte %>%
  ggplot()+
  geom_step(aes(x=time, y=1-estimate, group=age_group, colour=age_group))+
  geom_rect(aes(xmin=time, xmax= leadtime, ymin=1-conf.high, ymax=1-conf.low, group=age_group, fill=age_group), alpha=0.1, colour=NA)+
  scale_fill_viridis_d(guide=FALSE)+
  scale_colour_viridis_d()+
  labs(x="Days since 1 Jan 2020", y="Death rate", colour="Age",
       title="Cumulative death rate by age group")+
  theme_minimal()+
  theme(
    axis.line.x = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    legend.position = c(0.05, 0.05), legend.justification = c(0,0),
  )

ggsave(
  plot= plot_cmldeaths_age, 
  filename="plot_cmldeaths_age.png", path=here::here("output", "plots"), 
  units = "cm",
  height = 8,
  width = 12
)

## close log connection
sink()
