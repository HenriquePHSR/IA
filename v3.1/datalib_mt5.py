import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import sqlite3
import math
from sklearn.preprocessing import MinMaxScaler

# turns metatrader candle and ticks .csv files into a single .sql database with one table each (should rename .csv to .txt)
def mt5_data_handle(db_output, ticks_id_list, candle_id_list):
    conn = sqlite3.connect(db_output + '.sqlite')
    cur = conn.cursor()
    print('current in: ' + db_output)
    if db_output == 'currency_data_chunk':
        aux = 'y'
    else:
        aux = input('new will delete currents tables.\n'
            'new set (y/n)? >>> ')
    if aux == 'y':
        #print('deleting existing database and creating a new one...')
        cur.execute('DROP TABLE IF EXISTS market_data_candle')
        cur.execute('CREATE TABLE market_data_candle('
                'DATE TEXT,'
                'TIME TEXT,'
                'OPEN FLOAT,'
                'HIGH FLOAT,'
                'LOW FLOAT,'
                'CLOSE FLOAT,'
                'TICKVOL INTEGER,'
                'VOL INTEGER,'
                'SPREAD INTEGER'
                ')')
        cur.execute('DROP TABLE IF EXISTS market_data_ticks')
        cur.execute('CREATE TABLE market_data_ticks('
                't_DATE TEXT,'
                't_TIME TEXT,'
                't_SEC TEXT,'
                't_BID FLOAT,'
                't_ASK FLOAT,'
                't_LAST FLOAT,'
                't_VOLUME FLOAT,'
                't_TYPE INTEGER,'
                'iAC FLOAT,'
                'iAD FLOAT,'
                'iADX FLOAT,'
                'iADXWilder FLOAT,'
                'iAlligator FLOAT,'
                'iAMA FLOAT,'
                'iAO FLOAT,'
                'iATR FLOAT,'
                'iBearsPower FLOAT,'
                'iBands FLOAT,'
                'iBullsPower FLOAT,'
                'iCCI FLOAT,'
                'iChaikin FLOAT,'
                'iDEMA FLOAT,'
                'iDeMarker FLOAT,'
                'iEnvelopes FLOAT,'
                'iForce FLOAT,'
                'iFractals FLOAT,'
                'iFrAMA FLOAT,'
                'iIchimoku FLOAT,'
                'iBWMFI FLOAT,'
                'iMomentum FLOAT,'
                'iMFI FLOAT,'
                'iMA FLOAT,'
                'iOsMA FLOAT,'
                'iMACD FLOAT,'
                'iOBV FLOAT,'
                'iSAR FLOAT,'
                'iRSI FLOAT,'
                'iRVI FLOAT,'
                'iStdDEV FLOAT,'
                'iStochastic FLOAT,'
                'iTEMA FLOAT,'
                'iTriX FLOAT,'
                'iWPR FLOAT,'
                'iVIDyA FLOAT,'
                'iVolumes FLOAT'
                ')')
    fh_ticks_list = []
    for ticks_id in ticks_id_list:
        fh_ticks_list.append(ticks_id + '.txt')
    for item in fh_ticks_list:
        fh_ticks = open(item, 'r')
        for line in fh_ticks:
            line = line.replace('\x00', '')
            line = line.replace('ÿþ', '')
            line = line.replace('\n', '')
            pieces = line.split(',')
            if pieces[0] == "":
                continue
            
            indic = pieces[-1].split(';')
            pieces[-1] = indic[0]
            indic = indic[1:]
            if pieces[0] == 'Time':continue
            if pieces[0] == '': continue
            try:
                if pieces[5] == 'Sell':
                    pieces[5] = 1
                else:
                    pieces[5] = 0
            except:
                continue
            try:
                pieces[0] = pieces[0].split()
            except:
                continue
            
            time = pieces[0][1].split(':')
            time[0] = str(time[0]) + ':' + str(time[1])
            command = "INSERT INTO market_data_ticks(t_DATE, t_TIME,t_SEC, t_BID, t_ASK, t_LAST, t_VOLUME, t_TYPE, iAC, iAD, iADX, iADXWilder, iAlligator, iAMA, iAO, iATR, iBearsPower, iBands, iBullsPower, iCCI, iChaikin, iDEMA, iDeMarker, iEnvelopes, iForce, iFractals, iFrAMA, iIchimoku, iBWMFI, iMomentum, iMFI, iMA, iOsMA, iMACD, iOBV, iSAR, iRSI, iRVI, iStdDEV, iStochastic, iTEMA, iTriX, iWPR, iVIDyA, iVolumes) VALUES('%s', '%s','%s', %f, %f, %f, %f, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f)" % (
                str(pieces[0][0]), str(time[0]),str(time[2]), float(pieces[1]), float(pieces[2]),
                float(pieces[3]), float(pieces[4]),
                int(pieces[5]), float(indic[0]), float(indic[1]),float(indic[2]),float(indic[3]),float(indic[4]),float(indic[5]),float(indic[6]),float(indic[7]),float(indic[8]),float(indic[9]),float(indic[10]),float(indic[11]),float(indic[12]),float(indic[13]),float(indic[14]),float(indic[15]),float(indic[16]),float(indic[17]),float(indic[18]),float(indic[19]),float(indic[20]),float(indic[21]),float(indic[22]),float(indic[23]),float(indic[24]),float(indic[25]),float(indic[26]),float(indic[27]),float(indic[28]),float(indic[29]),float(indic[30]),float(indic[31]),float(indic[32]),float(indic[33]),float(indic[34]),float(indic[35]),float(indic[36])
                )
            command = command.replace('inf', '0.0')
            cur.execute(command)
        fh_ticks.close()
    fh_candle_list = []
    for candle_id in candle_id_list:
        fh_candle_list.append(candle_id + '.txt')
    for item in fh_candle_list:
        fh_candle = open(item, 'r')
        for line in fh_candle:
            temp = line.split('2019')
            for x in temp:
                if x.startswith('<'): continue
                pieces = x.split()
                try:
                    command = "INSERT INTO market_data_candle(DATE, TIME, OPEN, HIGH, LOW, CLOSE, TICKVOL, VOL, SPREAD) VALUES('%s', '%s', %f, %f, %f, %f, %d, %d, %d)" % (
                        '2019' + str(pieces[0]), str(pieces[1]), float(pieces[2]), float(pieces[3]), float(pieces[4]),
                        float(pieces[5]), int(pieces[6]), int(pieces[7]), int(pieces[8])
                    )
                    cur.execute(command)
                    conn.commit()
                except:
                    continue
    conn.commit()
    conn.close()
    fh_candle.close()
    #print(db_output + ' has change')

