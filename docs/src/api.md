# API

```@meta
CurrentModule = AASV
```

```@docs
AASV
```

## Reference profiles

```@docs
align_family_seq
align_family_seq!
align_genus_seq
align_genus_seq!
align_species_seq
align_species_seq!
select_shard
```

## Reference checks

```@docs
check_alignments!
check_reference_records
filter_divergent_references!
```

## Alignment and curation

```@docs
align_profiles
align_sequences
check_alignment
filter_divergent_seq
filter_divergent_seq!
improve_alignment
improve_alignment!
re_align
re_align!
```

## ASV structure and mutations

```@docs
ASVAssessment
ASVInvalidORF
ASVStatus
ASVValid
HydrophobicityMetrics
InvalidORF
MutationObservation
StructuralVerdict
StructureAssessment
StructureFail
StructurePass
StructureUnavailable
assess_asv
assess_structure
asv_functional_structure
asv_functional_structure!
calculate_asv_distance
check_asv_structure
get_hydro_metrics
```

## Classification

```@docs
ClassificationConfig
classify_asv
```

## Translation and similarity

```@docs
Translation
aa_similarity_matrix
aa_table
best_translation
codon_similarity_matrix
find_translation
```

## Taxonomic ranks

```@docs
FamilyRank
GenusRank
SpeciesRank
TaxonomicRank
```

## Shared with ProfileAlignments.jl

Sequences, alignments and FASTA files are those of
[ProfileAlignments.jl](https://github.com/alexology/ProfileAlignments.jl),
re-exported by AASV, so `using AASV` is enough:

- `Alignment(records; weights)`: rectangular alignment of `Sequence`
  records, with names, order and normalized positive sequence weights.
- `read_fasta(path)`: read a FASTA file (FASTX.jl) keeping full headers,
  record order and gap columns; malformed files raise an `ArgumentError`.
- `write_fasta(records_or_alignment, path; width = 80)`: write `Sequence`
  records or an `Alignment`; empty sequences are rejected before the file
  is created or truncated.

```@docs
Sequence
ScoringModel
```
