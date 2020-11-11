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
         index_date,
         returning = "pseudo_id",
         return_expectations={
             "rate": "universal",
             "int": {"distribution": "normal", "mean": 100, "stddev": 20}
         },
    ),

    stp = patients.registered_practice_as_of(
        index_date,
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"STP1": 0.3, "STP2": 0.3, "STP3": 0.4}},
        },
    ),

     region = patients.registered_practice_as_of(
         index_date,
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


    allpatients = patients.satisfying("""age>=0""", return_expectations={"incidence": 1}),

    cholesterol = patients.with_these_clinical_events(
        codes_cholesterol,
        returning = "number_of_episodes",
        between = ["index_date", "index_date + 1 month"],
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "normal", "mean": 2, "stddev": 0.5}
        },
    ),

    inr = patients.with_these_clinical_events(
        codes_inr,
        returning = "number_of_episodes",
        between = ["index_date", "index_date + 1 month"],
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "normal", "mean": 2, "stddev": 0.5}
        },
    ),
)


measures = [
    Measure(
        id="cholesterol_overall",
        numerator="cholesterol",
        denominator="population",
        group_by="allpatients"
    ),
    Measure(
        id="cholesterol_practice",
        numerator="cholesterol",
        denominator="population",
        group_by="practice"
    ),
    Measure(
        id="cholesterol_stp",
        numerator="cholesterol",
        denominator="population",
        group_by="stp"
    ),
    Measure(
        id="inr_overall",
        numerator="inr",
        denominator="population",
        group_by="allpatients"
    ),
    Measure(
        id="inr_practice",
        numerator="inr",
        denominator="population",
        group_by="practice"
    ),
    Measure(
        id="inr_stp",
        numerator="inr",
        denominator="population",
        group_by="stp"
    ),
]

