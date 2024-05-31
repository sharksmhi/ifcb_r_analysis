## MATLAB data package description

### Raw data files

These are raw IFCB data files from manually classified samples. The filenames indicate the date and time (in UTC) of sample collection, as well as the IFCB serial number used.

- *.roi: raw image data stored as a binary stream
- *.adc: analog-to-digital converter data from sensors for each event, and location pointers for each event's image data
- *.hdr: instrument settings information similar to those contained in the configuration file, as well as a key to the format of the .adc file

### .mat files

#### config/class2use.mat

- class2use: list of all manual classes used for manual image classification. The classes are sorted by manual classification id.

#### manual/*.mat

- class2use_auto: list of all classes from automatic image classification
- class2use_manual: list of all manual classes from config/class2use.mat. The classes are sorted by manual classification id.
- classlist: matrix containing information on roi number, manual classification id and automatic classification (see list_titles)
- default_class_original: default manual class
- list_titles: titles of classlist

### v2 Feature File Content Description (features/*.csv)

Features are described as in https://github.com/hsosik/ifcb-analysis/wiki/Feature-File-Documentation

#### Fea v2 label: Description (Units)

- roi_number: Region of interest (ROI) number (NA)
- Area: Cross-sectional area of largest blob in ROI (squared pixels)
- Biovolume: Volume estimate for the largest blob (cubed pixels)
- BoundingBox_xwidth: Width of smallest rectangle containing largest blob along x-axis (pixels)
- BoundingBox_ywidth: Height of smallest rectangle containing largest blob along y-axis (pixels)
- ConvexArea: Area of smallest convex polygon containing largest blob (squared pixels)
- ConvexPerimeter: Perimeter of smallest convex polygon containing largest blob (pixels)
- Eccentricity: Eccentricity of ellipse with same second-moments as largest blob (0=circle, 1=line) (dimensionless)
- EquivDiameter: Diameter of circle with same area as largest blob (pixels)
- Extent: Area divided by area of bounding box (dimensionless)
- FeretDiameter: INCORRECT in v2; maximum distance between any two boundary points of largest blob (pixels)
- H180: Hausdorff distance between largest blob and itself after 180-degree rotation along major axis (pixels)
- H90: Hausdorff distance between largest blob and itself after 90-degree rotation along major axis (pixels)
- Hflip: Hausdorff distance between largest blob and itself after reflection across major axis (pixels)
- MajorAxisLength: Length of major axis of ellipse with same normalized second central moment as region (pixels)
- MinorAxisLength: Length of minor axis of ellipse with same normalized second central moment as region (pixels)
- Orientation: Angle between x-axis and major axis of ellipse with same second-moments as blob (degrees)
- Perimeter: Distance around boundary of largest blob (pixels)
- RWcenter2total_powerratio: Relative power in central radial wedge (NA)
- RWhalfpowerintegral: Integral of power in half radial wedge (NA)
- Solidity: Proportion of pixels in convex hull also in largest blob (Area/ConvexArea) (dimensionless)
- moment_invariant1 to moment_invariant7: First to seventh moment invariant for shape indication (NA)
- numBlobs: Number of separate connected blobs in ROI (NA)
- shapehist_kurtosis_normEqD: Kurtosis of shape histogram (NA)
- shapehist_mean_normEqD: Mean of shape histogram (NA)
- shapehist_median_normEqD: Median of shape histogram (NA)
- shapehist_mode_normEqD: Mode of shape histogram (NA)
- shapehist_skewness_normEqD: Skewness of shape histogram (NA)
- summedArea: Area summed for all blobs (squared pixels)
- summedBiovolume: Biovolume summed for all blobs (cubed pixels)
- summedConvexArea: ConvexArea summed for all blobs (squared pixels)
- summedConvexPerimeter: ConvexPerimeter summed for all blobs (pixels)
- summedFeretDiameter: INCORRECT in v2; FeretDiameter summed for all blobs (pixels)
- summedMajorAxisLength: MajorAxisLength summed for all blobs (pixels)
- summedMinorAxisLength: MinorAxisLength summed for all blobs (pixels)
- summedPerimeter: Perimeter summed for all blobs (pixels)
- texture_average_contrast: Average contrast of pixel gray levels inside blob after brightness adjustment (NA)
- texture_average_gray_level: Average gray level of pixels inside blob after brightness adjustment (NA)
- texture_entropy: Entropy of pixel gray levels inside blob after brightness adjustment (NA)
- texture_smoothness: Smoothness measure of pixel gray levels inside blob after brightness adjustment (NA)
- texture_third_moment: Normalized third moment pixel gray levels inside blob after brightness adjustment (NA)
- texture_uniformity: Uniformity measure of pixel gray levels inside blob after brightness adjustment (NA)
- RotatedArea: Area of largest blob after rotation to align major axis along x-axis (squared pixels)
- RotatedBoundingBox_xwidth: Width of smallest rectangle containing largest blob after rotation (pixels)
- RotatedBoundingBox_ywidth: Height of smallest rectangle containing largest blob after rotation (pixels)
- Wedge01 to Wedge48: Relative power in sequential radial wedges in frequency space (dimensionless)
- Ring01 to Ring50: Relative power in sequential concentric rings in frequency space (dimensionless)
- HOG01 to HOG81: Sequential elements of Histogram of Oriented Gradients for ROI (NA)
- Area_over_PerimeterSquared: Area divided by squared Perimeter (NA)
- Area_over_Perimeter: Area divided by Perimeter (NA)
- H90_over_Hflip: H90 divided by Hflip (NA)
- H90_over_H180: H90 divided by H180 (NA)
- Hflip_over_H180: Hflip divided by H180 (NA)
- summedConvexPerimeter_over_Perimeter: summedConvexPerimeter divided by Perimeter (NA)
- rotated_BoundingBox_solidity: solidity of the bounding box for the blob after rotation to horizontally align the major axis (NA)
