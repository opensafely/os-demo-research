
## open log connection to file
sink(here::here("output", "logs", "log-1-plot-stppop.txt"))

## import libraries
library('tidyverse')
library('sf')


## import data
df_input <- read_csv(
  here::here("output", "cohorts", "input_1_stppop.csv"), 
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

plot_stppop <- sf_stppop %>%
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

ggsave(
  plot= plot_stppop, 
  filename="plot_stppop.png", path=here::here("output", "plots"), 
  units = "cm",
  height = 10,
  width = 10
)

## close log connection
sink()


