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

## CODELISTS
# All codelist are held within the codelist/ folder.
from codelists import *

## STUDY POPULATION
# Defines both the study population and points to the important covariates

index_date = "2020-01-01"
end_date = "2020-09-30"


study = StudyDefinition(
        # Configure the expectations framework
    default_expectations={
        "date": {"earliest": index_date, "latest": end_date},
        "rate": "uniform",
        "incidence": 0.2,
    },

    index_date = index_date,

    # This line defines the study population
    population=patients.satisfying(
        """
        (sex = 'F' OR sex = 'M') AND
        (age >= 18 AND age < 120) AND
        (NOT died) AND
        (registered)
        """,
        
        registered = patients.registered_as_of(
            index_date,
            #return_expectations={"incidence": 1}
        ),

        died = patients.died_from_any_cause(
		    on_or_before=index_date,
		    returning="binary_flag",
            #return_expectations={"incidence": 0.01}
        ),
    ),

    age=patients.age_as_of(
        index_date,
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),

    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),
    
    #Registered death, all deaths any cause
    date_death=patients.died_from_any_cause(
        between=[index_date, end_date],
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": index_date}},
    ),

    death_category = patients.categorised_as(
        {
            "covid-death": "died_covid",
            "non-covid-death": "(NOT died_covid) AND died_any",
            "" : "DEFAULT"
        },

        died_covid=patients.with_these_codes_on_death_certificate(
            codes_ICD10_covid,
            returning="binary_flag",
            match_only_underlying_cause=False,
            between=[index_date, end_date],
        ),

        died_any = patients.died_from_any_cause(
		    between=[index_date, end_date],
		    returning="binary_flag",
            return_expectations={"incidence": 0.01}
        ),

        return_expectations={"category": {"ratios": {"": 0.8, "covid-death": 0.1, "non-covid-death": 0.1}}, "incidence": 1},
    ),

    

)
