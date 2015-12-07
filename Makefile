README.md: README.Rmd
	Rscript -e "knitr::knit('README.Rmd')"

all: README.md
