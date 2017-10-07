import pandas as pd
import json
import pdb
import numpy as np
import yaml
from sqlalchemy import create_engine
from sqlalchemy.pool import NullPool


def get_engine(db, user, host, port, passwd):
    """
    Get SQLalchemy engine using credentials.
    Input:
    db: database name
    user: Username
    host: Hostname of the database server
    port: Port number
    passwd: Password for the database
    """

    url = 'postgresql://{user}:{passwd}@{host}:{port}/{db}'.format(
        user=user, passwd=passwd, host=host, port=port, db=db)
    engine = create_engine(url, poolclass=NullPool)
    return engine


def get_connection(config_file_name="../config.yaml"):
    """
    Sets up database connection from config file.
    Input:
    config_file_name: File containing host, user,
                      password, database, port, which are the
                      credentials for the PostgreSQL database
    """

    with open(config_file_name, 'r') as f:
        vals = yaml.load(f)

    return get_engine(vals['db']['database'], vals['db']['user'],
                      vals['db']['host'], vals['db']['port'],
                      vals['db']['password'])

def read_yaml(config_file_name):
    """
    This function reads the config file
    Args:
       config_file_name (str): name of the config file
    """
    with open(config_file_name, 'r') as f:
        config = yaml.load(f)
    return config

def get_features(experiment):
    return [x for x in experiment['Features'] if experiment['Features'][x]==True]


def get_data(years,
             features,
             grid_size,
             features_table_prefix,
             labels_table_prefix,
             intersect_percent):

    features_table_name = '{}_{}'.format(features_table_prefix,
                                         grid_size)
    labels_table_name = '{}_{}_{}'.format(labels_table_prefix,
                                          intersect_percent,
                                          grid_size)

    query = ("""SELECT cell_id, {features}, label::bool,
                CFP, CFN, CTP, CTN
                FROM  features.{features_table_name}
                JOIN features.{labels_table_name}
                USING (cell_id, year)
                JOIN {grid_size}.grid
                USING (cell_id)
                JOIN preprocess.buffer_2010
                ON st_intersects(cell, buffer_geom)
                LEFT JOIN features.costs_{grid_size}
                USING (cell_id, year)
                 WHERE year in ({years})"""
                .format(features=", ".join(features),
                        features_table_name=features_table_name,
                        labels_table_name=labels_table_name,
                        grid_size=grid_size,
                        years=",".join(["'{0}'".format(x) for x in years])))

    db_engine = get_connection()
    data = pd.read_sql(query, db_engine)
    data.set_index('cell_id', inplace=True)
    costs = np.array(data[['cfp','cfn', 'ctp', 'ctn']])
    return data.index, np.array(data.ix[:, ~data.columns.isin(['label', 'ctp', 'ctn', 'cfp', 'cfn'])]), np.array(data['label']), costs


def store_train(timestamp,
                model,
                parameters,
                features,
                years_train,
                grid_size,
                intersect_percent,
                costs,
                model_comment):

    query = (""" INSERT INTO results.models (run_time,
                                             model_type,
                                             model_parameters,
                                             features,
                                             year_train,
                                             grid_size,
                                             intersect_percent,
                                             costs,
                                             model_comment)
                VALUES ('{run_time}'::TIMESTAMP,
                        '{model_type}',
                        '{model_parameters}',
                         ARRAY{features},
                         '{year_train}',
                         '{grid_size}',
                         {intersect_percent},
                         '{costs}'::jsonb,
                         '{model_comment}') """.format(run_time=timestamp,
                                                      model_type=model,
                                                      model_parameters=json.dumps(parameters),
                                                      features=features,
                                                      year_train="-".join(years_train),
                                                      grid_size=grid_size,
                                                      intersect_percent=intersect_percent,
                                                      costs=json.dumps(costs),
                                                      model_comment=model_comment))
    db_conn = get_connection().raw_connection()
    cur = db_conn.cursor()
    cur.execute(query)
    db_conn.commit()

    # return model_id
    query_model_id = """SELECT max(model_id) as id from results.models"""
    db_engine = get_connection()
    model_id = pd.read_sql(query_model_id, db_engine)
    return model_id['id'].iloc[0]


def store_importances(model_id, features, importances):

    # Create pandas db of features importance
    dataframe_for_insert = pd.DataFrame( {  "model_id": model_id,
                                            "feature": features,
                                            "feature_importance": importances})

    dataframe_for_insert['rank_abs'] = dataframe_for_insert['feature_importance'].rank(method='dense',
                                                                                       ascending=False)
    db_engine = get_connection()
    dataframe_for_insert.to_sql("feature_importances",
                                 db_engine,
                                 if_exists="append",
                                 schema="results",
                                 index=False )
    return True


def store_predictions(model_id,
                      year_test,
                      cell_id,
                      scores,
                      test_y):

    dataframe_for_insert = pd.DataFrame( {"model_id": model_id,
                                          "year_test": year_test,
                                          "cell_id": cell_id,
                                          "score": scores,
                                          "label": test_y})
    dataframe_for_insert['score'] = dataframe_for_insert['score'].apply(lambda x: round(x,5))

    db_engine = get_connection()
    dataframe_for_insert.to_sql("predictions",
                                db_engine,
                                if_exists="append",
                                schema="results",
                                index=False )
    return True


def store_evaluations(model_id, year_test, metrics):
    db_conn = get_connection().raw_connection()
    for key in metrics:
        evaluation = metrics[key]
        metric = key.split('|')[0]
        try:
            metric_cutoff = key.split('|')[1]
            if metric_cutoff == '':
                metric_cutoff.replace('', None)
            else:
                pass
        except:
            metric_cutoff = None
        try:
            if np.isnan(evaluation):
                evaluation = 'Null'
        except:
            pass

        # store
        if metric_cutoff is None:
            metric_cutoff = 'Null'
        query = ("""INSERT INTO results.evaluations(model_id,
                                                    year_test,
                                                    metric,
                                                    cutoff,
                                                    value)
                   VALUES( {0}, {1}, '{2}', {3}, {4}) """
                   .format( model_id,
                            "-".join(year_test),
                            metric,
                            metric_cutoff,
                            evaluation ))

        db_conn.cursor().execute(query)
        db_conn.commit()
