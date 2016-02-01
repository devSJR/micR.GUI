====
micR.GUI is a script to build a graphical user interface for RKWard
Process image data for the enumeration of fluorescent image cells

micR.GUI requires a working installation of EBimage from Bioconductor and further packages from CRAN. EBImage is a very powerful image processing and analysis toolbox for R. The installation instructions are available at
http://bioconductor.org/packages/release/bioc/html/EBImage.html

# Installation

You can install the latest development version of the code using the `devtools` R package.

```R
# Install devtools, if you haven't already.

## try http:// if https:// URLs are not supported
source("https://bioconductor.org/biocLite.R")
biocLite("EBImage")

# Install the devtools package
install.packages("devtools")
library(devtools)

# Install the micR from github
install_github("devSJR/micR")

