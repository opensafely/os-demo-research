
library('tidyverse')
library('jsonlite')


md_list <- jsonlite::fromJSON(here::here("lib","measures_dict.json"), simplifyVector = FALSE, flatten=FALSE)
md_tbl <- md_list %>%
  enframe(name="measure", value="dictionary") %>%
  unnest_wider(dictionary) %>% 
  unnest_longer(groups, values_to="list", indices_to="group") %>% rename(var_label=label) %>% 
  unnest_wider(list)  %>% 
  unnest_wider(measure_args)

measures <- md_tbl$id %>% map(~read_csv(here::here("output",glue::glue("measure_{.}.csv"))))

data <- measures[[2]]


q_vec <- c(0, 0.1, 0.25, 0.5, 0.75, 0.9, 1)

quibble2 <- function(x, q = c(0.25, 0.5, 0.75)) {
  tibble("{{ x }}" := quantile(x, q), "{{ x }}_q" := q)
}

quantiles <- data %>% 
  group_by(date) %>% 
  summarise(quibble2(value, q_vec))


ggplot(data)+
  geom_line(aes(x=date, y=value, group=practice), alpha=0.1)+
  labs(x="Month", y="Cholesterol measurement / 10,000 patients")
  theme_bw()+
  theme(
    
  )