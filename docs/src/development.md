# Local checks and provenance

## Local checks

The tests cover FASTA, translation, gaps, alignment cleaning, distances, Phred
quality, FI, simulated BOLD retries and the complete offline pipeline.
The optional comparison with R checks every numeric column and the class
across eight scenarios, as well as translation, hydrophobicity and genetic
codes:

```powershell
julia --project=. test/parity.jl 'C:\Program Files\R\R-4.5.0\bin\Rscript.exe'
```

This check requires R with `dplyr`, `readxl`, `Biostrings`, `Peptides` and the
original sources under `reference/aasv` (or an alternative path as the second
argument). Normal use and the Julia tests do not require R.
The included CI runs the tests on Windows and Linux, with Julia 1.10 and the
stable release. The alignment package also has its own suite, which can be
run on its own:

```powershell
julia --project=../ProfileAlignments.jl -e 'using Pkg; Pkg.test()'
```

## Provenance

This port derives from [aasv](https://github.com/alexology/aasv), by Alex
Laini, Samuele Voyron and Laura Gruppuso, distributed under GPL >=2. This port
is also distributed under GPL >=2. The Grantham table comes from the
[grantham](https://github.com/patterninstitute/grantham) package, MIT licence;
see `THIRD_PARTY_NOTICES.md`. The copies of the original repositories in
`reference/` are local comparison material and are excluded from Git.
