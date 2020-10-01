import tensorflow as tf
from Helper import model_helper as mh
from tensorflow.keras.layers import Input, Embedding, Concatenate, LSTM, Dense, GaussianNoise
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.losses import binary_crossentropy


def make_generator(n_latent, n_feature_output, c_dict_size, n_hidden_units=100, embedding_size=64):
    latent_input = Input(shape=(None, n_latent), name='rcgan_generator_latent_input')

    cond_input = Input(shape=(None,), name="rcgan_generator_cond_input")
    cond_embedding = Embedding(c_dict_size, embedding_size, name="rcgan_generator_cond_embedding")(cond_input)

    c_gen_input = Concatenate(name="rcgan_generator_concat_cond_latent")([latent_input, cond_embedding])
    lstm = LSTM(n_hidden_units, return_sequences=True, name="rcgan_generator_lstm")(c_gen_input)
    output = Dense(n_feature_output, name="rcgan_generator_dense_output", activation="tanh")(lstm)

    model = Model([latent_input, cond_input], output, name="rcgan_conditional_generator")
    return model


def make_discriminator(n_feature, c_dict_size, n_hidden_units=100, embedding_size=64):
    feature_input = Input(shape=(None, n_feature), name="rcgan_discriminator_feature_input")
    feature_w_noise = GaussianNoise(stddev=0.01, name="rcgan_discriminator_noise_for_input")(feature_input)

    cond_input = Input(shape=(None,), name="rcgan_discriminator_cond_input")
    cond_embedding = Embedding(c_dict_size, embedding_size, name="rcgan_iscriminator_cond_embedding")(cond_input)

    c_critic_input = Concatenate(name="rcgan_discriminator_input_feat_cond")([feature_input, cond_embedding])
    lstm_1 = LSTM(n_hidden_units, return_sequences=True, name='rcgan_discriminator_lstm_1')(c_critic_input)
    lstm_2 = LSTM(n_hidden_units, return_sequences=True, name='rcgan_discriminator_lstm_2')(lstm_1)
    prob = Dense(1, activation="sigmoid", name="rcgan_discriminator_dense_score")(lstm_2)

    model = Model([feature_input, cond_input], prob, name="rcgan_conditional_discriminator_gp")
    return model


def make_gan(generator, discriminator):
    latent_input, c_input = generator.input
    g_output = generator.output
    gan_output = discriminator([g_output, c_input])

    model = Model([latent_input, c_input], gan_output, name='rcgan')
    return model


class RCGAN(tf.keras.Model):
    def __init__(self, generator: tf.keras.Model, discriminator: tf.keras.Model, c_dict_size, latent_dim):
        super(RCGAN, self).__init__()
        self.generator = generator
        self.discriminator = discriminator
        self.c_dict_size = c_dict_size
        self.latent_dim = latent_dim

    def compile(self, d_loss=binary_crossentropy,
                gan_loss=binary_crossentropy,
                d_opt=Adam(learning_rate=0.001, beta_1=0.9, beta_2=0.999),
                gan_opt=Adam(learning_rate=0.001, beta_1=0.9, beta_2=0.999)):
        super(RCGAN, self).compile()
        self.d_loss = d_loss
        self.gan_loss = gan_loss
        self.d_opt = d_opt
        self.gan_opt = gan_opt
        self.gan = make_gan(self.generator, self.discriminator)

    def train_discriminator(self, x_input, z_input, c_input):
        fake_sample = self.generator([z_input, c_input])
        with tf.GradientTape() as tape:
            prob_real = self.discriminator([x_input, c_input])
            prob_fake = self.discriminator([fake_sample, c_input])

            d_loss = self.d_loss(tf.constant(0.9) * tf.ones_like(prob_real), prob_real) + self.d_loss(tf.zeros_like(prob_fake), prob_fake)

        gradient = tape.gradient(d_loss, self.discriminator.trainable_variables)
        self.d_opt.apply_gradients(zip(gradient, self.discriminator.trainable_variables))
        return d_loss

    def train_generator(self, z_input, c_input):
        with tf.GradientTape() as tape:
            prob_fake = self.gan([z_input, c_input])
            gan_loss = self.gan_loss(tf.ones_like(prob_fake), prob_fake)

        gradient = tape.gradient(gan_loss, self.gan.trainable_variables)
        self.gan_opt.apply_gradients(zip(gradient, self.gan.trainable_variables))
        return prob_fake

    def train_step(self, data):
        x, y = data
        n_batch = tf.shape(x)[0]
        seq_len = tf.shape(x)[1]

        self.discriminator.trainable = True
        z_input = mh.generate_latent_points(n_batch, seq_len, self.latent_dim)
        c_input = mh.repeat_labels(y, seq_len)
        d_loss = self.train_discriminator(x, z_input, c_input)

        self.discriminator.trainable = False
        z_input = mh.generate_latent_points(n_batch, seq_len, self.latent_dim)
        c_input = mh.generate_random_labels(n_batch, seq_len, self.c_dict_size)
        g_loss = self.train_generator(z_input, c_input)

        return {"d_loss": d_loss, "g_loss": g_loss}
