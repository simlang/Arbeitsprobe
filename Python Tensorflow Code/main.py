from Helper import data_helper, settings, models, utils
from Models import Classifier
import tensorflow as tf

data = data_helper.loadSin(mode='us')
#data, test = data_helper.loadMNIST(size=60000)
#data = data_helper.loadGestures()
#data, test = data_helper.loadGestures_for_Classifier()

gan = models.make_models(settings.mode, settings.load_models)
models.train_models(gan, data, log_stats=True, save_models=False, log_samples=True, mode='gr')


#generator = utils.load_generator()
#classifier = Classifier.make_classifier(28, 10)
#Classifier.train_classifier_on_synthetic(classifier, generator, data, 64, 360, 100, 16, 4, 1, 1)

#callback = tf.keras.callbacks.TensorBoard(log_dir=utils.logs_folder, histogram_freq=0, profile_batch=0)
#classifier.fit(data, validation_data=test, epochs=100)
