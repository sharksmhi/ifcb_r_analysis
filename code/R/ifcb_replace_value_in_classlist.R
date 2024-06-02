library(tidyverse)
library(reticulate)

# Setup virtual environment
virtualenv_create("code/python/venv", requirements = "code/python/requirements.txt")
use_virtualenv("code/python/venv")

# Now try to import the python function
source_python("code/python/replace_value_in_classlist.py")

# Define which classifier you are working on
classifier <- "Tångesund"

# List files to be updated
files <- list.files(file.path("output/manual", classifier))

for (i in 1:length(files)) {
  replace_value_in_classlist(file.path("output/manual", classifier, files[i]),  # Ensure correct file path
                             file.path("output/manual", classifier, files[i]),
                             999,
                             19)  # Ensure correct output file path)
}
