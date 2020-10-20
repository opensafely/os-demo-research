


#plot measures ------------------------------------------------------------


measures <- read_rds(here::here("output", "collected_measures.rds"))

quibble <- function(x, q = c(0.25, 0.5, 0.75)) {
  tibble("{{ x }}" := quantile(x, q), "{{ x }}_q" := q)
}

measures_plots <- measures %>% 
  mutate(
    data_quantiles = map(data, ~ (.) %>% group_by(date) %>% summarise(quibble(value, seq(0,1,0.1)))),
    plot_by = pmap(lst( group, data, var_label, label), 
                  function(group, data, var_label, label){
                    data %>% mutate(value_10000 = value*10000) %>%
                    ggplot()+
                      geom_line(aes_string(x="date", y="value_10000", group=group), alpha=0.1, colour='blue')+
                      labs(
                        x="Date", y=NULL, 
                        title=glue::glue("{var_label} measurement per 10,000 patients"),
                        subtitle = label
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
    plot_quantiles = pmap(lst( group, data_quantiles, var_label, label), 
                  function(group, data_quantiles, var_label, label){
                    data_quantiles %>% mutate(value_10000 = value*10000) %>%
                      ggplot()+
                      geom_line(aes(x=date, y=value_10000, group=value_q, linetype=value_q==0.5, size=value_q==0.5), colour='blue')+
                      scale_linetype_manual(breaks=c(TRUE, FALSE), values=c("dashed", "dotted"), guide=FALSE)+
                      scale_size_manual(breaks=c(TRUE, FALSE), values=c(1, 0.7), guide=FALSE)+
                      labs(
                        x="Date", y=NULL, 
                        title=glue::glue("{var_label} measurement per 10,000 patients"),
                        subtitle = glue::glue("Quantiles {label}")
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


measures_plots %>%
  transmute(
    plot = plot_by,
    units = "cm",
    height = 8,
    width=12, 
    limitsize=FALSE,
    filename = str_c("plot_by_", id, ".png"),
    path = here::here("output", "plots"),
  ) %>%
  pwalk(ggsave)

