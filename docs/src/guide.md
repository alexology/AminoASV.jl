# Using AASV from Julia

## Julia API

`Sequence` is the same type exported by `ProfileAlignments`: alignments no
longer copy each record between two domain representations. The typed
translation returns a single result type:

```julia
translation = find_translation(dna"ATGCCAGCA")
if !isnothing(translation)
    translation.amino_acids
    translation.frame
end
```

`assess_structure` and `assess_asv` return `StructureAssessment` and
`ASVAssessment` respectively; amino acid differences are `MutationObservation`
values. These APIs compose the computation in memory without creating
intermediate tables. `check_asv_structure` and `calculate_asv_distance` keep
the tabular output for the existing reports.

Taxonomic options accept `SpeciesRank`, `GenusRank` and `FamilyRank`.
A reusable FI policy is represented by an immutable value:

```julia
policy = ClassificationConfig(quality_threshold=0.995,
                              include_hydro=false)
verdicts = classify_asv("analysis", policy)
```

Functions that modify files or directories end with `!`:
`align_species_seq!`, `align_genus_seq!`, `align_family_seq!`, `re_align!`,
`improve_alignment!`, `filter_divergent_seq!` and
`asv_functional_structure!`. The previous names remain as adapters for
compatibility with existing code.

`filter_divergent_seq!` reports progress over files and, every 5 seconds,
over the sequence comparisons in the current file. To show it even with
`print_messages=false`, pass `show_progress=true`; the frequency is set with
`progress_interval` (in seconds).
The distance computation works directly on the bytes of the ASCII sequences,
without copying rows for each pair, and precomputes the gap-free ends. Identical
sequences share their comparisons while keeping all the original identifiers.
Distances and removal rules remain exact, including cases with no overlap or
with gaps only. The gain grows with the number of duplicates; when all
sequences differ, the maximum number of comparisons remains quadratic.

To process all families without writing loops in the script:

```julia
species_bad = check_alignments!(; alignment_dir=reference_dir,
    tax_lev=SpeciesRank)
isempty(species_bad) || improve_alignment!(species_bad)

# After the fix, only the modified families are checked again.
species_still_bad = check_alignments!(; alignment_dir=reference_dir,
    tax_lev=SpeciesRank)

filter_divergent_references!(; alignment_dir=reference_dir,
    tax_lev=SpeciesRank, max_distance=0.10)
```

Both functions discover the families and skip directories without FASTA files.
`families=["FamilyA", "FamilyB"]` restricts the selection. `resume=true`
(default) reuses the results saved in `alignment_dir/checkpoints` only if the
file names and SHA-256 contents, the parameters and the algorithm version all
match. New downloads, added or removed files and realignments also invalidate
the results when the content changes. `resume=false` forces a new run.

On a cluster, `align_species_seq!`, `align_genus_seq!`, `align_family_seq!`,
`check_alignments!` and `filter_divergent_references!` accept
`shard_index` and `shard_count`. Families are sorted and partitioned
deterministically, without overlaps. For example, an 8-element job array
uses `shard_index=task_id, shard_count=8`. Jobs may share `alignment_dir`,
because each shard writes distinct families and checkpoints; downloads or
unsharded runs must not be started in parallel on the same files.

`asv_functional_structure!` instead uses dynamic tasks within the node and
accepts `threads=:auto` or an integer limit. ASV computations run in parallel
in batches bounded by the number of threads, while the aggregated reports are
assembled in the same order as the input.
Each reference profile and its nucleotide references are read once per run
and released after the last ASV of the family; reference codons are
translated only at novel residues.

`asv_functional_structure!` also reads reference sets built by earlier aasv
versions. Exact repeats of a record (same ID and sequence) are ignored; an ID
repeated with a different sequence is an error. Profile records without a
nucleotide reference in the taxon cannot be checked codon by codon and are
excluded, together with the columns left with gaps only. This removes, for
example, the `Canthonidia` species that an earlier R version merged into the
`Canthon` genus profile. Both cases are reported once per file with a warning. The other functions
that read references (`check_alignment`, `improve_alignment!`, `re_align!`,
`filter_divergent_seq!` and the genus/family merges) also ignore exact
repeats, and a family merge keeps a species found in two genus profiles once.
`check_reference_records(; alignment_dir)` lists these records in a table
before an analysis:

```julia
issues = check_reference_records(; alignment_dir="references")
```

Genus and family profiles can be rebuilt with `overwrite=true`. Species
alignments with altered IDs need `align_species_seq!(overwrite=true)`:
realigning them from `raw_sequences` would restore records removed by earlier
curation.
`check_alignments!` also returns the problematic paths of reused families;
it additionally supports `GenusRank`, `FamilyRank` and `type="raw_sequences"`.

The filter records the file fingerprints **after** modification and stores the
summary of removed sequences in the checkpoints. Per-family reports are
written to `alignment_dir/logs/divergent_references/<level>/<family>.tsv`
(customisable with `log_dir`, or disabled with `log_dir=nothing`).
Resumed runs do not duplicate report rows. Outputs are prepared before the
FASTA files are replaced: an interrupted replacement can be completed on the
next run without repeating the filter. If the interruption happens during the
computation, the family in progress is recomputed; completed families are
reused. Staging files remain available in case of interruption. The filter
works on the current files: a less restrictive threshold does not restore
previously removed sequences; to do that, regenerate the references.
`show_progress=false` disables the progress messages.

By default, `align_species_seq!` reports the families processed or reused,
progress through BOLD pages, filtering, and the species being aligned with its
number of sequences. Pass `show_progress=false` to disable these messages;
`progress_interval` controls updates during filtering. Alignment messages are
emitted before each species.
Independent species of the same family are aligned in batches with tasks from
the separate `ProfileAlignments` package; each batch is limited to the number
of available threads to bound memory use and avoid nested parallelism.
Alignment algorithms, presets and numerical structures live in the
`ProfileAlignments` package; AASV handles downloads, taxonomy and files.

`align_genus_seq!` and `align_family_seq!` report the families and taxa
processed or reused, the number of sequences in the profiles to merge, the
completed merges with the percentage for the current taxon, and the final time.
Updates are emitted before and after each merge; `show_progress=false`
disables them.
