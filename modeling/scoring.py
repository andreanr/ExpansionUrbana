import sys
import pdb
import numpy as np
import pandas as pd
import statistics
from costcla.metrics import savings_score, cost_loss
from sklearn import metrics


def generate_binary_at_x(test_predictions, cutoff):
    test_predictions_binary = [1 if x >= cutoff else 0 for x in test_predictions]
    return test_predictions_binary

def confusion_matrix_cost_at_x(test_labels, test_prediction_binary_at_x, test_costs):
    """
    Returns the raw number of a given metric:
        'TP_c' = true positives,
        'TN_c' = true negatives,
        'FP_c' = false positives,
        'FN_c' = false negatives
    """
    urban = test_costs[:,0]
    true_positive = [1 if x == 1 and y == 1 and z > 0 else 0 for (x, y, z) in zip(test_prediction_binary_at_x, test_labels, urban)]
    false_positive = [1 if x == 1 and y == 0 and z > 0 else 0 for (x, y, z) in zip(test_prediction_binary_at_x, test_labels, urban)]
    true_negative = [1 if x == 0 and y == 0 and z > 0 else 0 for (x, y, z) in zip(test_prediction_binary_at_x, test_labels, urban)]
    false_negative = [1 if x == 0 and y == 1 and z > 0 else 0 for (x, y, z) in zip(test_prediction_binary_at_x, test_labels, urban)]

    TP_c = np.sum(true_positive)
    TN_c = np.sum(true_negative)
    FP_c = np.sum(false_positive)
    FN_c = np.sum(false_negative)

    return TP_c, TN_c, FP_c, FN_c


def confusion_matrix_at_x(test_labels, test_prediction_binary_at_x):
    """
    Returns the raw number of a given metric:
        'TP' = true positives,
        'TN' = true negatives,
        'FP' = false positives,
        'FN' = false negatives
    """

    # compute true and false positives and negatives.
    true_positive = [1 if x == 1 and y == 1 else 0 for (x, y) in zip(test_prediction_binary_at_x, test_labels)]
    false_positive = [1 if x == 1 and y == 0 else 0 for (x, y) in zip(test_prediction_binary_at_x, test_labels)]
    true_negative = [1 if x == 0 and y == 0 else 0 for (x, y) in zip(test_prediction_binary_at_x, test_labels)]
    false_negative = [1 if x == 0 and y == 1 else 0 for (x, y) in zip(test_prediction_binary_at_x, test_labels)]

    TP = np.sum(true_positive)
    TN = np.sum(true_negative)
    FP = np.sum(false_positive)
    FN = np.sum(false_negative)

    return TP, TN, FP, FN


def calculate_all_evaluation_metrics(test_label, test_predictions, test_costs):
    """
    Calculate several evaluation metrics using sklearn for a set of
        labels and predictions.
    :param list test_labels: list of true labels for the test data.
    :param list test_predictions: list of risk scores for the test data.
    :return: all_metrics
    :rtype: dict
    """
    all_metrics = dict()
    #test_costs = test_costs.as_matrix()
    # FORMAT FOR DICTIONARY KEY
    # all_metrics["metric|parameter|unit|comment"] OR
    # all_metrics["metric|parameter|unit"] OR
    # all_metrics["metric||comment"] OR
    # all_metrics["metric"]

    cutoffs = [.1, .15, .2, .25, .3, .35, .4, .45, .5, .55,  .6,
               .65, .7, .75, .8, .85, .9]
    for cutoff in cutoffs:
        test_predictions_binary_at_x = generate_binary_at_x(test_predictions, cutoff)
        # confusion matrix
        TP, TN, FP, FN = confusion_matrix_at_x(test_label,  test_predictions_binary_at_x)

        all_metrics["true positives@|{}".format(str(cutoff))] = TP
        all_metrics["true negatives@|{}".format(str(cutoff))] = TN
        all_metrics["false positives@|{}".format(str(cutoff))] = FP
        all_metrics["false negatives@|{}".format(str(cutoff))] = FN
        # precision
        all_metrics["precision@|{}".format(str(cutoff))] = [TP / ((TP + FP) * 1.0) if (TP + FP) > 0 else 'Null'][0]
        # recall
        all_metrics["recall@|{}".format(str(cutoff))] = [TP / ((TP + FN) * 1.0) if (TP + FN)> 0 else 'Null'][0]
        # f1
        all_metrics["f1@|{}".format(str(cutoff))] = [(2* TP) / ((2*TP + FP + FN)*1.0) if (TP + FP + FN) > 0 else 'Null'][0]
        # accuracy
        all_metrics["auc@|{}".format(str(cutoff))] = (TP + TN) / ((TP + TN + FP + FN)*1.0)
        # cost sensity
        all_metrics["savings@|{}".format(str(cutoff))] = savings_score(test_label, test_predictions_binary_at_x, test_costs)
        all_metrics["cost_loss@|{}".format(str(cutoff))] = cost_loss(test_label, test_predictions_binary_at_x, test_costs)

        #Adding only the changes
        TP_c, TN_c, FP_c, FN_c = confusion_matrix_cost_at_x(test_label, test_predictions_binary_at_x, test_costs)
        all_metrics["true positives ch@|{}".format(str(cutoff))] = TP_c
        all_metrics["true negatives ch@|{}".format(str(cutoff))] = TN_c
        all_metrics["false positives ch@|{}".format(str(cutoff))] = FP_c
        all_metrics["false negatives ch@|{}".format(str(cutoff))] = FN_c
        all_metrics["precision ch@|{}".format(str(cutoff))] = [TP_c / ((TP_c + FP_c) * 1.0) if (TP_c + FP_c) > 0 else 'Null'][0]
        all_metrics["recall ch@|{}".format(str(cutoff))] = [TP_c / ((TP_c + FN_c) * 1.0) if (TP_c + FN_c)> 0 else 'Null'][0]
        all_metrics["f1 ch@|{}".format(str(cutoff))] = [(2* TP_c) / ((2*TP_c + FP_c + FN_c)*1.0) if (TP_c + FP_c + FN_c) > 0 else 'Null'][0]
        all_metrics["auc ch@|{}".format(str(cutoff))] = (TP_c + TN_c) / ((TP_c + TN_c + FP_c + FN_c)*1.0)

    return all_metrics

def cv_evaluation_metrics(fold_metrics):

    df_metrics = pd.DataFrame.from_dict(fold_metrics)
    metrics = df_metrics.T.mean(skipna=True).to_dict()
    return metrics
