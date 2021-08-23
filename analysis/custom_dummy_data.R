# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
## create dummy from scratch which respects existing relationships better

## This script helps to demonstrate the value of the `dummy_data_file` option of a cohortextractor action
## It is less helpful for demonstrating how to generate dummy data -- there are more general options!

## see https://docs.opensafely.org/study-def-expectations/#providing-your-own-dummy-data

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## select population size
population_size <- 10000

index_date <- as.Date("2019-01-01")
end_date <- as.Date("2019-12-31")

sex <- sample(c("M", "F"), size=population_size, replace=TRUE, prob=c(0.49, 0.51))
age <- as.integer(rnorm(population_size, mean=65+(sex=="F")*5, sd=10))
diabetes <-rbinom(population_size, size=1, prob=plogis(-1 + age*0.002 + (sex=='F')*-0.2))
hosp_admission_count  <- rpois(population_size, lambda = exp(-2.5 + age*0.03 + (sex=='F')*-0.2 + diabetes*1))
unplanned_admission_day <- round(rexp(population_size, rate = exp(-5 + age*0.01 + (age^2)*0.0001 + diabetes*1.5 + hosp_admission_count*1)/365))
unplanned_admission_date <- index_date + unplanned_admission_day
unplanned_admission_date <- dplyr::if_else(unplanned_admission_date>end_date, "", as.character(unplanned_admission_date))


dataset <- data.frame(
  patient_id = 1:population_size,
  sex,
  age,
  diabetes,
  hosp_admission_count,
  unplanned_admission_date
)

## save custom dataset to file
fs::dir_create(here::here("output", "cohorts"))
write.csv(
  dataset,
  file = here::here("output", "cohorts", "custom_dummy_data.csv"),
  row.names = FALSE
)

