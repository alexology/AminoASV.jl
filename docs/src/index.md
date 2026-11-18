# AminoASV.jl

Julia implementation of the [aasv](https://github.com/alexology/aasv) pipeline
for the functional analysis of COI ASVs. The scientific formulas are compatible
with R version 0.1.0, commit `9960347948da3142714deb656fcf38124b4e38d8`;
the architecture uses Julia types, dispatch and conventions.

This package is part of an experimental effort to use AI to port
bioinformatics and quantitative ecology packages to Julia, with the goal of
creating a unified environment for high performance scientific computing.

The package was first called `AASV` (versions up to 0.2.0). It is now
`AminoASV` (same UUID, repository `AminoASV.jl`), because the General
registry does not accept names shorter than five characters or written in
capitals, and its version restarts at 0.1.0 for the first registration.
Replace `using AASV` with `using AminoASV`; the function names are
unchanged.

Requires Julia 1.10 or later. Does not require R, Biostrings or DECIPHER.

```powershell
julia --project=. setup.jl
julia -t auto --project=. test/runtests.jl
julia -t auto --project=. examples/offline_pipeline.jl
```

The local example creates FASTA files, codon tables, Excel reports and
`results/demo/analysis/classification.csv`.

To install the version published on GitHub (ProfileAlignments.jl is not
registered, so add it first; `setup.jl` does the same for a local checkout):

```julia
using Pkg
Pkg.develop(url="https://github.com/alexology/ProfileAlignments.jl")
Pkg.develop(url="https://github.com/alexology/AminoASV.jl")
using AminoASV, BioSequences

record = Sequence("COI", dna"ATGCCAGCA")
protein = best_translation(record.sequence)
```

## Pipeline with real data

```julia
using AminoASV, DataFrames, CSV

taxonomy = CSV.read("taxonomy.csv", DataFrame)
# Required columns: family, genus, species.
align_species_seq!(taxonomy; alignment_dir="references",
                   min_length=500, max_length=1000, genetic_code="5")

for family in unique(skipmissing(taxonomy.family))
    problems = check_alignment(family; alignment_dir="references", tax_lev=SpeciesRank)
    improve_alignment!(problems; log_dir="logs")
    dir = joinpath("references", "alignments", family, "species")
    paths = filter(p -> endswith(p, ".fasta"), readdir(dir; join=true))
    filter_divergent_seq!(paths; log_dir="logs", max_distance=0.10)
end

align_genus_seq!(; alignment_dir="references")
align_family_seq!(; alignment_dir="references")
# Records whose insertions open gap columns in most of the merged profile
# are removed and listed in references/logs/gap_causing_references.

asvs = CSV.read("asvs.csv", DataFrame)
# Required columns: family, genus, species, ASV (DNA sequence).
# Additional numeric columns: abundances in the samples.
revised = asv_functional_structure!(asvs;
    alignment_dir="references", output_dir="analysis", genetic_code="5")
verdicts = classify_asv("analysis")
CSV.write("classification.csv", verdicts)
```

`align_genus_seq!` and `align_family_seq!` remove, after each merge, the
records whose insertions open columns that are gaps in most references
(`remove_gap_causing=true`). R aasv merges without this step and relies on
`check_alignment` and `improve_alignment` at each level; `false` reproduces
its merges. A few such records otherwise make every query an indel at that
level: on 9,768 Scarabaeidae references, 44 records (0.45%) made all 34
tested ASVs `INVALID_ORF` at family level; with the removal the results
matched those obtained with the R references.

The package precompiles a small offline analysis, so the first call of
`asv_functional_structure!` in a session does not wait for compilation.

Julia options are passed after `;`. Missing statistical values use `missing`;
an absent result or option uses `nothing`. CSV, Excel and `DataFrame` are
input/output adapters, while the core uses concrete structures. Sequences are
vectors of `Sequence(id, sequence)` with unique names. The `alignment_dir` and
`output_dir` arguments accept Windows, Linux and macOS paths. Use
`overwrite=true` to rebuild references that already exist.
Species rebuilds prepare all outputs before installation, remove obsolete
species files and invalidate that family's genus/family profiles and curation
checkpoints. Rebuild those profiles afterwards with `align_genus_seq!` and
`align_family_seq!`; other families and non-reference files are preserved.
