import yaml
import pandas as pd
import pdb
import numpy as np

import utils

def gen_cost_matrix(costos, grid_size):
    # Read costs
    costo_calles = costos['costo_calles']
    costo_eco_pequenas = costos['costo_unidades_economicas_pequenas']
    costo_eco_medianas = costos['costo_unidades_economicas_medianas']
    costo_transporte = costos['costo_transporte']

    # Read interests
    antes = costos['interes_antes']
    despues = costos['interes_despues']
    DROP = ("""DROP TABLE IF EXISTS features.costs_{grid_size}""".format(grid_size=grid_size))
    QUERY = ("""CREATE TABLE features.costs_{grid_size} AS (
                 WITH costos_construccion AS (
                    SELECT cell_id,
                           year,
                           calle_distancia_km * {costo_calles} +
                           unidades_economicas_pequenas_distancia_km * {costo_eco_pequenas} +
                           unidades_economicas_medianas_distancia_km * {costo_eco_medianas} +
                           carretera_distancia_km * {costo_transporte} AS costo_construccion,
                           CASE WHEN zona_urbana_distancia_min = 0
                                THEN 0 ELSE 1 END AS dummy_urbano
                    FROM features.features_{grid_size}
                ) SELECT  cell_id,
                          year,
                           0 as CTN,
                           costo_construccion * dummy_urbano AS CFP,
                           costo_construccion * dummy_urbano * {antes} AS CTP,
                           costo_construccion * dummy_urbano * {despues} AS CFN
                    FROM costos_construccion)""".format(grid_size=grid_size,
                                                       costo_calles=costo_calles,
                                                       costo_eco_pequenas=costo_eco_pequenas,
                                                       costo_eco_medianas=costo_eco_medianas,
                                                       costo_transporte=costo_transporte,
                                                       antes=antes,
                                                       despues=despues))
    db_conn = utils.get_connection().raw_connection()
    cur = db_conn.cursor()
    cur.execute(DROP)
    db_conn.commit()
    cur.execute(QUERY)
    db_conn.commit()

if __name__ == '__main__':
    experiment_path = '../experiment.yaml'
    experiment = utils.read_yaml(experiment_path)
    gen_cost_matrix(experiment['costos'], experiment['grid_size'])
