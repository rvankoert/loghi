import argparse
import subprocess
import tempfile
from pathlib import Path

# Dockers to be pulled
docker_version: str = "1.3.4"

# Stop if a single docker command has failed
stop_on_error: bool = True

# Laypa model
baseline_laypa: bool = True
laypa_model: str = "INSERT_FULL_PATH_TO_YAML_HERE"
laypa_model_weights: str = "INSERT_FULLPATH_TO_PTH_HERE"

# Loghi-HTR model
htr_loghi: bool = True
loghi_htr_model: str = "INSERT_FULL_PATH_TO_LOGHI_HTR_MODEL_HERE"
# BEAMWIDTH: higher makes results slightly better at the expense of lot of computation time. In general don't set higher than 10
beam_width: int = 1

# Set this to True for recalculating reading order, line clustering and cleaning.
recalculate_reading_order: bool = True
# If the edge of baseline is closer than x pixels...
recalculate_reading_order_border_margin: int = 50
# Clean if True
recalculate_reading_order_clean_borders: bool = True
# How many threads to use
recalculate_reading_order_threads: int = 4  # REVIEW Why is this the only one that specifies this

# Turn on language detection
detect_language: bool = True

# interpolate word locations
split_words: bool = True

# Used gpu ids, set to "-1" to use CPU, "0" for first, "1" for second, etc
gpu: int = 0


def str2bool(v):
    if isinstance(v, bool):
        return v
    if v.lower() in ("yes", "true", "t", "y", "1"):
        return True
    elif v.lower() in ("no", "false", "f", "n", "0"):
        return False
    else:
        raise argparse.ArgumentTypeError("Boolean value expected.")


def get_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run file to inference using the model found in the config file")

    io_args = parser.add_argument_group("IO")
    io_args.add_argument("-i", "--input", nargs="+", help="Input folder", type=str, action="extend", required=True)
    io_args.add_argument("-o", "--output", help="Output folder", type=str)

    process_args = parser.add_argument_group("Process")
    process_args.add_argument("--docker_version", help="Version of docker release to use", default=docker_version, type=str)
    process_args.add_argument("--stop_on_error", help="Stop if a docker failed", default=stop_on_error, type=str2bool)

    laypa_args = parser.add_argument_group("Laypa")
    laypa_args.add_argument("--baseline_laypa", help="Run Laypa", default=baseline_laypa, type=str2bool)
    laypa_args.add_argument("--laypa_model", help="Laypa config (yaml)", default=laypa_model, type=str)
    laypa_args.add_argument("--laypa_model_weights", help="Laypa weights (pth)", default=laypa_model_weights, type=str)

    loghi_htr_args = parser.add_argument_group("Loghi-HTR")
    loghi_htr_args.add_argument("--htr_loghi", help="Run Loghi-HTR", default=htr_loghi, type=str2bool)
    loghi_htr_args.add_argument("--loghi_htr_model", help="Loghi-HTR model (dir)", default=loghi_htr_model, type=str)
    loghi_htr_args.add_argument("--beam_width", help="Beam width", default=beam_width, type=int)

    loghi_tooling_args = parser.add_argument_group("Loghi Tooling")
    loghi_tooling_args.add_argument(
        "--recalculate_reading_order",
        help="Recalculate reading order",
        default=recalculate_reading_order,
        type=str2bool,
    )
    loghi_tooling_args.add_argument(
        "--recalculate_reading_order_border_margin",
        help="Recalculate reading order border margin",
        default=recalculate_reading_order_border_margin,
        type=int,
    )
    loghi_tooling_args.add_argument(
        "--recalculate_reading_order_clean_borders",
        help="Recalculate reading order clean borders",
        default=recalculate_reading_order_clean_borders,
        type=str2bool,
    )
    loghi_tooling_args.add_argument(
        "--recalculate_reading_order_threads",
        help="Recalculate reading order threads",
        default=recalculate_reading_order_threads,
        type=int,
    )
    loghi_tooling_args.add_argument(
        "--detect_language", help="Recalculate reading order threads", default=detect_language, type=str2bool
    )
    loghi_tooling_args.add_argument(
        "--split_words", help="Split text lines into words based on heuristics", default=split_words, type=str2bool
    )

    gpu_args = parser.add_argument_group("GPU")
    gpu_args.add_argument("--gpu", help="GPU", default=gpu)

    args = parser.parse_args()

    return args


