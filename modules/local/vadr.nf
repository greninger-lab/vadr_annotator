process VADR {
    tag "$meta.id"
    label 'process_high'

    container "quay.io/jefffurlong/vadr"

    input:
        tuple val(meta), path(fasta)
        path(mdir)
        val(mkey)
        path(sbt)

    output:
        tuple val(meta), path("${meta.id}_out"),           emit: vadr_out
        tuple val(meta), path("${meta.id}_out.vadr.tbl"),  emit: tbl
        tuple val(meta), path("${meta.id}.gbf"),           emit: gbf
        tuple val(meta), path("${meta.id}.fsa"),           emit: fsa
    

    shell:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = ""
    switch("${mkey}") {
        case "hmpv":
        case "hpiv1":
        case "hpiv2":
        case "hpiv3":
        case "hpiv4":
            args = "${task.ext.args1}"
            break
        case "229E":
        case "NL63":
            args = "${task.ext.args2}"
            break
        case "HKU1":
            args = "${task.ext.args3}"
            break
        case "OC43":
            args = "${task.ext.args4}"
            break             
        case "hsv":
            args = "${task.ext.args_hsv}"
            break
    }

    """
    #mv ${meta.id}.fasta ${meta.id}_untrimmed.fasta
    awk '/^>/ {print \$0 " [moltype=mRNA]"; next} {gsub("U", "T"); print}' ${fasta} > ${meta.id}_untrimmed.fasta
    /opt/vadr/vadr/miniscripts/fasta-trim-terminal-ambigs.pl --minlen 50 --maxlen 1800000 ${meta.id}_untrimmed.fasta > ${meta.id}.fasta
    v-annotate.pl --mdir ${mdir} --mkey ${mkey} ${args} ${meta.id}.fasta ${meta.id}_out
    cat ${meta.id}_out/${meta.id}_out.vadr.pass.tbl ${meta.id}_out/${meta.id}_out.vadr.fail.tbl > ./temp.${meta.id}_out.vadr.tbl
    sed -n '/Additional note/q;p' ./temp.${meta.id}_out.vadr.tbl > ./${meta.id}_out.vadr.tbl
    rm ./temp.${meta.id}_out.vadr.tbl
    #awk '/^>/ {print \$0 " [moltype=mRNA]"; next} {gsub("U", "T"); print}' ${meta.id}.fasta > ${meta.id}.fsa
    cp ${meta.id}.fasta ${meta.id}.fsa
    table2asn -t ${sbt} -f ${meta.id}_out.vadr.tbl -V vb -i ${meta.id}.fsa  -o ${meta.id} || true

    """
}
