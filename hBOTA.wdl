##### WORKFLOW DEFINITION #####
import "https://github.com/jwitch/hBOTA/tree/main/NETMHC2_allele.wdl" as sub
workflow hBOTA{
###changed name of workflow####
	File Sample_Path_List
	File Allele_List
    String Fastq_Extension
	
	Map[String, String] SamplesPaths = read_map(Sample_Path_List)
	scatter (pair in SamplesPaths){

		String SampleDir = pair.right
		String SampleName = pair.left

		File fastaFile = SampleDir + SampleName + Fastq_Extension

		# run BOTA to get prioritized regions
		call BOTA_prioritize {
			input:
				fastaRawFile = fastaFile,
				SampleName = SampleName
		}

		# For each allele:
		call sub.sub_wf {
			input:
				Fasta = BOTA_prioritize.fastaPrioritizedMin15AAFile,
				Allele_List =  Allele_List,
				Fasta_name = SampleName
		}
	}
}

task BOTA_prioritize {
	File fastaRawFile
	String SampleName

	command <<<
		
		cp ${fastaRawFile} ${SampleName}.fasta
		
		python3 /usr/local/src/bota/BOTA/BOTA_SRC/write_config.py -I ${SampleName}.fasta -O config.file

		python3 /usr/local/src/bota/BOTA/iniBOTA_py3.py --config config.file --genecat ${SampleName}.fasta --outdir output_bota_result_P --candidatefile bota_aa.P.txt -g P

		python3 /usr/local/src/bota/BOTA/iniBOTA_py3.py --config config.file --genecat ${SampleName}.fasta --outdir output_bota_result_N --candidatefile bota_aa.N.txt -g N
		echo "Splitting input fasta according to the prediction"

		python2 /usr/local/src/bota/BOTA/BOTA_SRC/split_fastas.py -p bota_aa.P.txt -n bota_aa.N.txt -a ${SampleName}.fasta -z ${SampleName}.prioritized.fa
		
		readlink -f ${SampleName}.prioritized.fa
		readlink -f bota_aa.N.txt
		readlink -f bota_aa.P.txt

		cat ${SampleName}.prioritized.fa | sed 's/^/#/' | tr -d "\n" | tr ">" "\n" | sed 's/#/ /' | tr -d "#" | tail -n +2 |  awk '{ if(length($2) > 14) {print ">"$1"\n"$2} }' > ${SampleName}.prioritized.min15aa.fa

	>>>

	output {
		File fastaPrioritizedFile = "${SampleName}.prioritized.fa"
		File fastaPrioritizedMin15AAFile = "${SampleName}.prioritized.min15aa.fa"
		File prioritizedN = "bota_aa.N.txt"
		File prioritizedP = "bota_aa.P.txt"

	}

	runtime {
		docker: "plichta/hbota_stepa:02022022"
		bootDiskSizeGb: 25
		cpu: "1"
		disks: "local-disk 75 LOCAL"
		memory: "16 GB"
		preemptible: 2
	}


}


