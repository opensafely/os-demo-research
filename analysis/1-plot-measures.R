## open log connection to file
sink(here::here("output", "logs","log-1-plot-measures.txt"))


## import libraries
library('tidyverse')

# create measures look-up
md_tbl <- tibble(
  measure = c("cholesterol", "cholesterol", "cholesterol", "inr", "inr", "inr"),
  measure_label = c("Cholesterol", "Cholesterol", "Cholesterol", "INR", "INR", "INR"),
  by = c("overall", "practice", "stp", "overall", "practice", "stp"),
  by_label = c("overall", "by practice", "by STP", "overall", "by practice", "by STP"),
  id = paste0(measure, "_", by),
  numerator = measure,
  denominator = "population",
  group_by = c("allpatients", "practice", "stp", "allpatients", "practice", "stp"),
)

## import measures data from look-up
measures <- md_tbl %>%
  mutate(
    data = map(id, ~read_csv(here::here("output", "measures", glue::glue("measure_{.}.csv")))),
  )


quibble <- function(x, q = c(0.25, 0.5, 0.75)) {
  ## function that takes a vector and returns a tibble of its quantiles
  tibble("{{ x }}" := quantile(x, q), "{{ x }}_q" := q)
}

## generate plots for each measure within the data frame
measures_plots <- measures %>% 
  mutate(
    data_quantiles = map(data, ~ (.) %>% group_by(date) %>% summarise(quibble(value, seq(0,1,0.1)))),
    plot_by = pmap(lst( group_by, data, measure_label, by_label), 
                  function(group_by, data, measure_label, by_label){
                    data %>% mutate(value_10000 = value*10000) %>%
                    ggplot()+
                      geom_line(aes_string(x="date", y="value_10000", group=group_by), alpha=0.1, colour='blue')+
                      labs(
                        x="Date", y=NULL, 
                        title=glue::glue("{measure_label} measurement per 10,000 patients"),
                        subtitle = by_label
                      )+
                      theme_bw()+
                      theme(
                        panel.border = element_blank(), 
                        axis.line.x = element_line(colour = "black"),
                        panel.grid.major.x = element_blank(),
                        panel.grid.minor.x = element_blank(),
                      )
                  }
    ),
    plot_quantiles = pmap(lst( group_by, data_quantiles, measure_label, by_label), 
                  function(group_by, data_quantiles, measure_label, by_label){
                    data_quantiles %>% mutate(value_10000 = value*10000) %>%
                      ggplot()+
                      geom_line(aes(x=date, y=value_10000, group=value_q, linetype=value_q==0.5, size=value_q==0.5), colour='blue')+
                      scale_linetype_manual(breaks=c(TRUE, FALSE), values=c("dashed", "dotted"), guide=FALSE)+
                      scale_size_manual(breaks=c(TRUE, FALSE), values=c(1, 0.7), guide=FALSE)+
                      labs(
                        x="Date", y=NULL, 
                        title=glue::glue("{measure_label} measurement per 10,000 patients"),
                        subtitle = glue::glue("Quantiles {by_label}")
                      )+
                      theme_bw()+
                      theme(
                        panel.border = element_blank(), 
                        axis.line.x = element_line(colour = "black"),
                        panel.grid.major.x = element_blank(),
                        panel.grid.minor.x = element_blank(),
                        #axis.line.y = element_blank(),
                      )
                  }
    )
  )


fs::dir_create(here::here("output", "plots"))

## plot the charts (by variable)
measures_plots %>%
  transmute(
    plot = plot_by,
    units = "cm",
    height = 8,
    width=12, 
    limitsize=FALSE,
    filename = str_c("plot_each_", id, ".png"),
    path = here::here("output", "plots"),
  ) %>%
  pwalk(ggsave)


## plot the charts (by quantile)
measures_plots %>%
  transmute(
    plot = plot_quantiles,
    units = "cm",
    height = 8,
    width=12, 
    limitsize=FALSE,
    filename = str_c("plot_quantiles_", id, ".png"),
    path = here::here("output", "plots"),
  ) %>%
  pwalk(ggsave)


## close log connection
sink()
