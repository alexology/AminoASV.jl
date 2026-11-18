using Documenter
using AASV

DocMeta.setdocmeta!(AASV, :DocTestSetup, :(using AASV); recursive=true)

makedocs(;
    modules=[AASV],
    sitename="AASV.jl",
    authors="Alex Laini",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://alexology.github.io/AASV.jl",
        edit_link="main",
    ),
    pages=[
        "Home" => "index.md",
        "Using AASV from Julia" => "guide.md",
        "Ported functions and differences" => "differences.md",
        "VSEARCH read quality" => "vsearch.md",
        "Local checks and provenance" => "development.md",
        "API" => "api.md",
    ],
    checkdocs=:exports,
)

deploydocs(; repo="github.com/alexology/AASV.jl", devbranch="main")
