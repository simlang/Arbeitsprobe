import tensorflow as tf

rng = tf.random.Generator.from_non_deterministic_state()

def score_sum_mean(y_true, y_pred):
    reduced = tf.math.reduce_mean(y_pred, axis=[1, 2])
    return reduced * y_true


def repeat_labels(labels, seq_len):
    labels = tf.expand_dims(labels, 1)
    return tf.repeat(labels, seq_len, 1)


def generate_latent_points(n_batch, seq_len, n_latent):
    return rng.normal(shape=(n_batch, seq_len, n_latent))


def generate_random_labels(n_batch, seq_len, c_dict_size):
    label_batch = rng.uniform(shape=(n_batch, ), minval=0, maxval=c_dict_size, dtype=tf.dtypes.int32)
    repeated_labels = repeat_labels(label_batch, seq_len)
    return repeated_labels


def generate_fake_samples(generator, n_batch, seq_len, n_latent, c_dict_size):
    z_input = generate_latent_points(n_batch, seq_len, n_latent)
    c_input = generate_random_labels(n_batch, seq_len, c_dict_size)
    g_output = generator([z_input, c_input], training=False)
    return g_output


def generate_dataset(generator, size, seq_len, c_dict_size):
    latent_dim = generator.input[0].shape[2]
    z_input = generate_latent_points(size, seq_len, latent_dim)
    labels = generate_random_labels(size, seq_len, c_dict_size)
    outputs = generator([z_input, labels])
    return [outputs, labels[:, 0]]
