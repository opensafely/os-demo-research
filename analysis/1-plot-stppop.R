
## open log connection to file
sink(here::here("output", "logs", "log-1-plot-stppop.txt"))

## import libraries
library('tidyverse')
library('sf')


## import measures data
df_input <- read_csv(
  here::here("output", "cohorts", "input_1_stppop.csv"), 
  col_types = cols(
    patient_id = col_integer(),
    registered = col_double(), # should be int but it doesn't like it
    died = col_double(), # should be int but it doesn't like it
    stp = col_character(),
    age = col_double(),
    sex = col_character()
  )
)

df_stppop = df_input %>%
  filter(is.na(died)) %>%
  group_by(stp) %>%
  summarise(
    registered = n()
  )

# from https://openprescribing.net/api/1.0/org_location/?format=json&org_type=stp
# not importing directly from URL because no access on the server
sf_stp <- st_read(here::here("lib", "STPshapefile.json"))


sf_stppop <- sf_stp %>% 
  left_join(df_stppop, by = c("ons_code" = "stp"))

plot_stppop <- sf_stppop %>%
ggplot() +
  geom_sf(aes(fill=registered), colour='black') +
  scale_fill_gradient(limits = c(0,NA), low="white", high="blue")+
  labs(
    title="Registered TPP-patients per STP",
    subtitle= "as at 1 January 2020",
    fill = NULL)+
  theme_void()+
  theme(
    legend.position=c(0.1, 0.5)
  )

ggsave(
  plot= plot_stppop, 
  filename="plot_stppop.png", path=here::here("output", "plots"), 
  units = "cm",
  height = 10,
  width = 10
)

## close log connection
sink()


