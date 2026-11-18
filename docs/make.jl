using Documenter
using AminoASV

DocMeta.setdocmeta!(AminoASV, :DocTestSetup, :(using AminoASV); recursive=true)

makedocs(;
    modules=[AminoASV],
    sitename="AminoASV.jl",
    authors="Alex Laini",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://alexology.github.io/AminoASV.jl",
        edit_link="main",
    ),
    pages=[
        "Home" => "index.md",
        "Using AminoASV from Julia" => "guide.md",
        "Ported functions and differences" => "differences.md",
        "VSEARCH read quality" => "vsearch.md",
        "Local checks and provenance" => "development.md",
        "API" => "api.md",
    ],
    checkdocs=:exports,
)

deploydocs(; repo="github.com/alexology/AminoASV.jl", devbranch="main")
