#!/usr/bin/env bash

cp -r ${1}/* .

Rscript -e "rmarkdown::render(
    'report.Rmd',
    params = list(demographics='/data/${demographics}', mortality='/data/${mortality}', diagnosis='/data/${diagnosis}', date_var='${date_var}', group_var='${group_var}', market='${market}', tumor='${tumor}', delivery='${delivery}')
)"
mv report.html multiqc_report.html
