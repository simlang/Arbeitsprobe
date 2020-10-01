from enum import Enum


class Mode(Enum):
    RCGAN = 1
    RCWGAN = 2
    RCWGAN_GP = 3
    RCWGAN_GPe = 4


is_local = True
mode = Mode.RCWGAN_GP
load_models = False

N_EPOCHS = 10000
N_BATCH = 32
N_CRITIC = 5
LATENT_DIM = 1
FEATURE_DIM = 1
SEQ_LEN = 30
C_DICT_SIZE = 1
N_HIDDEN_UNITS_G = 8 # 16
N_HIDDEN_UNITS_D = 64 # 64
EMBEDDING_SIZE = 1
CLIPPING_PARAMETER = 0.1
