from cohortextractor import (
    codelist,
    codelist_from_csv,
)


## measurement codes

codes_cholesterol = codelist_from_csv(
    "codelists-local/cholesterol-measurement.csv", system="ctv3", column="id"
)

codes_inr = codelist_from_csv(
    "codelists-local/international-normalised-ratio-measurement.csv", system="ctv3", column="id"
)
