from cohortextractor import codelist_from_csv

# measurement codes

codes_ICD10_covid = codelist_from_csv(
    "codelists/opensafely-covid-identification.csv", system="icd10", column="icd10_code"
)

codes_cholesterol = codelist_from_csv(
    "codelists-local/cholesterol-measurement.csv", system="ctv3", column="id"
)

codes_inr = codelist_from_csv(
    "codelists-local/international-normalised-ratio-measurement.csv",
    system="ctv3",
    column="id",
)
