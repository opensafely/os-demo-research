from cohortextractor import (
    codelist,
    codelist_from_csv,
)


## measurement codes

codes_cholesterol = codelist_from_csv(
    "codelists/cholesterol-measurement.csv", system="ctv3", column="CTV3ID"
)
