import tensorflow as tf
from tensorflow.keras import layers
from Helper import model_helper

HIDDEN_UNITS = 64

def make_classifier(feature_dim, categories):
    input = layers.Input(shape=(None, feature_dim))

    lstm_1 = layers.Bidirectional(layers.LSTM(HIDDEN_UNITS, return_sequences=True))(input)
    lstm_2 = layers.Bidirectional(layers.LSTM(HIDDEN_UNITS))(lstm_1)

    dense = layers.Dense(HIDDEN_UNITS, activation='relu')(lstm_2)
    dropout = layers.Dropout(0.5)(dense)
    output = layers.Dense(categories)(dropout)
    model = tf.keras.Model(input, output)
    model.compile(
        optimizer='adam',
        loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=['accuracy']
    )
    return model


def train_classifier_on_synthetic(classifier: tf.keras.Model, generator, eval_data, s_batch, n_batch, n_epochs, seq_len, categories, log_freq = 1, eval_freq=10):
    loss = 0
    acc = 0
    for e in range(n_epochs):
        for _ in range(s_batch):
            data, label = model_helper.generate_dataset(generator, n_batch, seq_len, categories)
            loss_new, acc_new = classifier.train_on_batch(data, label)
            loss += loss_new
            acc += acc_new
        if (e+1) % log_freq == 0:
            mean_loss = loss / (log_freq * s_batch)
            mean_acc = acc / (log_freq * s_batch)
            loss = 0
            acc = 0
            print("loss: %f, acc: %f" % (mean_loss, mean_acc))
        if (e+1) % eval_freq == 0:
            classifier.evaluate(eval_data)

