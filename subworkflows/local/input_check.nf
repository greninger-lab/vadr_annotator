//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_fasta_channel(it) }
        .set { fasta }

    emit:
    fasta                                     // channel: [ val(meta), [ fasta ] ]
}

// Function to get list of [ meta, [ fasta ] ]
def create_fasta_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.sample

    // add path(s) of the fastq file(s) to the meta map
    def fasta_meta = []
    if (!file(row.fasta).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> FASTA file does not exist!\n${row.fasta}"
    }

    fasta_meta = [ meta, [ file(row.fasta) ] ]

    return fasta_meta
}