# acess a table create by mt5_data_handle and return it in a dataframe
def request_table(database_id, table_id):
    conn = sqlite3.connect(database_id + '.sqlite')
    command = 'SELECT * From ' + table_id
    query = conn.execute('SELECT * FROM ' + table_id)
    cols = [column[0] for column in query.description]
    dataset = pd.DataFrame.from_records(data=query.fetchall(), columns=cols)
    return dataset

def plot_series(time, series, format="-", start=0, end=None):
    plt.plot(time[start:end], series[start:end], format)
    plt.xlabel("Time")
    plt.ylabel("Value")
    plt.grid(True)
    
def insert_db(db_path):
    a_ticks_files_list = []
    a_candle_files_list = []

    aux = 'y'
    while aux == 'y':
        a_tick = input('inform a tick file name >>> ')
        #a_candle = input('inform a candle file name >>> ')
        a_ticks_files_list.append(a_tick)
        a_candle_files_list.append("WDOH19_CANDLE_EMPTY") 
        aux = input('continue(y/n)? >>> ')
    mt5_data_handle(db_path, a_ticks_files_list, a_candle_files_list)
    
def test_routine(model, dataset, shift, target, x_matrix_size, x_features_list, model_type):
    if model_type == 1: #MULTICLASS
        x_Mn = dataset
        x_Mn['t_DATE-TIME'] = x_Mn['t_DATE'] + x_Mn['t_TIME']
        y_Mn = dataset.drop_duplicates(subset=['t_DATE-TIME'])
    
        # shift
        y_Mn['t_LAST_Shift'] = y_Mn['t_LAST'].shift(-shift)
        y_Mn['t_TIME_Shift'] = y_Mn['t_TIME'].shift(-shift)
        y_Mn['t_LAST_DELTA'] = y_Mn['t_LAST'] - y_Mn['t_LAST_Shift']
        y_Mn = y_Mn.dropna()
    
        for index, row in y_Mn.iterrows():
            if row['t_LAST_DELTA'] > target:
                y_Mn.loc[index,'t_POS'] = 1
            elif row['t_LAST_DELTA'] < -target:
                y_Mn.loc[index,'t_POS'] = -1
            else:
                y_Mn.loc[index,'t_POS'] = 0
    
        y_Mn = y_Mn[['t_DATE-TIME','t_LAST_Shift','t_TIME_Shift','t_LAST_DELTA','t_POS']]
    
        x_values_matrix = np.zeros((x_matrix_size, len(x_features_list), 1))
        x_values_matrix = np.expand_dims(x_values_matrix,axis=0)
    
        score = 0
        points = 0
        for index, row in y_Mn.iterrows():
            temp = x_Mn[x_features_list].iloc[index]
            temp = temp.values
            temp = np.expand_dims(temp, axis=1)
            x_values_matrix[0][:-1] = x_values_matrix[0][1:]
            x_values_matrix[0][-1] = temp
            predict = model.predict(x_values_matrix)
        
            if (np.argmax(predict[0])== 0) and (row['t_POS'] == 1):
                score += 1
                points += abs(row['t_LAST_DELTA'])
            elif(np.argmax(predict[0])== 1) and (row['t_POS'] == -1):
                score += 1
                points += abs(row['t_LAST_DELTA'])
            elif(np.argmax(predict[0])== 2) and (row['t_POS'] == 0):
                score += 1
            elif(np.argmax(predict[0])== 0) and (row['t_POS'] != 1):
                points -= abs(row['t_LAST_DELTA'])
            elif(np.argmax(predict[0])== 1) and (row['t_POS'] != -1):
                points -= abs(row['t_LAST_DELTA'])
        return score, points
    
    if model_type == 2:
        x_Mn = dataset
        x_Mn['t_DATE-TIME'] = x_Mn['t_DATE'] + x_Mn['t_TIME']
        y_Mn = dataset.drop_duplicates(subset=['t_DATE-TIME'])
    
        # shift
        y_Mn['t_LAST_Shift'] = y_Mn['t_LAST'].shift(-shift)
        y_Mn['t_TIME_Shift'] = y_Mn['t_TIME'].shift(-shift)
        y_Mn['t_LAST_DELTA'] = y_Mn['t_LAST'] - y_Mn['t_LAST_Shift']
        y_Mn = y_Mn.dropna()
    
        for index, row in y_Mn.iterrows():
            if row['t_LAST_DELTA'] > target:
                y_Mn.loc[index,'t_POS'] = 1
            elif row['t_LAST_DELTA'] < -target:
                y_Mn.loc[index,'t_POS'] = -1
            else:
                y_Mn.loc[index,'t_POS'] = 0
    
        y_Mn = y_Mn[['t_DATE-TIME','t_LAST_Shift','t_TIME_Shift','t_LAST_DELTA','t_POS']]
    
        x_values_matrix = np.zeros((x_matrix_size, len(x_features_list)))
        x_values_matrix = np.expand_dims(x_values_matrix,axis=0)

        score = 0
        points = 0
        for index, row in y_Mn.iterrows():
            temp = x_Mn[x_features_list].iloc[index]
            temp = temp.values
            x_values_matrix[0][:-1] = x_values_matrix[0][1:]
            x_values_matrix[0][-1] = temp
            predict = model.predict(x_values_matrix)
            
            if (np.argmax(predict[0])== 0) and (row['t_POS'] == 1):
                score += 1
                points += abs(row['t_LAST_DELTA'])
            elif(np.argmax(predict[0])== 1) and (row['t_POS'] == -1):
                score += 1
                points += abs(row['t_LAST_DELTA'])
            elif(np.argmax(predict[0])== 2) and (row['t_POS'] == 0):
                score += 1
            elif(np.argmax(predict[0])== 0) and (row['t_POS'] != 1):
                points -= abs(row['t_LAST_DELTA'])
            elif(np.argmax(predict[0])== 1) and (row['t_POS'] != -1):
                points -= abs(row['t_LAST_DELTA'])
        return score, points