def execute_command(command):
    print(command)
    with subprocess.Popen(
        command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, bufsize=1, universal_newlines=True
    ) as p:
        for line in p.stdout:
            print(line, end="")
        return p


def main(args):
    docker_laypa = f"loghi/docker.laypa:{docker_version}"
    docker_loghi_tooling = f"loghi/docker.loghi-tooling:{docker_version}"
    docker_loghi_htr = f"loghi/docker.htr:{docker_version}"
    use_2013_namespace = " -use_2013_namespace "
    docker_gpu_params = "" if gpu < 0 else f"--gpus device={gpu}"

    laypa_model_path = Path(args.laypa_model)
    laypa_model_weights_path = Path(args.laypa_model_weights)

    tmp_dir_creator = tempfile.TemporaryDirectory()
    tmp_dir = Path(tmp_dir_creator.name)
    print(f"Temporary dir {tmp_dir}")

    input_dir = Path(args.input[0])
    output_dir = Path(args.output) if args.output else input_dir

    user_command = "-u $(id -u ${USER}):$(id -g ${USER})"

    remove_done_command = f"find {input_dir} {output_dir} -name '*.done' -exec rm -f \"{{}}\" \\;"
    remove_done_output = execute_command(remove_done_command)

    if args.stop_on_error and remove_done_output.returncode != 0:
        print(f"Laypa has errored, stopping program: {remove_done_output.stderr}")
        raise subprocess.CalledProcessError(remove_done_output.returncode, remove_done_command)

    if args.baseline_laypa:
        print("Starting Laypa baseline detection")

        laypa_dir = laypa_model_path.parent
        if not input_dir.is_dir():
            print(f"Specified input dir ({input_dir}) does not exist, stopping program")
            raise FileNotFoundError(f"Missing {input_dir}")
        if not output_dir.is_dir():
            print(f"Could not find output dir ({output_dir}), creating one at specified location")
            output_dir.mkdir(exist_ok=True, parents=True)

        laypa_command = (
            f"docker run {docker_gpu_params} --rm -it {user_command} -m 32000m --shm-size 10240m "
            f"-v {laypa_dir}:{laypa_dir} "
            f"-v {input_dir}:{input_dir} "
            f"-v {output_dir}:{output_dir} "
            f"{docker_laypa} python run.py "
            f"-c {laypa_model_path} "
            f"-i {input_dir} "
            f"-o {output_dir} "
            f'--opts MODEL.WEIGHTS "" '
            f"TEST.WEIGHTS {laypa_model_weights_path} "
            # f"| tee -a \"{tmp_dir.joinpath('log.txt')}\" "
        )

        laypa_output = execute_command(laypa_command)
        # print(laypa_output.stdout)

        if args.stop_on_error and laypa_output.returncode != 0:
            # TODO stderr is currently None
            print(f"Laypa has errored, stopping program: {laypa_output.stderr}")
            raise subprocess.CalledProcessError(laypa_output.returncode, laypa_command)

        extract_baseline_command = (
            f"docker run --rm {user_command} "
            f"-v {input_dir}:{input_dir} "
            f"-v {output_dir}:{output_dir} "
            f"{docker_loghi_tooling} /src/loghi-tooling/minions/target/appassembler/bin/MinionExtractBaselines "
            f"-input_path_png {output_dir.joinpath('page')} "
            f"-input_path_page {output_dir.joinpath('page')} "
            f"-output_path_page {output_dir.joinpath('page')} "
            f"-as_single_region true {use_2013_namespace} "
            # f"| tee -a \"{tmp_dir.joinpath('log.txt')}\" "
        )

        extract_baseline_output = execute_command(extract_baseline_command)
        # print(extract_baseline_output.stdout)

        if args.stop_on_error and extract_baseline_output.returncode != 0:
            print(f"MinionExtractBaselines has errored (Laypa), stopping program: {extract_baseline_output.stderr}")
            raise subprocess.CalledProcessError(extract_baseline_output.returncode, extract_baseline_command)

    if args.htr_loghi:
        print("Starting Loghi HTR")

        cut_from_image_command = (
            f"docker run {user_command} --rm "
            f"-v {output_dir}/:{output_dir} "
            f"-v {tmp_dir}:{tmp_dir} "
            f"{docker_loghi_tooling} /src/loghi-tooling/minions/target/appassembler/bin/MinionCutFromImageBasedOnPageXMLNew "
            f"-input_path {output_dir} "
            f"-outputbase {tmp_dir.joinpath('imagesnippets')} "
            f"-output_type png "
            f"-channels 4 "
            f"-threads 4 {use_2013_namespace} "
            # f"| tee -a \"{tmp_dir.joinpath('log.txt')}\" "
        )

        cut_from_image_output = execute_command(cut_from_image_command)
        # print(cut_from_image_output.stdout)

        if args.stop_on_error and cut_from_image_output.returncode != 0:
            print(
                f"MinionCutFromImageBasedOnPageXMLNew has errored (Loghi-HTR), stopping program: {cut_from_image_output.stderr}"
            )
            raise subprocess.CalledProcessError(cut_from_image_output.returncode, cut_from_image_command)

        loghi_htr_model_path = Path(loghi_htr_model)
        loghi_htr_dir = loghi_htr_model_path.parent

        list_images_command = (
            f"find {tmp_dir.joinpath('imagesnippets')} -type f -name '*.png' > {tmp_dir.joinpath('lines.txt')}"
        )

        list_images_output = execute_command(list_images_command)
        # print(list_images_command.stdout)

        if args.stop_on_error and list_images_output.returncode != 0:
            print(f"listing images has errored (Loghi-HTR), stopping program: {list_images_output.stderr}")
            raise subprocess.CalledProcessError(cut_from_image_output.returncode, cut_from_image_command)

        loghi_htr_command = (
            f"docker run {docker_gpu_params} {user_command} --rm -m 32000m --shm-size 10240m -ti "
            f"-v {tmp_dir}:{tmp_dir} "
            f"-v {loghi_htr_dir}:{loghi_htr_dir} "
            # f"bash -c LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4 "
            f"{docker_loghi_htr} python3 /src/loghi-htr/src/main.py "
            f"--do_inference "
            f"--existing_model {loghi_htr_model_path}  "
            f"--batch_size 64 "
            f"--use_mask "
            f"--inference_list {tmp_dir.joinpath('lines.txt')} "
            f"--results_file {tmp_dir.joinpath('results.txt')} "
            f"--charlist {loghi_htr_model_path.joinpath('charlist.txt')} "
            f"--gpu {args.gpu} "
            f"--output {tmp_dir.joinpath('output')} "
            f"--config_file_output {tmp_dir.joinpath('output', 'config.json')} "
            f"--beam_width {beam_width} "
            # f"| tee -a \"{tmp_dir.joinpath('log.txt')}\" "
        )

        loghi_htr_output = execute_command(loghi_htr_command)
        # print(loghi_htr_output.stdout)

        if args.stop_on_error and loghi_htr_output.returncode != 0:
            print(f"Loghi-HTR has errored, stopping program: {loghi_htr_output.stderr}")
            raise subprocess.CalledProcessError(loghi_htr_output.returncode, loghi_htr_command)

        merge_page_command = (
            f"docker run {user_command} --rm -v{output_dir}:{output_dir} -v {tmp_dir}:{tmp_dir} {docker_loghi_tooling} /src/loghi-tooling/minions/target/appassembler/bin/MinionLoghiHTRMergePageXML "
            f"-input_path {output_dir.joinpath('page')} "
            f"-results_file {tmp_dir.joinpath('results.txt')} "
            f"-config_file {tmp_dir.joinpath('output', 'config.json')} {use_2013_namespace} "
            # f"| tee -a \"{tmp_dir.joinpath('log.txt')}\" "
        )

        merge_page_output = execute_command(merge_page_command)
        # print(merge_page_output.stdout)

        if args.stop_on_error and merge_page_output.returncode != 0:
            print(f"MinionLoghiHTRMergePageXML has errored (Loghi-HTR), stopping program: {merge_page_output.stderr}")
            raise subprocess.CalledProcessError(merge_page_output.returncode, merge_page_command)

    if args.recalculate_reading_order:
        print("Recalculating reading order")

        clean_borders = "-clean_borders " if recalculate_reading_order_clean_borders else ""
        recalculate_reading_order_command = (
            f"docker run {user_command} --rm "
            f"-v {output_dir}:{output_dir} "
            f"{docker_loghi_tooling} /src/loghi-tooling/minions/target/appassembler/bin/MinionRecalculateReadingOrderNew "
            f"-input_dir {output_dir.joinpath('page')} "
            f"-border_margin {args.recalculate_reading_order_border_margin} "
            f"{clean_borders}"
            f"-threads {args.recalculate_reading_order_threads} {use_2013_namespace} "
            # f"| tee -a \"{tmp_dir.joinpath('log.txt')}\" "
        )

        recalculate_reading_order_output = execute_command(recalculate_reading_order_command)
        # print(recalculate_reading_order_output.stdout)

        if args.stop_on_error and recalculate_reading_order_output.returncode != 0:
            print(f"MinionRecalculateReadingOrderNew has errored, stopping program: {recalculate_reading_order_output.stderr}")
            raise subprocess.CalledProcessError(recalculate_reading_order_output.returncode, recalculate_reading_order_command)

    if args.detect_language:
        print("Detecting language")
        detect_language_command = (
            f"docker run {user_command} --rm -v {output_dir}:{output_dir} {docker_loghi_tooling} /src/loghi-tooling/minions/target/appassembler/bin/MinionDetectLanguageOfPageXml "
            f"-page {output_dir.joinpath('page')} {use_2013_namespace} "
            # f"| tee -a \"{tmp_dir.joinpath('log.txt')}\" "
        )

        detect_language_output = execute_command(detect_language_command)
        # print(detect_language_output.stdout)

        if args.stop_on_error and detect_language_output.returncode != 0:
            print(f"MinionDetectLanguageOfPageXml has errored, stopping program: {detect_language_output.stderr}")
            raise subprocess.CalledProcessError(detect_language_output.returncode, detect_language_command)

    if args.split_words:
        print("Splitting words")
        split_words_command = (
            f"docker run {user_command} --rm -v {output_dir}/:{output_dir} {docker_loghi_tooling} /src/loghi-tooling/minions/target/appassembler/bin/MinionSplitPageXMLTextLineIntoWords "
            f"-input_path {output_dir.joinpath('page')} {use_2013_namespace} "
            # f"| tee -a \"{tmp_dir.joinpath('log.txt')}\" "
        )

        split_words_output = execute_command(split_words_command)
        # print(split_words_output.stdout)

        # TODO Except Error is easier, probably
        if args.stop_on_error and split_words_output.returncode != 0:
            print(f"MinionSplitPageXMLTextLineIntoWords has errored, stopping program: {split_words_output.stderr}")
            raise subprocess.CalledProcessError(split_words_output.returncode, split_words_command)

    tmp_dir_creator.cleanup()


if __name__ == "__main__":
    args = get_arguments()
    main(args)
