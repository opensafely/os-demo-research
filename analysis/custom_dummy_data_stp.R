# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
## create dummy from scratch which respects existing relationships better

## This script helps to demonstrate the value of the `dummy_data_file` option of a cohortextractor action
## It is less helpful for demonstrating how to generate dummy data -- there are more general options!

## see https://docs.opensafely.org/study-def-expectations/#providing-your-own-dummy-data

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## import libraries

library('tidyverse')


## select population size
population_size <- 10000


## import STP codes from file
df_stps <- read_csv(here::here("lib","STPs.csv")) %>%
  rename(stp=stp_id)

## define which STPs have high (3), moderate (2), low (1), or no (0) representation in TPP

df_weights <- df_stps %>%
  mutate(
    stp_weight = case_when(
      stp %in% c("E54000005", "E54000049", "E54000027", "E54000026") ~ 3,
      stp %in% c("E54000009", "E54000006", "E54000015", "E54000024",
                     "E54000014", "E54000040", "E54000033", "E54000022",
                     "E54000012", "E54000021", "E54000025", "E54000041",
                     "E54000037", "E54000023", "E54000013", "E54000020",
                     "E54000042", "E54000017", "E54000043") ~ 2,
      stp %in% c("E54000044", "E54000035", "E54000010",
                     "E54000029", "E54000008", "E54000007",
                     "E54000036", "E54000016") ~ 1,
      TRUE ~ 0
    ),
    n_registered = rmultinom(1, size=population_size, prob=stp_weight)[,1]
  )

## create counts
df_custominput <- df_weights %>%
  uncount(
    weights=n_registered,
    .id="patient_id"
  ) %>%
  select(-stp_weight)


## save custom dataset to file
fs::dir_create(here::here("output", "cohorts"))
write_csv(df_custominput, path = here::here("output", "cohorts", "custom_dummy_data_stp.csv"))

