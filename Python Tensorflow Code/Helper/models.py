from Models import RCGAN, RCWGAN_GPe, RCWGAN_GP, RCWGAN
from Helper import settings, utils
import datetime


def make_models(mode: settings.Mode, load_models: bool):
    if load_models:
        g, d = utils.load_models_gan()
    else:
        if mode == settings.Mode.RCGAN:
            g = RCGAN.make_generator(settings.LATENT_DIM, settings.FEATURE_DIM, settings.C_DICT_SIZE, settings.N_HIDDEN_UNITS_G, settings.EMBEDDING_SIZE)
            d = RCGAN.make_discriminator(settings.FEATURE_DIM, settings.C_DICT_SIZE, settings.N_HIDDEN_UNITS_D, settings.EMBEDDING_SIZE)
        elif mode == settings.Mode.RCWGAN:
            g = RCWGAN.make_generator(settings.LATENT_DIM, settings.FEATURE_DIM, settings.C_DICT_SIZE, settings.N_HIDDEN_UNITS_G, settings.EMBEDDING_SIZE)
            d = RCWGAN.make_critic(settings.FEATURE_DIM, settings.C_DICT_SIZE, settings.N_HIDDEN_UNITS_D, settings.EMBEDDING_SIZE, settings.CLIPPING_PARAMETER)
        elif mode == settings.Mode.RCWGAN_GP:
            g = RCWGAN_GP.make_generator(settings.LATENT_DIM, settings.FEATURE_DIM, settings.C_DICT_SIZE, settings.N_HIDDEN_UNITS_G, settings.EMBEDDING_SIZE)
            d = RCWGAN_GP.make_critic(settings.FEATURE_DIM, settings.C_DICT_SIZE, settings.N_HIDDEN_UNITS_D, settings.EMBEDDING_SIZE)
        else:
            g = RCWGAN_GPe.make_generator(settings.LATENT_DIM, settings.FEATURE_DIM, settings.C_DICT_SIZE, settings.N_HIDDEN_UNITS_G, settings.EMBEDDING_SIZE)
            d = RCWGAN_GPe.make_critic(settings.FEATURE_DIM, settings.C_DICT_SIZE, settings.N_HIDDEN_UNITS_D, settings.EMBEDDING_SIZE)

    if mode == settings.Mode.RCGAN:
        gan = RCGAN.RCGAN(g, d, settings.C_DICT_SIZE, settings.LATENT_DIM)
    elif mode == settings.Mode.RCWGAN:
        gan = RCWGAN.RCWGAN(g, d, settings.N_CRITIC, settings.C_DICT_SIZE, settings.LATENT_DIM)
    elif mode == settings.Mode.RCWGAN_GP:
        gan = RCWGAN_GP.RCWGAN_GP(g, d, settings.N_CRITIC, settings.C_DICT_SIZE, settings.LATENT_DIM, settings.SEQ_LEN)
    else:
        gan = RCWGAN_GPe.RCWGAN_GPe(g, d, settings.N_CRITIC, settings.C_DICT_SIZE, settings.LATENT_DIM, settings.SEQ_LEN)
    gan.compile()
    return gan


def train_models(model, data, log_stats=False, save_models=True, log_samples=True, mode='im'):
    callbacks = []
    start_time = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    log_dir = utils.logs_folder + start_time
    if log_stats:
        callback_stats = utils.tensorboard_logger_callback(log_dir)
        callbacks.append(callback_stats)

    if save_models:
        callback_model = utils.SaveModelCallback(start_time)
        callbacks.append(callback_model)

    if log_samples:
        callback_sample = utils.GenerateSampleCallback(settings.SEQ_LEN, settings.LATENT_DIM, settings.C_DICT_SIZE, log_dir, mode=mode)
        callbacks.append(callback_sample)

    model.fit(data, epochs=settings.N_EPOCHS, batch_size=settings.N_BATCH, callbacks=callbacks)
