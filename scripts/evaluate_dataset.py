# System imports
import sys
sys.path.insert(0, "/home/marx/Documents/Github/DeepMReye")
import os
from argparse import ArgumentParser

# DeepMReye imports
from deepmreye import architecture, train, analyse, preprocess
from deepmreye.util import data_generator, model_opts
from deepmreye.util.util import CLI_OPTIONS

# --------------------------------------------------------------------------------
# ------------------------Evaluate model on given dataset-------------------------
# --------------------------------------------------------------------------------

# Parse input arguments
parser = ArgumentParser()
for val, item in CLI_OPTIONS.items():
    parser.add_argument(*item.cli, dest=val, **item.kwargs)
args = parser.parse_args()
# Set GPU
os.environ["CUDA_VISIBLE_DEVICES"] = "{}".format(args.gpu_id)

# Create data generators from given path
dataset_name = os.path.basename(os.path.dirname(args.dataset_path))
generators = data_generator.create_holdout_generators([args.dataset_path], train_split=0.90)
opts = model_opts.get_opts()
# User options which are different than the default are adjusted *within* the script (uncomment line below) not at command line
# opts['epochs'] = 15

# Train model and save weights into weights_path
(model, model_inference) = train.train_model(dataset=dataset_name, generators=generators, opts=opts, use_multiprocessing=True,
                                             return_untrained=False, verbose=1, save=True, model_path=args.weights_path)

