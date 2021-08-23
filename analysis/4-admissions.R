## import libraries

library('tidyverse')
library('survminer')
library('survival')

index_date = as.Date("2019-01-01")
end_date = as.Date("2019-12-31")

## import data
df_input <- read_csv(
  here::here("output", "cohorts", "input_4_admissions.csv"),
  col_types = cols(
    patient_id = col_integer(),
    sex = col_character(),
    age = col_double(),
    diabetes= col_double(),
    hosp_admission_count = col_integer(),
    unplanned_admission_date = col_date()
  )
) %>%
mutate(
  previous_admissions = cut(hosp_admission_count, c(0,1,2, Inf), right=FALSE, labels=c("0", "1", "2+")),
  time_to_admission = if_else(is.na(unplanned_admission_date), end_date - index_date, unplanned_admission_date - index_date),
  admitted = !is.na(time_to_admission)
)


# create directory where output will be saved
fs::dir_create(here::here("output", "plots"))


# admission rate by diabetes status

surv_diabetes <-
survfit(
  Surv(time=time_to_admission, event=admitted) ~ diabetes,
  data = df_input
) %>%
  ggsurvplot(
    conf.int = TRUE,
    ggtheme = theme_minimal(),
    xlim = c(0, 320),
    break.x.by = 100,
    palette = "Set2",
    #legend = "left"
    legend.title="",
    font.legend = 10
  )

# save plot
ggsave(
  plot= surv_diabetes$plot,
  filename="plot_admissions_by_diabetes.png", path=here::here("output", "plots"),
  units = "cm",
  height = 15,
  width = 15
)

# admission rate by number of previous admissions

surv_previous <-
  survfit(
    Surv(time=time_to_admission, event=admitted) ~ previous_admissions,
    data = df_input
  ) %>%
  ggsurvplot(
    conf.int = TRUE,
    ggtheme = theme_minimal(),
    xlim = c(0, 320),
    break.x.by = 100,
    palette = "Set2",
    #legend = "left"
    legend.title="",
    font.legend = 10
  )

# save plot
ggsave(
  plot= surv_previous$plot,
  filename="plot_admissions_by_previous.png", path=here::here("output", "plots"),
  units = "cm",
  height = 15,
  width = 15
)
