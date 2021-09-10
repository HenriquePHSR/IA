import queue
import threading
import struct
import time
import pandas
import numpy
import tensorflow

#(train_X, train_y, epochs=250, batch_size=72, validation_data=(test_X, test_y), verbose=2, shuffle=False)
class thread_training(threading.Thread):
    def __init__(self, model, train_X, train_y, epochs, batch_size, validation_data, verbose, shuffle):
        self.model = model
        self.train_X = train_X
        self.train_y = train_y
        self.epochs = epochs
        self.batch_size = batch_size
        self.validation_data = validation_data
        self.verbose = verbose
        self.shuffle = shuffle
        self.history = 0
        super(thread_training, self).__init__()

    #def onThread(self, function, *args, **kwargs):
    #    self.q.put((function, args, kwargs))

    def run(self):
        self.history = self.model.fit(self.train_X, self.train_y, epochs= self.epochs, batch_size= self.batch_size, validation_data= self.validation_data, verbose= self.verbose, shuffle= self.shuffle)
        self.model.summary()
        save_name = "model_train_on_thread_-_" + str(threading.currentThread().getName())
        self.model.save(save_name)
        
        return self.history