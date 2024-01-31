# hBOTA

T cell responses to immunodominant microbiome epitopes reflect dynamic transitions from tolerance to inflammation, Pedersen TK et al

## Algorithm
hBOTA is a wrapper around the original BOTA algorithm (PMID: 30349087) and NetMHCIIpan 3.2 (PMID: 29315598). The algorithm is shared in the form of WDL scripts that can be executed in Terra / Firecloud system (https://firecloud.terra.bio/) using Google Cloud resources or with a local installation of workflow management system Cromwell (https://cromwell.readthedocs.io/en/stable/). The underlying dockers are available from the public Docker Hub.

The main hBOTA.wdl requires as input:
1) Allele_List - list of MHC class II alleles recognized by NetMHCIIpan 3.2 (see example list in Allele_List_Example.txt)
2) Sample_Path_List - tab separated file with a protein fasta file names in the first column (wihtout extension) and the path to the folder containing the file in the second column (see example list in File_List_Example.txt)  
3) Fastq_Extension - file extension for the files in Sample_Path_List (e.g. ".faa")

The output of hBOTA is a list of NetMHCIIpan 3.2 predictions of binding to MHC class II alleles for protein regions prioritized by hBOTA.

Note: this is a copy from https://gitlab.com/xavier-lab-computation/public/hbota
