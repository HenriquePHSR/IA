import pandas as pd
import numpy as np
import tensorflow as tf

def y_columns(dataset, shift, full, target):
    x_Mn = dataset
    x_Mn = x_Mn.set_index(np.arange(len(x_Mn)))
    x_Mn['t_DATE-TIME'] = x_Mn['t_DATE'] + x_Mn['t_TIME']
    x_Mn = x_Mn.drop_duplicates(subset=['t_DATE-TIME'])
    x_Mn = x_Mn.set_index(np.arange(len(x_Mn)))
    x_Mn['t_LAST_Shift'] = x_Mn['t_LAST'].shift(-shift)
    x_Mn['t_TIME_Shift'] = x_Mn['t_TIME'].shift(-shift)
    x_Mn['t_LAST_DELTA'] = x_Mn['t_LAST_Shift'] - x_Mn['t_LAST']
    x_Mn = x_Mn.dropna()

    for index, row in x_Mn.iterrows():
        if row['t_LAST_DELTA'] > target:
            x_Mn.loc[index, 't_POS_up'] = 1
            x_Mn.loc[index, 't_POS_down'] = 0
            x_Mn.loc[index, 't_POS_const'] = 0
        elif row['t_LAST_DELTA'] < -target:
            x_Mn.loc[index, 't_POS_down'] = 1
            x_Mn.loc[index, 't_POS_up'] = 0
            x_Mn.loc[index, 't_POS_const'] = 0
        else:
            x_Mn.loc[index, 't_POS_const'] = 1
            x_Mn.loc[index, 't_POS_up'] = 0
            x_Mn.loc[index, 't_POS_down'] = 0
    if not full:
        x_Mn = x_Mn[x_Mn['t_TIME'] < '14:00']
    x_Mn = x_Mn.set_index(np.arange(len(x_Mn)))
    return x_Mn


def process_dataset(dataset, is_categorical, shift, target, feature_list, x_matrix_size, full):
    x_Mn = y_columns(dataset, shift, full, target)
    if is_categorical:
        y = x_Mn[['t_POS_up', 't_POS_down', 't_POS_const']] #tf.keras.utils.to_categorical(x_Mn[['t_POS_up', 't_POS_down', 't_POS_const']], num_classes=3)
    else:
        y = x_Mn['t_LAST_DELTA']

    x = x_Mn[feature_list]
    x_matrix = []
    y_matrix = y[x_matrix_size:]
    y_matrix = pd.DataFrame(y_matrix)
    y_values_matrix = []

    for index, row in y_matrix.iterrows():
        x_matrix.append(x[index - x_matrix_size:index])
        y_values_matrix.append(row.values)
    x_values_matrix = []
    for element in x_matrix:
        x_values_matrix.append(element.values)
    x_processed = np.array(x_values_matrix)
    y_processed = np.array(y_values_matrix)

    if is_categorical:
        print("Classes summary: ")
        class_lenght(y_processed)
        
        
    return x_Mn, x_processed, y_processed


def class_lenght(y_processed):
    class_count = []
    for i in range(len(y_processed[0])):
        class_count.append(len([y for y in y_processed if y[i]==1]))
    print(class_count)

def under_sample(x_values_matrix, y_values_matrix, us_factor):
    x_processed = []
    y_processed = []
    aux = 0
    for i in range(len(y_values_matrix)):
        if np.array_equal(y_values_matrix[i], np.array([1, 0, 0])):
            x_processed.append(x_values_matrix[i])
            y_processed.append(y_values_matrix[i])
        if np.array_equal(y_values_matrix[i], np.array([0, 1, 0])):
            x_processed.append(x_values_matrix[i])
            y_processed.append(y_values_matrix[i])
        if np.array_equal(y_values_matrix[i], np.array([0, 0, 1])):
            if aux == us_factor:
                x_processed.append(x_values_matrix[i])
                y_processed.append(y_values_matrix[i])
                aux = 0
            else:
                aux += 1
    return np.array(x_processed), np.array(y_processed)

    