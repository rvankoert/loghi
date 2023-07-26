this is an example of how to run Loghi in a dockerized environment using the API's:

we assume 
- all source is under ~/src/
- dockers are loaded and available as images

this package is loghi and should be located at ~/src/loghi/
typical workflow:
go to dir "webservice"
"cd ~/src/loghi/webservice/"

optionally edit docker-compose.yml

start dockers
"docker-compose up"
this starts the dockers and will provide a log of what is happening.
a docker-compose version of 1.28.0 or higher is required to access the GPU's properly
https://docs.docker.com/compose/gpu-support/#enabling-gpu-access-to-service-containers

to do initial baseline-detection:
"./do_laypa.sh /scratch/3105"
results are found at /tmp/output/laypa

extract baselines:
"./extract_baselines_laypa.sh /tmp/output/laypa/NL_HaNa_2.12.03_3105_0094/"
=> results are found at /tmp/upload/NL_HaNa_2.12.03_3105_0094/NL_HaNa_2.12.03_3105_0094.xml


cp /tmp/upload/NL_HaNa_2.12.03_3105_0094/NL_HaNa_2.12.03_3105_0094.xml /scratch/3105/page/

./cut_from_image.sh /scratch/3105

=> line snippet-results can be found at /tmp/upload/NL_HaNa_2.12.03_3105_0094/NL_HaNa_2.12.03_3105_0094/

run actual HTR on snippets:
./do_htr.sh /tmp/upload/NL_HaNa_2.12.03_3105_0094/NL_HaNa_2.12.03_3105_0094/

find /tmp/output/loghi-htr/NL_HaNa_2.12.03_3105_0094/ -name '*.txt' -type f -exec cat {} + > NL_HaNa_2.12.03_3105_0094.txt


#merge results with pageXML
./loghi-htr-merge-page-xml.sh /scratch/3105/page/NL_HaNa_2.12.03_3105_0094.xml NL_HaNa_2.12.03_3105_0094.txt /home/rutger/src/loghi-htr-models/generic_new_17_2023_05_25_4channel/config.json 

#recalculate reading order
./recalculate_reading_order.sh /scratch/3105/page/

#split into words
./split_into_words.sh /scratch/3105/page/

Known issues:
-PyTorch based code seems to break down on MIG-enabled GPU's (LayPa, PyLaia, P2PaLA)
-Loghi-HTR breaks down after an error and does not reset automatically yet
