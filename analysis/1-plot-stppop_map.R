## import libraries

library('tidyverse')
library('sf')


## import data
df_input <- read_csv(
  here::here("output", "cohorts", "input_1_stppop_map.csv"),
  col_types = cols(
    patient_id = col_integer(),
    stp = col_character()
  )
)

# from https://openprescribing.net/api/1.0/org_location/?format=json&org_type=stp
# not importing directly from URL because no access on the server
sf_stp <- st_read(here::here("lib", "STPshapefile.json"))


df_stppop = df_input %>% count(stp, name='registered')

sf_stppop <- sf_stp %>%
  left_join(df_stppop, by = c("ons_code" = "stp")) %>%
  mutate(registered = if_else(!is.na(registered), registered, 0L))

plot_stppop_map <- sf_stppop %>%
ggplot() +
  geom_sf(aes(fill=registered), colour='black') +
  scale_fill_gradient(limits = c(0,NA), low="white", high="blue")+
  labs(
    title="TPP-registered patients per STP",
    subtitle= "as at 1 January 2020",
    fill = NULL)+
  theme_void()+
  theme(
    legend.position=c(0.1, 0.5)
  )

# create directory where output will be saved
fs::dir_create(here::here("output", "plots"))

# save plot
ggsave(
  plot= plot_stppop_map,
  filename="plot_stppop_map.png", path=here::here("output", "plots"),
  units = "cm",
  height = 10,
  width = 10
)



plot_stppop_bar <- sf_stppop %>%
  mutate(
    name = forcats::fct_reorder(name, registered, median, .desc=FALSE)
  ) %>%
  ggplot() +
  geom_col(aes(x=registered/1000000, y=name, fill=registered), colour='black') +
  scale_fill_gradient(limits = c(0,NA), low="white", high="blue", guide=FALSE)+
  labs(
    title="TPP-registered patients per STP",
    subtitle= "as at 1 January 2020",
    y=NULL,
    x="Registered patients\n(million)",
    fill = NULL)+
  theme_minimal()+
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    plot.title.position = "plot",
    plot.caption.position =  "plot"
  )


ggsave(
  plot= plot_stppop_bar,
  filename="plot_stppop_bar_names.png", path=here::here("output", "plots"),
  units = "cm",
  height = 15,
  width = 15
)


plot_stppop_bar

