#!/usr/bin/env nextflow

nextflow.enable.dsl=2
// Header log info

def all_params =  params.collect{ k,v -> "$k=$v" }.join(", ")

def summary = [:]

if (workflow.revision) summary["Pipeline Release"] = workflow.revision

summary["Max Resources"]                  = "$params.max_memory memory, $params.max_cpus cpus, $params.max_time time per job"
summary["Output dir"]                     = params.outdir
summary["Launch dir"]                     = workflow.launchDir
summary["Working dir"]                    = workflow.workDir
summary["Script dir"]                     = workflow.projectDir
summary["User"]                           = workflow.userName

summary["outdir"]                         = params.outdir

log.info summary.collect { k,v -> "${k.padRight(18)}: $v" }.join("\n")
log.info "-\033[2m--------------------------------------------------\033[0m-"


/*--------------------------------------------------
    Channel setup
---------------------------------------------------*/
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

process report {
container 'hsyed91/rpackages:latest'
        label "process_medium"
        label "report"
        publishDir "${params.outdir}/results", mode: "copy"

        input:
        file(report_dir) from ch_report_dir
 file(demographics) from demographics_channel
 file(mortality) from mortality_channel
 file(diagnosis) from diagnosis_channel
    val date_var
    val group_var
    val market
    val tumor
    val delivery 


        output:
        file "output.html"

        script:
        """
docker run -v $PWD:/data hsyed91/rpackages:latest Rscript -e "library(rmarkdown); \
params <- list(demographics='/data/${demographics}', mortality='/data/${mortality}', diagnosis='/data/${diagnosis}', date_var='${date_var}', group_var='${group_var}', market='${market}', tumor='${tumor}', delivery='${delivery}'); \
rmarkdown::render('/app/CLQA_markdown.Rmd', output_file='/data/output.html', params=params)"

        """
    }

workflow {
ch_report_dir = Channel.value(file("${project_dir}/bin/report"))
demographics_channel = Channel.fromPath(params.demographics)
    mortality_channel = Channel.fromPath(params.mortality)
   diagnosis_channel = Channel.fromPath(params.diagnosis)
  date_var_channel = Channel.value(params.date_var)
  group_var_channel = Channel.value(params.group_var)
    market_channel = Channel.value(params.market)
    tumor_channel = Channel.value(params.tumor)
    delivery_channel = Channel.value(params.delivery)

    report( demographics_channel,mortality_channel,diagnosis_channel,date_var_channel,group_var_channel,market_channel,tumor_channel,delivery_channel)
}

