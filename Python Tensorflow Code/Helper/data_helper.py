import numpy as np
import tensorflow as tf
from Helper import settings

if settings.is_local:
    data_folder = './data/'
else:
    data_folder = '/mnt/ml-ba-ga27duk/data/'


gestureMode = 16


def loadMNIST(size=60000):
    assert (size > 0) & (size <= 60000)
    (train_images, train_labels), (test_images, test_labels) = tf.keras.datasets.mnist.load_data()
    train_images = train_images.reshape((train_images.shape[0], 28, 28)).astype('float32')
    train_images = train_images.astype('float32')
    train_labels = train_labels.astype('int32')
    train_images = (train_images - 127.5) / 127.5

    test_images = test_images.reshape((test_images.shape[0], 28, 28)).astype('float32')
    test_images = test_images.astype('float32')
    test_labels = test_labels.astype('int32')
    test_images = (test_images - 127.5) / 127.5
    return makeDataSet(train_images[0:size], train_labels[0:size]), makeDataSet(test_images[0:size], test_labels[0:size])


def loadSin(mode='us'):
    if mode == 'us':
        data = np.genfromtxt(data_folder + 'US.csv', delimiter=',')
    else:
        data = np.genfromtxt(data_folder + 'USwdF.csv', delimiter=',')

    label = data[-1, :]
    data = data[0:-1, :]
    data = data.astype('float32')
    label = label.astype('int32')

    data = np.transpose(data)
    data = data
    label = np.squeeze(label)
    data = np.expand_dims(data, axis=2)
    return makeDataSet(data, label)


def loadGestures_raw():
    csv = np.genfromtxt(data_folder + 'gestures.csv', delimiter=',')
    labels = csv[:, -1].astype('int32')
    if gestureMode == 16:
        labels = np.reshape(labels, (5800, 2))
    else:
        labels = np.reshape(labels, (2900, 4))
    labels = labels[:, 0]

    raw_data = csv[:, 0:-1].astype('float32')
    raw_data = ((raw_data + 0.5) / 127.5)
    if gestureMode == 16:
        raw_data = np.reshape(raw_data, (5800, 128))
    else:
        raw_data = np.reshape(raw_data, (2900, 256))

    data = []
    for row in raw_data:
        if gestureMode == 16:
            block = np.reshape(row, (16, 8))
        else:
            block = np.reshape(row, (32, 8))
        data.append(block)
    return np.array(data), np.array(labels)


def loadGestures():
    data, labels = loadGestures_raw()
    return makeDataSet(data, labels)


def loadGestures_for_Classifier():
    data, labels = loadGestures_raw()
    size = data.shape[0]

    train_data = []
    train_label = []
    test_data = []
    test_label = []
    indexes = np.random.uniform(0.0, 1.0, size)
    for i in range(size):
        if indexes[i] <= 0.2:
            test_data.append(data[i])
            test_label.append(labels[i])
        else:
            train_data.append(data[i])
            train_label.append(labels[i])

    return makeDataSet(np.array(train_data), np.array(train_label)), makeDataSet(np.array(test_data), np.array(test_label))



def makeDataSet(data, labels):
    return tf.data.Dataset.from_tensor_slices((tf.convert_to_tensor(data), tf.convert_to_tensor(labels))).repeat(20).shuffle(3000).batch(
        settings.N_BATCH, drop_remainder=True).prefetch(1)
