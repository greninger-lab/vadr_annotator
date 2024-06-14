process VADR {
    tag "$meta.id"
    label 'process_high'

    container "docker.io/jefffurlong/vadr"

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
    """
    v-annotate.pl --mdir ${mdir} --mkey ${mkey} ${task.ext.args} ${meta.id}.fasta ${meta.id}_out
    cat ${meta.id}_out/${meta.id}_out.vadr.pass.tbl ${meta.id}_out/${meta.id}_out.vadr.fail.tbl > ./temp.${meta.id}_out.vadr.tbl
    sed -n '/Additional note/q;p' ./temp.${meta.id}_out.vadr.tbl > ./${meta.id}_out.vadr.tbl
    rm ./temp.${meta.id}_out.vadr.tbl
    cp ${meta.id}.fasta ${meta.id}.fsa
    table2asn -t ${sbt} -f ${meta.id}_out.vadr.tbl -V vb -i ${meta.id}.fasta  -o ${meta.id} || true

    """
}
