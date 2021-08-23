# LIBRARIES

# cohort extractor
from cohortextractor import StudyDefinition, patients, codelist_from_csv

# CODELISTS
# All codelist are held within the codelist/ folder.
diabetes_codelist = codelist_from_csv(
    "codelists/opensafely-diabetes.csv", system="ctv3", column="CTV3ID"
)

# set the index date
index_date = "2019-01-01"

# STUDY POPULATION

study = StudyDefinition(
    default_expectations={
        "date": {
            "earliest": index_date,
            "latest": "today",
        },  # date range for simulated dates
        "rate": "uniform",
        "incidence": 1,
    },
    
    index_date = index_date,
    
    # This line defines the study population
    population=patients.satisfying(
        "registered AND NOT has_died AND has_1year_fu",
        registered=patients.registered_as_of(
            index_date,
        ),
        has_died=patients.died_from_any_cause(
            on_or_before=index_date,
            returning="binary_flag",
        ),
        has_1year_fu=patients.registered_with_one_practice_between(
            start_date="index_date - 1 year",
            end_date="index_date",
        )
    ),
    
    age=patients.age_as_of( 
        index_date,
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
            "incidence" : 1
        },
    ),
    
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
            "incidence": 1,
        }
    ),
      
    diabetes=patients.with_these_clinical_events(
        diabetes_codelist,
        returning="binary_flag",
        on_or_before="index_date",
        return_expectations={"incidence": 0.01},
    ),
  
    hosp_admission_count=patients.admitted_to_hospital(
        returning="number_of_matches_in_period",
        between=["index_date - 1 year", "index_date - 1 day"],
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 0.7}
        },
    ),
  
    unplanned_admission_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"],
        on_or_after="index_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": index_date, "latest" : "2019-12-31"},
            "rate": "uniform",
            "incidence": 0.30,
        },
   ),

)
