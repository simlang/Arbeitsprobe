import tensorflow as tf
from Helper import model_helper as mh
from tensorflow.keras.layers import Input, Embedding, Concatenate, LSTM, Dense
from tensorflow.keras.models import Model
from tensorflow.keras.constraints import Constraint


class WeightClip(Constraint):
    # set clip value when initialized
    def __init__(self, clip_value):
        self.clip_value = clip_value

    # clip model weights to hypercube
    def __call__(self, weights):
        return tf.keras.backend.clip(weights, -self.clip_value, self.clip_value)

    # get the config
    def get_config(self):
        return {'clip_value': self.clip_value}


def make_generator(n_latent, n_feature_output, c_dict_size, n_hidden_units=100, embedding_size=64):
    latent_input = Input(shape=(None, n_latent), name='rcwgan_generator_latent_input')

    cond_input = Input(shape=(None,), name="rcwgan_generator_cond_input")
    cond_embedding = Embedding(c_dict_size, embedding_size, name="rcwgan_generator_cond_embedding")(cond_input)

    c_gen_input = Concatenate(name="rcwgan_generator_concat_cond_latent")([latent_input, cond_embedding])
    lstm = LSTM(n_hidden_units, return_sequences=True, name="rcwgan_generator_lstm")(c_gen_input)
    output = Dense(n_feature_output, name="rcwgan_generator_dense_output", activation="tanh")(lstm)

    model = Model([latent_input, cond_input], output, name="rcwgan_conditional_generator")
    return model


def make_critic(n_feature, c_dict_size, n_hidden_units=100, embedding_size=64, c=0.1):
    feature_input = Input(shape=(None, n_feature), name="rcwgan_critic_feature_input")

    cond_input = Input(shape=(None,), name="rcwgan_critic_cond_input")
    cond_embedding = Embedding(c_dict_size, embedding_size, name="rcwgan_critic_cond_embedding")(cond_input)

    c_critic_input = Concatenate(name="rcwgan_critic_input_feat_cond")([feature_input, cond_embedding])
    lstm = LSTM(n_hidden_units, kernel_constraint=WeightClip(c), recurrent_constraint=WeightClip(c),
                                return_sequences=True, name="rcwgan_critic_lstm")(c_critic_input)
    score = Dense(1, activation="linear", kernel_constraint=WeightClip(c), name="rcwgan_critic_dense_score")(lstm)

    model = Model([feature_input, cond_input], score, name="rcwgan_conditional_critic")
    return model


class RCWGAN(tf.keras.Model):
    def __init__(self, generator: tf.keras.Model, critic: tf.keras.Model, n_critic, c_dict_size, latent_dim):
        super(RCWGAN, self).__init__()
        self.generator = generator
        self.critic = critic
        self.n_critic = n_critic
        self.c_dict_size = c_dict_size
        self.latent_dim = latent_dim

    def compile(self):
        super(RCWGAN, self).compile()
        self.g_optimizer = tf.optimizers.Adam(learning_rate=0.001)
        self.c_optimizer = tf.optimizers.Adam(learning_rate=0.001)

    def train_critic(self, z_input, x_input, labels):
        fake_sample = self.generator([z_input, labels], training=True)
        with tf.GradientTape() as tape:
            fake_score = self.critic([fake_sample, labels], training=True)
            real_score = self.critic([x_input, labels], training=True)

            c_loss = fake_score - real_score

        c_gradient = tape.gradient(c_loss, self.critic.trainable_variables)
        self.optimizer.apply_gradients(zip(c_gradient, self.critic.trainable_variables))
        return c_loss

    def train_generator(self, z_input, labels):
        with tf.GradientTape() as tape:
            fake_sample = self.generator([z_input, labels], training=True)
            g_score = -self.critic([fake_sample, labels], training=True)

        g_gradient = tape.gradient(g_score, self.generator.trainable_variables)
        self.optimizer.apply_gradients(zip(g_gradient, self.generator.trainable_variables))
        return -g_score

    def train_step(self, data):
        x, y = data
        n_batch = tf.shape(x)[0]
        seq_len = tf.shape(x)[1]

        wasserstein_sum = 0
        self.critic.trainable = True
        for _ in range(self.n_critic):
            z_input = mh.generate_latent_points(n_batch, seq_len, self.latent_dim)
            c_input = mh.repeat_labels(y, seq_len)
            wasserstein_sum -= self.train_critic(z_input, x, c_input)
        w_dist = wasserstein_sum / self.n_critic

        self.critic.trainable = False
        z_input = mh.generate_latent_points(n_batch, seq_len, self.latent_dim)
        c_input = mh.generate_random_labels(n_batch, seq_len, self.c_dict_size)
        g_score = self.train_generator(z_input, c_input)

        return {"w_dist": tf.math.reduce_mean(w_dist), "g_score": tf.math.reduce_mean(g_score)}
