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

# import utility functions from lib folder
# from lib.measures_dict import measures_dict

## STUDY POPULATION
# Defines both the study population and points to the important covariates

index_date = "2020-02-01"
date_end = "2020-09-01"
today = "2020-09-21"


study = StudyDefinition(
        # Configure the expectations framework
    default_expectations={
        "date": {"earliest": index_date, "latest": "today"},
        "rate": "exponential_increase",
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

    died = patients.satisfying(
        """dead_ONS""",
        dead_ONS = patients.died_from_any_cause(
		    on_or_before=index_date,
		    returning="binary_flag"
	    ),
        return_expectations={"incidence": 0.01}
    ),

    registered = patients.registered_as_of(
        index_date,
        return_expectations={"incidence": 0.99}
    ),

    ### geographic /administrative groups

    practice = patients.registered_practice_as_of(
         "2020-02-01",
         returning="pseudo_id",
         return_expectations={
             "rate": "universal",
             "category": {
                 "ratios": {
                     "practice1": 0.1,
                     "practice2": 0.1,
                     "practice3": 0.1,
                     "practice4": 0.1,
                     "practice5": 0.1,
                     "practice6": 0.1,
                     "practice7": 0.2,
                     "practice8": 0.2,
                 },
             },
         },
    ),

    ## https://github.com/ebmdatalab/tpp-sql-notebook/issues/54
    stp = patients.registered_practice_as_of(
        "2020-02-01",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"STP1": 0.3, "STP2": 0.3, "STP3": 0.4}},
        },
    ),

     region = patients.registered_practice_as_of(
         "2020-02-01",
         returning="nuts1_region_name",
         return_expectations={
             "rate": "universal",
             "category": {
                 "ratios": {
                     "North East": 0.1,
                     "North West": 0.1,
                     "Yorkshire and the Humber": 0.1,
                     "East Midlands": 0.1,
                     "West Midlands": 0.1,
                     "East of England": 0.1,
                     "London": 0.2,
                     "South East": 0.2,
                 },
             },
         },
    ),


    allpatients=patients.satisfying("""age>=0""", return_expectations={"incidence": 1}),

    cholesterol = patients.with_these_clinical_events(
        codes_cholesterol,
        returning = "number_of_episodes",
        between = ["index_date", "index_date + 1 month"],
        return_expectations={"incidence": 0.90}
    ),
)
