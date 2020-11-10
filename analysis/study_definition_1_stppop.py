## LIBRARIES

# cohort extractor
from cohortextractor import (
    StudyDefinition,
    patients
)

# dictionary of STP codes (for dummy data)
from dictionaries import dict_stp

## STUDY POPULATION
# Defines both the study population and points to the important covariates

index_date = "2020-01-01"

study = StudyDefinition(

#    default_expectations={
#        "date": {"earliest": index_date, "latest": "today"}, # date range for simulated dates
#        "rate": "uniform", # occurrance rate for simulated dates
#        "incidence": 1, # proportion where data is not missing, or where code is not present
#    },

    # This line defines the study population
    population = patients.registered_as_of(
        index_date,
    ),

    stp = patients.registered_practice_as_of(
        index_date,
        returning="stp_code",
        return_expectations={
            "incidence": 0.95,
            "category": {"ratios": dict_stp},
        },
    ),
)
