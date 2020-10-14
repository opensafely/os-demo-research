

measures_dict = dict(
    # dictionary of dictionaries, listing all measure variables and the grouping variables
    cholesterol = dict(
        label = "Cholesterol",
        groups = dict(
            allpatients = dict(   
                label = "overall",
                measure_args = dict(
                    id = "cholesterol_overall", # this should be "{key of the level 1 dict}_{key of the level 3 dict}"
                    numerator = "cholesterol_numer",
                    denominator="cholesterol_denom",
                    group_by = "allpatients"
                ),
            ),
            practice = dict(
                label = "by practice",
                measure_args = dict(
                    id = "cholesterol_practice",
                    numerator = "cholesterol_numer",
                    denominator="cholesterol_denom",
                    group_by = "practice"
                ),
            ),
            stp = dict(
                label = "by STP",
                measure_args = dict(
                    id = "cholesterol_practice",
                    numerator = "cholesterol_numer",
                    denominator="cholesterol_denom",
                    group_by = "stp"
                ),
            ),
        ),
    ),
)
