#!/usr/bin/env python

import pandas as pd
import json
import sys

def parse_csv_to_json(csv_path, output_path):
    # Load CSV into a pandas DataFrame
    df = pd.read_csv(csv_path)

    # Initialize an empty list to hold the JSON output
    json_output = []

    # Iterate over the DataFrame rows
    for index, row in df.iterrows():
        # Add the RH label to the JSON object
        json_output.append({
            "name": f"Right {row['Label Name']}",
            "label": str(row['RH Label']),
            "voxel_value": row['RH Label'],
            "r": 0,
            "g": 0,
            "b": 0
        })
        # Add the LH label to the JSON object
        json_output.append({
            "name": f"Left {row['Label Name']}",
            "label": str(row['LH Labels']),
            "voxel_value": row['LH Labels'],
            "r": 0,
            "g": 0,
            "b": 0
        })

    # Save JSON to the output path
    with open(output_path, 'w') as json_file:
        json.dump(json_output, json_file, indent=4)

# Parse inputs
in_csv_path = sys.argv[1]
out_json_path = sys.argv[2]

# Generate JSON from the specified CSV
json_result = parse_csv_to_json(in_csv_path, out_json_path)

