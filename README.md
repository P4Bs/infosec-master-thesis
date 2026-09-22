# Infosec Master Thesis

## Repository contents

- **`main.tex`** — main LaTeX source of the thesis document.
- **`bibliography.bib`** — bibliography references (BibLaTeX/Biber).
- **`tfm-style-guide.sty`** — style package used to format the document.
- **`Portada_TFM.doc`** / **`portada_tfm.pdf`** — cover page, embedded into the final PDF via `\includepdf`.
- **`images/`** — figures referenced in the document.
- **`latest-version/main.pdf`** — latest compiled version of the document, available without building the project.
- **`splint-cwe-analysis/`** — analysis scripts, organized by CWE.
- **`post-process-scripts/`** — result post-processing scripts.
- **`src/`** — auxiliary code, not required to compile the document.

## How to compile the document

The document is built with **LaTeX + Biber** (BibLaTeX backend). `latexmk` is recommended, but manual compilation also works.

### Requirements

- A TeX distribution (TeX Live or MiKTeX) with the following packages: `graphicx`, `txfonts`, `amssymb`, `float`, `titlesec`, `listings`, `dsfont`, `fontenc`, `pdfpages`, `longtable`, `booktabs`, `pdflscape`, `csquotes`, `hyperref`, `biblatex`, and `biber`.

### Option 1: `latexmk` (recommended)

```bash
latexmk -pdf -bibtex-cond main.tex
```

### Option 2: manual

```bash
pdflatex main.tex
biber main
pdflatex main.tex
pdflatex main.tex
```

The output is `main.pdf` in the project root. A copy of the latest compiled version is already available at [`latest-version/main.pdf`](latest-version/main.pdf).
