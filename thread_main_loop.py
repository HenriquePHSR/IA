import queue
import threading
import struct
import time as tm
import numpy as np
import tensorflow as tf
import pandas as pd
import numpy as np
import datetime

def pre_processing(df):
    df['t_BID']=(df['t_BID'] - df['iTEMA']) / df['iStdDEV']
    df['t_ASK']=(df['t_ASK'] - df['iTEMA']) / df['iStdDEV']
    df['t_LAST']=(df['t_LAST'] - df['iTEMA']) / df['iStdDEV']
    df['iCCI']=(df['iCCI']-df['iCCI'].mean()) / df['iCCI'].std()
    df['Vx']=(df['Vx']-df['Vx'].mean()) / df['Vx'].std()
    df['Vy']=(df['Vy']-df['Vy'].mean()) / df['Vy'].std()
    df = df.drop(columns=['iTEMA'])
    return df


class thread_main_loop(threading.Thread):
    def __init__(self, model, r_buffer_id, w_buffer_id, scaler):
        self.model = model
        self.scaler = scaler
        self.r_buffer_id = r_buffer_id
        self.w_buffer_id = w_buffer_id
        self.sleep_task = False
        self.end_task = False
        super(thread_main_loop, self).__init__()

    #def onThread(self, function, *args, **kwargs):
    #    self.q.put((function, args, kwargs))

    def run(self):
        i=0
        day = 24*60*60
        full_feature_list=['t_DATE', 't_TIME','t_SEC', 't_BID', 't_ASK', 't_LAST', 't_VOLUME', 't_TYPE', 'iAC', 'iAD', 'iADX', 'iADXWilder', 'iAlligator', 'iAMA', 'iAO', 'iATR', 'iBearsPower', 'iBands', 'iBullsPower', 'iCCI', 'iChaikin', 'iDEMA', 'iDeMarker', 'iEnvelopes', 'iForce', 'iFractals', 'iFrAMA', 'iIchimoku', 'iBWMFI', 'iMomentum', 'iMFI', 'iMA', 'iOsMA', 'iMACD', 'iOBV', 'iSAR', 'iRSI', 'iRVI', 'iStdDEV', 'iStochastic', 'iTEMA', 'iTriX', 'iWPR', 'iVIDyA', 'iVolumes']
        base_df = []
        df = pd.DataFrame(columns=full_feature_list)
        
        while True:
            if (self.end_task == True):
                break
            if (self.sleep_task == True):
                continue
            #try:
            tick = ''
            fh_1 = open(r"C:\Users\Henrique\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Files\buffer_" + self.r_buffer_id, "r")

            for line in fh_1:
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
                
                base_df.append([
                    str(pieces[0][0]), str(time[0]),str(time[2]), float(pieces[1]), float(pieces[2]),
                    float(pieces[3]), float(pieces[4]),
                    int(pieces[5]), float(indic[0]), float(indic[1]),float(indic[2]),float(indic[3]),float(indic[4]),float(indic[5]),float(indic[6]),float(indic[7]),float(indic[8]),float(indic[9]),float(indic[10]),float(indic[11]),float(indic[12]),float(indic[13]),float(indic[14]),float(indic[15]),float(indic[16]),float(indic[17]),float(indic[18]),float(indic[19]),float(indic[20]),float(indic[21]),float(indic[22]),float(indic[23]),float(indic[24]),float(indic[25]),float(indic[26]),float(indic[27]),float(indic[28]),float(indic[29]),float(indic[30]),float(indic[31]),float(indic[32]),float(indic[33]),float(indic[34]),float(indic[35]),float(indic[36])
                    ])
                i=i+1
            df=pd.DataFrame(base_df,index=np.arange(len(base_df)),columns=full_feature_list)
            
            v = df['iVolumes']
            # Convert to radians.
            v_rad = df['iForce']*np.pi / 180
            # Calculate the x and y components.
            df['Vx'] = v*np.cos(v_rad)
            df['Vy'] = v*np.sin(v_rad)
            
            df['t_DATE-TIME']=df['t_DATE']+" "+df['t_TIME']
            df['t_DATE-TIME']
            date_time = pd.to_datetime(df['t_DATE-TIME'], format='%Y.%m.%d %H:%M')
            timestamp_s = date_time.map(datetime.datetime.timestamp)
            
            df['day sin'] = np.sin(timestamp_s * (2 * np.pi / day))
            df['day cos'] = np.cos(timestamp_s * (2 * np.pi / day))
            
            
            x=df[['t_BID', 't_ASK', 't_LAST', 'Vx', 'Vy', 'day sin', 'day cos']]
            
            last_row=x.iloc[-1]
            print('#########')
            print(last_row)
            print('#########')
            #except:
            #    print("## file read error")
            #    tm.sleep(1)
            #    continue
            last_row=np.array(last_row).reshape(1, -1)
            last_row = self.scaler.transform(last_row)
            print('#########')
            print(last_row)
            print('#########')
            
            predict=self.model.predict([last_row])
            
            value = predict
            print('#########')
            print(predict)
            print('#########')
            ba = bytearray(struct.pack("f", value))
            try:
                fh_2 = open(r"C:\Users\Henrique\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Files\buffer_" + self.w_buffer_id, "wb")
                fh_2.write(ba)
                fh_2.close()
            except:
                print("## file write error")
                tm.sleep(1)
                continue
            
            tm.sleep(5)
    
    def stop(self):
        self.sleep_task = True

    def awake(self):
        self.sleep_task = False

    def kill(self):
        self.end_task = True
        