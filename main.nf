#!/usr/bin/env nextflow

nextflow.enable.dsl=2

project_dir = workflow.projectDir
run_date = new java.text.SimpleDateFormat("yyyy_MM_dd").format(new Date())
params.demographics = 'input1.csv'
params.mortality = 'input2.csv'
params.diagnosis = 'input3.csv'
params.market = 'default_market'
params.tumor = 'default_tumor'
params.delivery = 'default_delivery'
params.outdir = 'results'
params.date_var = 'metdiagnosisdate'
params.group_var = 'ethnicity'

process runRMarkdown {
container 'hsyed91/rpackages:latest'
label "runRMarkdown"
publishDir "${params.outdir}", mode: "copy"
input:
    path demographics
    path mortality
    path diagnosis
    val date_var
    val group_var
    val market
    val tumor
    val delivery

    output:
    path 'output.html'

    script:
   """
   Rscript -e "library(rmarkdown); \
        params <- list(demographics='/data/${demographics}', mortality='/data/${mortality}', diagnosis='/data/${diagnosis}', date_var='${date_var}', group_var='${group_var}', market='${market}', tumor='${tumor}', delivery='${delivery}'); \
        rmarkdown::render('/app/CLQA_markdown.Rmd', output_file='/data/output.html', params=params, output_dir='.')"
    """
}

workflow {
    demographics_channel = Channel.fromPath(params.demographics)
    mortality_channel = Channel.fromPath(params.mortality)
   diagnosis_channel = Channel.fromPath(params.diagnosis)
  date_var_channel = Channel.value(params.date_var)
  group_var_channel = Channel.value(params.group_var)
    market_channel = Channel.value(params.market)
    tumor_channel = Channel.value(params.tumor)
    delivery_channel = Channel.value(params.delivery)

    runRMarkdown( demographics_channel,mortality_channel,diagnosis_channel,date_var_channel,group_var_channel,market_channel,tumor_channel,delivery_channel)
}
