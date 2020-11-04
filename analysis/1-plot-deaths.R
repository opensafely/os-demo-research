

## import libraries
library('tidyverse')
library('lubridate')
#pacman::p_load("tidyverse","lubridate")

## open log connection to file
sink(here::here("output", "logs", "log-1-plot-deaths.txt"))

#args <- commandArgs(trailingOnly=TRUE)

## import measures data
data_input <- read_csv(here::here("output", "cohorts", "input_deaths.csv"), col_types = "iDDDdddcc")

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
  theme_bw()+
  theme(
    panel.border = element_blank(), 
    axis.line.x = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    strip.background = element_blank(),
    legend.position = c(0.1, 0.9),
    legend.background = element_blank()
    #plot.margin = margin(0, 0, 0, 0, "pt"),
  )



fs::dir_create(here::here("output", "plots"))

ggsave(
  plot= plot_deaths, 
  filename="plot_deaths.png", path=here::here("output", "plots"), 
  units = "cm",
  height = 8,
  width = 12
)


survival::survfit(
  survival::Surv(time=time_to_death, event=event) ~ age_group, 
  data = data_cleaned
) %>%
  survminer::ggsurvplot(
    conf.int = TRUE,
    ggtheme = theme_minimal(), 
    palette = viridis::viridis_pal()(n_distinct(data_cleaned$age_group)),
    xlim = c(0, 300),
    ylim = c(0.95, 1),
    break.x.by = 100
  )

## close log connection
sink()
