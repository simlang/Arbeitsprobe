import tensorflow as tf
import numpy as np
from Helper import model_helper as mh, settings
from Models import RCGAN, RCWGAN_GPe, RCWGAN_GP, RCWGAN
import io
from multiprocessing import Process
import matplotlib.pyplot as plt

if settings.is_local:
    model_folder = './model/'
    logs_folder = './logs/'
else:
    model_folder = '/mnt/ml-ba-ga27duk/result/model/'
    logs_folder = '/mnt/ml-ba-ga27duk/result/logs/'


def tensorboard_logger_callback(log_dir):
    return tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=10, profile_batch=0)


class SaveModelCallback(tf.keras.callbacks.Callback):
    def __init__(self, start_time):
        super(SaveModelCallback, self).__init__()
        self.start_time = start_time

    def on_epoch_end(self, epoch, logs=None):
        if isinstance(self.model, RCWGAN_GP.RCWGAN_GP):
            save_models(self.model.generator, self.model.critic, self.start_time)
        elif isinstance(self.model, RCWGAN_GPe.RCWGAN_GPe):
            save_models(self.model.generator, self.model.critic, self.start_time)
        elif isinstance(self.model, RCWGAN.RCWGAN):
            save_models(self.model.generator, self.model.critic, self.start_time)
        elif isinstance(self.model, RCGAN.RCGAN):
            save_models(self.model.generator, self.model.discriminator, self.start_time)
        else:
            return


class GenerateSampleCallback(tf.keras.callbacks.Callback):
    def __init__(self, seq_len, latent_dim, c_dict_size, log_dir, amount=25, mode='im'):
        super(GenerateSampleCallback, self).__init__()
        self.random_seed = mh.generate_latent_points(amount, seq_len, latent_dim)
        self.random_labels = mh.generate_random_labels(25, seq_len, c_dict_size)
        self.file_writer = tf.summary.create_file_writer(log_dir)
        self.mode = mode

    def save_img_thread(self, fake_data, epoch):
        with self.file_writer.as_default():
            if self.mode == 'gr':
                plot = graph_grid(fake_data, self.random_labels[:, 0])
            else:
                plot = image_grid(fake_data, self.random_labels[:, 0])
            tf.summary.image('samples', plot_to_image(plot), step=epoch)


    def on_epoch_begin(self, epoch, logs=None):
        if epoch % 1 == 0:
            if isinstance(self.model, RCWGAN_GP.RCWGAN_GP):
                g = self.model.generator
            elif isinstance(self.model, RCWGAN_GPe.RCWGAN_GPe):
                g = self.model.generator
            elif isinstance(self.model, RCWGAN.RCWGAN):
                g = self.model.generator
            elif isinstance(self.model, RCGAN.RCGAN):
                g = self.model.generator
            else:
                return
            fake_data = g([self.random_seed, self.random_labels])

            if settings.is_local:
                p = Process(target=self.save_img_thread, args=(fake_data, epoch))
                p.start()
            else:
                self.save_img_thread(fake_data, epoch)



def save_plot_to_file(name, plot):
    plot.savefig('plots/' + name + '.png')

def plot_to_image(figure):
    """Converts the matplotlib plot specified by 'figure' to a PNG image and
    returns it. The supplied figure is closed and inaccessible after this call."""
    # Save the plot to a PNG in memory.
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    # Closing the figure prevents it from being displayed directly inside
    # the notebook.
    plt.close(figure)
    buf.seek(0)
    # Convert PNG buffer to TF image
    image = tf.image.decode_png(buf.getvalue(), channels=1)
    # Add the batch dimension
    image = tf.expand_dims(image, 0)
    return image


def image_grid(images, labels):
    figure = plt.figure(figsize=(10, 10))
    for i in range(25):
        # Start next subplot.
        plt.subplot(5, 5, i + 1, title=str(labels[i].numpy()))
        plt.xticks([])
        plt.yticks([])
        plt.grid(False)
        plt.imshow(images[i], cmap='gray')

    return figure

def graph_grid(data, labels):
    figure = plt.figure(figsize=(10, 10))
    for i in range(25):
        # Start next subplot.
        plt.subplot(5, 5, i + 1, title=str(labels[i].numpy()))
        plt.xticks([])
        plt.yticks(np.arange(-1.0, 1.1, step=0.2))
        plt.ylim(-1.1, 1.1)
        plt.grid(False)
        plt.plot(data[i])
    figure.tight_layout()
    return figure


def plot_model(model: tf.keras.Model, name='model'):
    tf.keras.utils.plot_model(model, name + '.png', show_layer_names=True,
                              show_shapes=True)


def save_models(g_model=None, c_model=None, start_time=""):
    if g_model:
        tf.keras.models.save_model(g_model, model_folder + 'generator', save_format='h5')
    if c_model:
        tf.keras.models.save_model(c_model, model_folder + 'discriminator', save_format='h5')


def load_models_gan():
    generator = tf.keras.models.load_model(model_folder + 'generator')
    critic = tf.keras.models.load_model(model_folder + 'discriminator')
    return [generator, critic]

def load_generator():
    generator = tf.keras.models.load_model(model_folder + 'generator', custom_objects={"Functional": tf.keras.Model})
    return generator
