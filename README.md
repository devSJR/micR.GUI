====
micR.GUI is a script to build a graphical user interface for RKWard
Process image data for the enumeration of fluorescent image cells

micR.GUI requires a working installation of EBimage from Bioconductor and further packages from CRAN. EBImage is a very powerful image processing and analysis toolbox for R. The installation instructions are available at
http://bioconductor.org/packages/release/bioc/html/EBImage.html

# Installation

You can install the latest development version of the code using the `devtools` R package.

```R
# Install devtools, if you haven't already.
install.packages("devtools")
library(devtools)

install_github("devSJR/micR")

