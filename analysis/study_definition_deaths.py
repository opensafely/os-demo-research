from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv

from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    codelist_from_csv,
    codelist,
    filter_codes_by_category,
    combine_codelists
)

## CODE LISTS
# All codelist are held within the codelist/ folder.
from codelists import *

## STUDY POPULATION
# Defines both the study population and points to the important covariates

index_date = "2020-01-01"
end_date = "2020-10-01"
today = "2020-10-21"


study = StudyDefinition(
        # Configure the expectations framework
    default_expectations={
        "date": {"earliest": index_date, "latest": "today"},
        "rate": "exponential_increase",
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
        """
    ),

    registered = patients.registered_as_of(
        index_date,
        return_expectations={"incidence": 1}
    ),

    died = patients.died_from_any_cause(
		on_or_before=index_date,
		returning="binary_flag",
        return_expectations={"incidence": 0.01}
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
    
    # Registered death, any COVID
    date_covidany_death=patients.with_these_codes_on_death_certificate(
        codes_ICD10_covid,
        between=[index_date, end_date],
        match_only_underlying_cause=False,
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": index_date}},
    ),   
    
    # Registered death, any COVID as underlying cause
    date_covidunderlying_death=patients.with_these_codes_on_death_certificate(
        codes_ICD10_covid,
        between=[index_date, end_date],
        match_only_underlying_cause=True,
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": index_date}},
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
            "alive": "NOT died_any",
            "covid-death": "died_covid",
            "non-covid-death": "died_noncovid",
            "unknown" : "DEFAULT"
        },

        died_covid=patients.with_these_codes_on_death_certificate(
            codes_ICD10_covid,
            returning="binary_flag",
            match_only_underlying_cause=False,
            between=[index_date, end_date],            
        ),
        died_covidunderlying=patients.with_these_codes_on_death_certificate(
            codes_ICD10_covid,
            returning="binary_flag",
            match_only_underlying_cause=True,
            between=[index_date, end_date],            
        ),

        died_any = patients.died_from_any_cause(
		    between=[index_date, end_date],
		    returning="binary_flag",
            return_expectations={"incidence": 0.01}
        ),

        died_noncovid = patients.satisfying(
            """(NOT died_covid) AND died_any""",
            return_expectations={"incidence": 0.15},
        ),

        return_expectations={"category": {"ratios": {"alive": 0.8, "covid-death": 0.1, "non-covid-death": 0.1}}, "incidence": 1},
    ),

    

)