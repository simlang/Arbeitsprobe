import tensorflow as tf
from Helper import model_helper as mh
from tensorflow.keras.layers import Input, Embedding, Concatenate, Dense, LSTM
from tensorflow.keras.models import Model


def make_generator(n_latent, n_feature_output, c_dict_size, n_hidden_units=100, embedding_size=64):
    latent_input = Input(shape=(None, n_latent), name='rcwgangp_generator_latent_input')

    cond_input = Input(shape=(None,), name="rcwgangp_generator_cond_input")
    cond_embedding = Embedding(c_dict_size, embedding_size, name="rcwgangp_generator_cond_embedding")(cond_input)

    c_gen_input = Concatenate(name="rcwgangp_generator_concat_cond_latent")([latent_input, cond_embedding])
    lstm = LSTM(n_hidden_units, return_sequences=True, name="rcwgangp_generator_lstm")(c_gen_input)
    output = Dense(n_feature_output, name="rcwgangp_generator_dense_output", activation="tanh")(lstm)

    model = Model([latent_input, cond_input], output, name="rcwgangp_conditional_generator")
    return model


def make_critic(n_feature, c_dict_size, n_hidden_units=100, embedding_size=64):
    feature_input = Input(shape=(None, n_feature), name="rcwgangp_critic_feature_input")

    cond_input = Input(shape=(None,), name="rcwgangp_critic_cond_input")
    cond_embedding = Embedding(c_dict_size, embedding_size, name="rcwgangp_critic_cond_embedding")(cond_input)

    c_critic_input = Concatenate(name="rcwgangp_critic_input_feat_cond")([feature_input, cond_embedding])
    lstm = LSTM(n_hidden_units, return_sequences=True, name='rcwgangp_critic_lstm')(c_critic_input)
    score = Dense(1, activation="linear", name="rcwgangp_critic_dense_score")(lstm)

    model = Model([feature_input, cond_input], score, name="rcwgangp_conditional_critic")
    return model


class RCWGAN_GP(tf.keras.Model):
    def __init__(self, generator: tf.keras.Model, critic: tf.keras.Model, n_critic, c_dict_size, latent_dim, seq_len):
        super(RCWGAN_GP, self).__init__()
        self.generator = generator
        self.critic = critic
        self.gp_weight = tf.constant(0.1)
        self.n_critic = n_critic
        self.c_dict_size = c_dict_size
        self.latent_dim = latent_dim
        self.seq_len = seq_len

    def compile(self,
                c_optimizer=tf.keras.optimizers.Adam(learning_rate=0.001, beta_1=0.9, beta_2=0.999),
                g_optimizer=tf.keras.optimizers.Adam(learning_rate=0.001, beta_1=0.9, beta_2=0.999)):
        super(RCWGAN_GP, self).compile()
        self.c_optimizer = c_optimizer
        self.g_optimizer = g_optimizer
        
    def interpolate(self, x, y):
        n_batch = tf.shape(x)[0]
        epsilon = tf.random.uniform((n_batch, 1, 1), 0.0, 1.0)
        diff = tf.math.subtract(y, x)
        interpolated = tf.math.add(x, tf.math.multiply(epsilon, diff))
        return interpolated

    def calc_gp(self, real_samples, fake_samples, labels):
        interpolated = self.interpolate(real_samples, fake_samples)
        with tf.GradientTape(watch_accessed_variables=False) as tape:
            tape.watch(interpolated)
            score = self.critic([interpolated, labels], training=True)

        gradient = tape.gradient(score, interpolated)
        #norm = tf.reduce_sum(tf.math.square(gradient), axis=2)
        norm = tf.norm(gradient, axis=2)
        return tf.math.square((norm - tf.ones_like(norm)))

    def calc_critic_loss(self, x_input, fake_sample, labels, fake_score, real_score):
        w_dist = tf.squeeze(fake_score - real_score)
        gp = self.calc_gp(x_input, fake_sample, labels)
        return w_dist + tf.math.scalar_mul(self.gp_weight, gp), -w_dist

    def calc_gen_loss(self, z_input, labels):
        fake_sample = self.generator([z_input, labels], training=True)
        g_score = self.critic([fake_sample, labels], training=True)
        return -g_score

    def train_critic(self, z_input: tf.Tensor, x_input: tf.Tensor, labels: tf.Tensor):
        fake_sample = self.generator([z_input, labels], training=True)
        fake_score = self.critic([fake_sample, labels], training=True)
        real_score = self.critic([x_input, labels], training=True)
        c_loss, w_dist = self.calc_critic_loss(x_input, fake_sample, labels, fake_score, real_score)
        gradient = tf.gradients(c_loss, self.critic.trainable_variables)
        self.c_optimizer.apply_gradients(zip(gradient, self.critic.trainable_variables))
        return c_loss, w_dist

    def train_generator(self, z_input: tf.Tensor, labels: tf.Tensor):
        g_loss = self.calc_gen_loss(z_input, labels)
        gradient = tf.gradients(g_loss, self.generator.trainable_variables)
        self.g_optimizer.apply_gradients(zip(gradient, self.generator.trainable_variables))
        return g_loss

    def train_step(self, data):
        x, y = data
        n_batch = tf.shape(x)[0]
        seq_len = tf.shape(x)[1]
        c_loss_sum = 0
        w_dist_sum = 0

        self.critic.trainable = True
        c_input = mh.repeat_labels(y, seq_len)
        for _ in range(self.n_critic):
            z_input = mh.generate_latent_points(n_batch, seq_len, self.latent_dim)
            c_loss_t, w_dist_t = self.train_critic(z_input, x, c_input)
            c_loss_sum += c_loss_t
            w_dist_sum += w_dist_t
        c_loss = c_loss_sum / self.n_critic
        w_dist = w_dist_sum / self.n_critic

        self.critic.trainable = False
        z_input = mh.generate_latent_points(n_batch, seq_len, self.latent_dim)
        c_input = mh.generate_random_labels(n_batch, seq_len, self.c_dict_size)
        g_loss = -self.train_generator(z_input, c_input)

        return {"c_loss": c_loss, "g_score": g_loss, "w_dist": tf.reduce_mean(w_dist)}



