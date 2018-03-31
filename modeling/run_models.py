import yaml
import pandas as pd
import datetime
import pdb
from itertools import product
import numpy as np
import psycopg2
from sklearn.model_selection import KFold
from sklearn import (svm, ensemble, tree,
                     linear_model, neighbors, naive_bayes)
from costcla.models import (CostSensitiveRandomForestClassifier,
                            CostSensitiveLogisticRegression)

import utils
import scoring

def gen_models_to_run(experiment):
    # get values
    years_train = experiment['years_train']
    features = utils.get_features(experiment)
    grid_size = experiment['grid_size']
    #n_folds = experiment['n_folds']
    costs = experiment['costos']
    features_table_prefix = experiment['features_table_name']
    labels_table_prefix = experiment['labels_table_name']
    intersect_percent = experiment['intersect_percent']

    # get data
    train_index, train_x, train_y, train_costs = utils.get_data(years_train,
                                            features,
                                            grid_size,
                                            features_table_prefix,
                                            labels_table_prefix,
                                            intersect_percent)

    # Magic Loop
    for model in experiment["model"]:
        print('Using model: {}'.format(model))
        parameter_names = sorted(experiment["parameters"][model])
        parameter_values = [experiment["parameters"][model][p] for p in parameter_names]
        all_params = product(*parameter_values)

        for each_param in all_params:
            print('With parameters: {}'.format(each_param))
            print('-----------------------------')
            timestamp = datetime.datetime.now()
            parameters = {name: value for name, value
                              in zip(parameter_names, each_param)}
            # Train
            print('training')
            modelobj, importances = train(train_x,
                                          train_y,
                                          train_costs,
                                          model,
                                          parameters,
                                          2)
            # Store model
            model_id = utils.store_train(timestamp,
                                         model,
                                         parameters,
                                         features,
                                         years_train,
                                         grid_size,
                                         intersect_percent,
                                         costs,
                                         experiment['model_comment'])

            print('Model id: {}'.format(model_id))
            utils.store_importances(model_id, features, importances)

            for year_test in experiment['year_tests']:
                print('testing')
                print('For year {}'.format(year_test))
                test_index, test_x, test_y, test_costs = utils.get_data([year_test],
                                                                        features,
                                                                        grid_size,
                                                                        features_table_prefix,
                                                                        labels_table_prefix,
                                                                        intersect_percent)

                scores = predict_model(modelobj, test_x)
                utils.store_predictions(model_id,
                                        year_test,
                                        test_index,
                                        scores,
                                        test_y)
                print('scoring')
                metrics = scoring.calculate_all_evaluation_metrics(test_y.tolist(),
                                                                   scores,
                                                                   test_costs)



                utils.store_evaluations(model_id, [year_test], metrics)

                print('Cool')
                print('--------------------------')
                print('--------------------------')

        print('Done!')


def get_feature_importances(model):
    """
    Get feature importances (from scikit-learn) of trained model.
    Args:
        model: Trained model
    Returns:
        Feature importances, or failing that, None
    """
    ##TODO return a dict
    try:
        return model.feature_importances_
    except:
        pass
    try:
        # Must be 1D for feature importance plot
        if len(model.coef_) <= 1:
            return model.coef_[0]
        else:
            return model.coef_
    except:
        pass
    return None


def train(train_x, train_y, train_costs, model, parameters, n_cores):
    modelobj = define_model(model, parameters, n_cores)
    if 'CostSensitive' in model:
        train_x = train_x
        train_costs = train_costs
        train_y = train_y
        modelobj.fit(train_x, train_y, train_costs)
    else:
        modelobj.fit(train_x, train_y)

    importances = get_feature_importances(modelobj)
    return modelobj, importances


def predict_model(modelobj, test):
    predicted_score = modelobj.predict_proba(test)[:, 1]
    return predicted_score


def define_model(model, parameters, n_cores):
    if model == "RandomForest":
        return ensemble.RandomForestClassifier(
            n_estimators=parameters['n_estimators'],
            max_features=parameters['max_features'],
            criterion=parameters['criterion'],
            max_depth=parameters['max_depth'],
            min_samples_split=parameters['min_samples_split'],
            random_state=parameters['random_state'],
            n_jobs=n_cores)

    elif model == 'SVM':
        return svm.SVC(C=parameters['C_reg'],
                       kernel=parameters['kernel'],
                       probability=True)

    elif model == 'LogisticRegression':
        return linear_model.LogisticRegression(
            C=parameters['C_reg'],
            random_state=parameters['random_state'],
            penalty=parameters['penalty'])

    elif model == 'AdaBoost':
        return ensemble.AdaBoostClassifier(
            learning_rate=parameters['learning_rate'],
            algorithm=parameters['algorithm'],
            n_estimators=parameters['n_estimators'])

    elif model == 'ExtraTrees':
        return ensemble.ExtraTreesClassifier(
            n_estimators=parameters['n_estimators'],
            max_features=parameters['max_features'],
            criterion=parameters['criterion'],
            max_depth=parameters['max_depth'],
            min_samples_split=parameters['min_samples_split'],
            random_state=parameters['random_state'],
            n_jobs=n_cores)

    elif model == 'GradientBoostingClassifier':
        return ensemble.GradientBoostingClassifier(
            n_estimators=parameters['n_estimators'],
            learning_rate=parameters['learning_rate'],
            subsample=parameters['subsample'],
            max_depth=parameters['max_depth'])

    elif model == 'GaussianNB':
        return naive_bayes.GaussianNB()

    elif model == 'DecisionTreeClassifier':
        return tree.DecisionTreeClassifier(
            max_features=parameters['max_features'],
            criterion=parameters['criterion'],
            max_depth=parameters['max_depth'],
            min_samples_split=parameters['min_samples_split'])

    elif model == 'SGDClassifier':
        return linear_model.SGDClassifier(
            loss=parameters['loss'],
            penalty=parameters['penalty'],
            n_jobs=n_cores)

    elif model == 'KNeighborsClassifier':
        return neighbors.KNeighborsClassifier(
            n_neighbors=parameters['n_neighbors'],
            weights=parameters['weights'],
            algorithm=parameters['algorithm'],
            n_jobs=n_cores)

    elif model == 'CostSensitiveRandomForest':
        return CostSensitiveRandomForestClassifier(
            n_estimators=parameters['n_estimators'],
            combination=parameters['combination'],
            max_features=parameters['max_features'],
            pruned=parameters['pruned'])

    elif model == 'CostSensitiveLogisticRegression':
        return CostSensitiveLogisticRegression(
            C=parameters['C'],
            max_iter=parameters['max_iter'],
            random_state=parameters['random_state'],
            tol=parameters['tol'],
            solver=parameters['solver'])

    else:
        raise ConfigError("Unsupported model {}".format(model))

if __name__ == '__main__':
    experiment_path = '../experiment.yaml'
    experiment = utils.read_yaml(experiment_path)
    gen_models_to_run(experiment)
