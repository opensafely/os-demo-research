## open log connection to file
sink("log-0-input.txt")


## import libraries
library('tidyverse')
library('jsonlite')

## import measures dictionary and refactor into tibble
md_list <- jsonlite::fromJSON(here::here("lib","measures_dict.json"), simplifyVector = FALSE, flatten=FALSE)
md_tbl <- md_list %>%
  enframe(name="measure", value="dictionary") %>%
  unnest_wider(dictionary) %>% 
  unnest_longer(groups, values_to="list", indices_to="group") %>% rename(var_label=label) %>% 
  unnest_wider(list)  %>% 
  unnest_wider(measure_args)

## import measures data
measures <- md_tbl %>%
  mutate(
    data = map(id, ~read_csv(here::here("output",glue::glue("measure_{.}.csv")))),
    plot_q = map()
  )

## save to file
write_rds(measures, here::here("output", "collected_measures.rds"), compress="xz")



## close log connection
sink()