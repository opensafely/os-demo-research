## LIBRARIES

# cohort extractor
from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    codelist_from_csv,
    codelist,
    filter_codes_by_category,
    combine_codelists
)

# dictionary of STP codes (for dummy data)
from dictionaries import dict_stp

## STUDY POPULATION
# Defines both the study population and points to the important covariates

start_date = "2020-01-01"
end_date = "2020-10-01"

study = StudyDefinition(
        # Configure the expectations framework
    default_expectations={
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "uniform",
        "incidence": 0.2,
    },

    # This line defines the study population
    population = patients.all(),

    registered = patients.registered_as_of(
        start_date,
        return_expectations={"incidence": 1}
    ),

    died = patients.died_from_any_cause(
		on_or_before=start_date,
		returning="binary_flag",
        return_expectations={"incidence": 0.01}
    ),

    stp = patients.registered_practice_as_of(
        start_date,
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": dict_stp },
        },
    ),

    age = patients.age_as_of(
        start_date,
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),

    sex = patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),
)