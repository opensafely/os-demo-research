## import libraries

library('tidyverse')

## import data
df_input <- read_csv(
  here::here("output", "cohorts", "input_1_stppop.csv"),
  col_types = cols(
    patient_id = col_integer(),
    stp = col_character()
  )
)


df_stppop = df_input %>% count(stp, name='registered')

plot_stppop_bar <- df_stppop %>%
  mutate(
    name = forcats::fct_reorder(stp, registered, median, .desc=FALSE)
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

# create directory where output will be saved
fs::dir_create(here::here("output", "plots"))

# save plot
ggsave(
  plot= plot_stppop_bar,
  filename="plot_stppop_bar.png", path=here::here("output", "plots"),
  units = "cm",
  height = 15,
  width = 15
)


plot_stppop_bar

