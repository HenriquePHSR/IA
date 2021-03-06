import queue
import threading
import struct
import time
import numpy as np
import tensorflow as tf

class thread_main_loop(threading.Thread):
    def __init__(self, model, input_x_len, input_y_len, input_z_len, r_buffer_id, w_buffer_id, model_type):
        self.model = model
        self.model_type = model_type
        self.input_x_len = input_x_len
        self.input_y_len = input_y_len
        self.input_z_len = input_z_len
        self.r_buffer_id = r_buffer_id
        self.w_buffer_id = w_buffer_id
        self.sleep_task = False
        self.end_task = False
        super(thread_main_loop, self).__init__()

    #def onThread(self, function, *args, **kwargs):
    #    self.q.put((function, args, kwargs))

    def run(self):
        base_df = pd.dataframe()
        if self.model_type == 0:
            x_values_matrix = np.zeros((self.input_x_len, self.input_y_len, self.input_z_len))
            x_values_matrix = np.expand_dims(x_values_matrix,axis=0)
        if self.model_type == 1:
            x_values_matrix = np.zeros((self.input_x_len, self.input_y_len))
            x_values_matrix = np.expand_dims(x_values_matrix,axis=0)
        while True:
            if (self.end_task == True):
                break
            if (self.sleep_task == True):
                continue
            try:
                tick = ''
                fh_1 = open(r"C:\Users\Henrique\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Files\buffer_" + self.r_buffer_id, "r")
                tick = fh_1.read()
                fh_1.close()
            
                tick = tick.replace('\x00', '')
                tick = tick.replace('ÿþ', '')
                tick = tick.replace('\n', '')
                tick = tick.split(';')
                tick[0] = tick[0].split(',')
                temp = np.asarray([float(tick[1]), float(tick[2]), float(tick[3]), float(tick[4]), float(tick[5]),float(tick[6]),float(tick[7]),float(tick[8]),float(tick[9])])
            except:
                print("## file read error")
                time.sleep(1)
                continue
            if self.model_type == 0:
                temp = np.expand_dims(temp, axis=1)
                x_values_matrix[0][:-1] = x_values_matrix[0][1:]
                print(threading.currentThread().getName())
                print(x_values_matrix)
                x_values_matrix[0][-1] = temp

                y_predict = self.model.predict(x_values_matrix)
                print(str(threading.currentThread().getName()) + " : " + str(y_predict[0]))
            if self.model_type == 1:
                x_values_matrix[0][:-1] = x_values_matrix[0][1:]
                x_values_matrix[0][-1] = temp
                print(threading.currentThread().getName())
                print(x_values_matrix)
                y_predict = self.model.predict(x_values_matrix)
                print(str(threading.currentThread().getName()) + " : " + str(y_predict[0]))
            if (len(y_predict[0]) > 1):
                if (np.argmax(y_predict[0]) == 0):
                    value = float(10.0 * y_predict[0][0])
                elif (np.argmax(y_predict[0]) == 1):
                    value = float(-10.0 * y_predict[0][1])
                else:
                    value = 0.0
            else:
                value = y_predict[0]
            ba = bytearray(struct.pack("f", value))
            try:
                fh_2 = open(r"C:\Users\Henrique\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Files\buffer_" + self.w_buffer_id, "wb")
                fh_2.write(ba)
                fh_2.close()
            except:
                print("## file write error")
                time.sleep(1)
                continue
            
            time.sleep(59)
    
    def stop(self):
        self.sleep_task = True

    def awake(self):
        self.sleep_task = False

    def kill(self):
        self.end_task = True
        