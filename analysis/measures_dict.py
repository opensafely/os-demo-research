import json


measures_dict = dict(
    # dictionary of dictionaries, listing all measure variables and the grouping variables
    cholesterol = dict(
        label = "Cholesterol",
        groups = dict(
            allpatients = dict(   
                label = "overall",
                measure_args = dict(
                    id = "cholesterol_overall", # this should be "{key of the level 1 dict}_{key of the level 3 dict}"
                    numerator = "cholesterol",
                    denominator="population",
                    group_by = "allpatients"
                ),
            ),
            practice = dict(
                label = "by practice",
                measure_args = dict(
                    id = "cholesterol_practice",
                    numerator = "cholesterol",
                    denominator="population",
                    group_by = "practice"
                ),
            ),
            stp = dict(
                label = "by STP",
                measure_args = dict(
                    id = "cholesterol_stp",
                    numerator = "cholesterol",
                    denominator="population",
                    group_by = "stp"
                ),
            ),
        ),
    ),

    inr = dict(
        label = "INR",
        groups = dict(
            allpatients = dict(   
                label = "overall",
                measure_args = dict(
                    id = "inr_overall", # this should be "{key of the level 1 dict}_{key of the level 3 dict}"
                    numerator = "inr",
                    denominator="population",
                    group_by = "allpatients"
                ),
            ),
            practice = dict(
                label = "by practice",
                measure_args = dict(
                    id = "inr_practice",
                    numerator = "inr",
                    denominator="population",
                    group_by = "practice"
                ),
            ),
            stp = dict(
                label = "by STP",
                measure_args = dict(
                    id = "inr_stp",
                    numerator = "inr",
                    denominator="population",
                    group_by = "stp"
                ),
            ),
        ),
    ),
)


with open('../measures_dict.json', 'w') as fp:
    json.dump(measures_dict, fp, indent=4)