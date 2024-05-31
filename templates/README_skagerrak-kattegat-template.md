## General information

Author: Anders Torstensson, Ann-Turi Skjevik, Malin Mohlin, Maria Karlberg, Bengt Karlson
Contact e-mail: <E-MAIL>
DOI: 10.17044/scilifelab.25883455
License: CC BY 4.0
This readme file was last updated: <DATE>

Please cite as: Torstensson, Anders; Skjevik, Ann-Turi; Mohlin, Malin; Karlberg, Maria; Karlson, Bengt (<YEAR>). SMHI IFCB plankton image reference library. SciLifeLab. Dataset. https://doi.org/10.17044/scilifelab.25883455

## Dataset description

This dataset includes manually annotated plankton images by phytoplankton experts at the Swedish Meteorological and Hydrological Institute (SMHI). These images can be used for training classifiers to identify various plankton species. The images were captured using an Imaging FlowCytobot (IFCB, McLane Research Laboratories) from different locations and seasons in the Skagerrak and Kattegat. Images were gathered during monthly monitoring cruises from <YEAR_START> to <YEAR_END>, utilizing an IFCB mounted as part of the underway FerryBox system on the R/V Svea. This collection consists of <N_IMAGES> annotated images across <CLASSES> different classes.

## Available data

There are two zip-packages available from this dataset:

<IMAGE_ZIP> - contains .png images that are manually annotated and organized into subfolders for each class

<MATLAB_ZIP> - includes raw data files (.roi, .hdr, .adc) and MATLAB files for creating an image classifier using the code available at https://github.com/hsosik/ifcb-analysis
