

## import libraries
library('tidyverse')
library('lubridate')

## open log connection to file
sink("log-1-plot-deaths.txt")

## import measures data
data_input <- read_csv(here::here("output", "input_deaths.csv"), col_types = "iDDDdddcc")


data_cleaned <- data_input %>%
  mutate(
    sex = case_when(
      sex=="F" ~ "Female",
      sex=="M" ~ "Male",
      TRUE ~ sex
    ),
  )

death_day <- data_cleaned %>%
  filter(!is.na(date_death)) %>%
  group_by(date_death, death_category, sex) %>%
  summarise(n=n())

plot_deaths <- death_day %>% ungroup() %>%
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
  width=12
)

## close log connection
sink()
