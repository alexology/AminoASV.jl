# Ported functions and differences

## Ported functions

| Function | Operation |
|---|---|
| `aa_similarity_matrix` | 4096 codon pairs with Hamming similarity |
| `align_species_seq!` | BOLD COI-5P download, filters, translation, alignments |
| `align_genus_seq!`, `align_family_seq!` | progressive profile merging |
| `check_alignment` | paths of alignments with internal gaps |
| `check_alignments!` | check of all families with persistent results |
| `filter_divergent_references!` | per-family filter with resume and persistent reports |
| `re_align!` | realignment, optionally from the original FASTA files |
| `improve_alignment!` | iterative removal of problematic sequences, with logs |
| `filter_divergent_seq!` | nearest-neighbour distance filter |
| `asv_functional_structure!` | ASV analysis at the three taxonomic levels |
| `classify_asv` | FI index, class, evidence and intermediate metrics |

Also available: `read_fasta`, `write_fasta`, `best_translation`, `aa_table`,
`align_sequences`, `align_profiles`, `calculate_asv_distance`,
`get_hydro_metrics` and `check_asv_structure`. `?function_name` shows the
documentation in Julia.

## Compatibility and differences

- The FI formula, the weights (0.35/0.30/0.35), the 0.90 threshold, the quality
  filter, the normalised entropy and the conservation discount
  `1-exp(-n_ref/20)` follow the R code. Grantham distances use the original
  table, not an approximation. Hydrophobicity uses the Kyte–Doolittle scale.
- Alignment uses the independent
  [ProfileAlignments.jl](https://github.com/alexology/ProfileAlignments.jl) package, installed
  as a sibling project and written entirely in Julia:
  BLOSUM62, affine gaps (`gap_open=-10`, `gap_extend=-1`), k-mer distances,
  guide tree, two progressive passes and iterative refinement.
  Terminal gaps are free; ASV queries are inserted into the profile with
  `mode=:query`. `anchors=:fft` enables the approximate FFT acceleration,
  while the default uses full dynamic programming.
  The previous linear-penalty engine has been replaced.
  It does not reproduce DECIPHER or MAFFT: coordinates, gaps, mutations and FI
  may differ. Biological validation on real benchmarks is still required.
- `Sequence`, `best_translation` and the protein metrics accept BioSequences
  types directly (`LongDNA`, `LongAA` and the `dna"..."`, `aa"..."` literals).
  The pipeline converts these inputs once into the internal ASCII encoding,
  keeping compatibility with the files and with the string API.
- DECIPHER-specific arguments (for example `processors`, `terminalGap`) do not
  carry over directly; use the Julia parameters listed above. The previous
  arguments `match`, `mismatch` and `gap` are still accepted: `gap` sets a
  linear penalty.
  The filter distance is the fraction of differing residues in the
  intersection of the covered regions, excluding terminal gaps.
- Built-in genetic codes: the 20 codes of the Biostrings table used in the R
  comparison (1–6, 9–16, 21–26), without reinterpreting start codons. For
  other codes, pass a complete codon→amino acid dictionary.
  IUPAC bases that translate unambiguously produce the corresponding residue;
  otherwise `X`. Translation searches only the three forward frames, ignores
  the incomplete terminal codon and does not search the reverse complement.
- Identical profiles are deduplicated for the structural analysis, as in R.
  When restoring an entirely problematic alignment without an external
  reference, the first sequence is kept deterministically, whereas R picks
  one at random.
- BOLD is read through the paginated API, even for small families. Retries
  keep the backoff state; permanent HTTP 4xx errors stop the download
  immediately. A `.complete` marker prevents a directory created during a
  failed download from being treated as complete. Downloaded pages are saved
  to `alignment_dir/bold_downloads/<family>` only once fully received. With
  `overwrite=false`, a rerun reuses the local pages and requests only the
  missing pages of the same query; `overwrite=true` starts a new query without
  mixing pages from different downloads. The cache is kept after completion.
  If BOLD no longer serves the saved query, restart with `overwrite=true`.
  For local data, pass `records_provider=family -> records` to
  `align_species_seq`.
- The analysis also records comparisons without mutations or whose
  hydrophobicity cannot be computed, so no ASV is lost from the reports. When
  the hydrophobicity metric is missing, its FI contribution is zero, as in R;
  the report contains `UNAVAILABLE`. A stop codon or an incompatible gap
  produces the sentinel `aa_pos=-1` and an FI of zero.
- Reports keep the main names and columns of the R version.
  `classify_asv` reads Excel or TSV. Re-running the pipeline replaces the
  previous reports in the `aa_structure_results` directory.

The FI index measures compatibility with the evolution of functional COI;
it is neither a probability nor a diagnosis of NUMT/mitochondrial origin.
