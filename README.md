![LOGO](Logo_Metexplore.png)
# FingerprintClustering

Version: 3.1

## Short description
Performs unsupervised clustering among a metabolic network from a fingerprint

## Description
Calculates shortest distances between metabolites in a (human) metabolic network (Recon v2.02). These distances are used by an unsupervised algorithm to classify each metabolites in a given cluster (i.e., sub-network). The optimal number of clusters is determined automatically by the Silhouette's index (Rousseeuw, 1987).


### Input files
- a ```fingerprint``` (tsv or tabular format): required, composed by at least a column containing identifier values to map on the network file. Multi-mapping (i.e., mapping on different identifier) could be performed if these three kind of values are included each in a separate column. Optionally, this program could filter empty values from a designated column (e.g., non-significant bio-entities after a statistical pre-selection). This tool is part of the MetExplore's project consisting in a web server dedicated to the analysis of omics data in the context of genome scale metabolic networks (Cottret et al., 2018).
- a ```metabolic network``` (SBML) : optional, by default Recon v2.03 SBML file (without compartments) (Thiele et al., 2013).

### Output files

##### Default mode 

- ```heatmap.pdf``` : distance matrix between individuals colored by a gradient of color (from minimal distance, in red, to maximum distance, in blank). In case of hierarchical clustering, the individuals are ranked according to dendrogram result. In case of clustering by partitioning (or in advanced mode), they are ordered by silhouette's score.
- ```optimum_silhouette.pdf```: best clustering according to Silhouette's index (x: number of clusters; y: average width of silhouette).
- ```silhouette.pdf```: for the best clustering (determined above), the Silhouette's index for each individuals and for each cluster.
- ```pca.pdf```: individuals projection in the two (could be customized) first axis of a PCA. Individuals are colorized according to their belonging to each clusters. Each clusters is represented by a centroid and an elliptical dispersion. 
- ```summary.tsv``` : for each number of clusters, the column contain the bewteen- and the (sum of the ) within inertia, the between-inertia differences with the previous partition, the average silhouette width.
- ```cluster.tsv``` : the first column contains the name of the individuals (ranked by silhouette's score), the second, the numerical identifier of their cluster, the third and the fourth, their pca coordinates on the first two axis, the last one contains their silhouette's index.

#####Advanced mode 
- ```elbow.pdf``` : best clustering according to the between inertia loss per partition (x: number of clusters; y: relative within inertia). 
- ```gap.pdf``` : best clustering according to the the gap statistic (see below; x: number of clusters; y: within inertia gap). The best partition is the grater gap statistic in comparison to the gap statistic and its standard deviation from the next partitioning. 
- ```log_w_diff.pdf``` : differences between the within-inertia log from the dataset and from a random bootstrap, also called gap statistic.
- ```contribution.pdf``` :  contribution of each columns to the inertia of each clusters for the optimal partioning
- ```discriminant_power.pdf``` :  contribution of each columns to the inertia of each partitioning
- ```within.tsv``` : within inertia of each clusters of each partioning


## Key features
- Metabolic network
- Modeling
- Clustering
- Prediction

## Functionality
- Post-processing
- Statistical Analysis

## Tool Authors
- MetExplore Group contact-metexplore@inra.fr

## Container Contributors
- Etienne Camenen (INRA Toulouse)

## Git Repository
- https://github.com/phnmnl/container-pathwayEnrichment.git

## Installation
For local installation of the container:
```
docker pull docker-registry.phenomenal-h2020.eu/phnmnl/fingerprintclustering
```

## Usage Instructions
For direct usage of the docker image:

```
docker run docker-registry.phenomenal-h2020.eu/phnmnl/fingerprintclustering -i <input_file>
```

With optional parameters:

```
docker run docker-registry.phenomenal-h2020.eu/phnmnl/fingerprintclustering --infile <input_file> [--sbml <sbml_file>] [--help] [--version] [--verbose] [--quiet] [--header] [--separator <separator_charachter>] [--classifType <classif_algorithm_ID>] [--distance <distance_type_ID>] [--maxClusters <maximum_clusters_number] [--nbClusters clusters_numbers] [--nbAxis <axis_number>] [--text] [--advanced]
```

##### Execution parameters
- ```-h (--help)``` print the help.
- ```-v (--version)``` prints the tool's version.
- ```--verbose``` activates "super verbose" mode (to survey long run with big data; specify ongoing step).
- ```-q (--quiet)``` activates a "quiet" mode (with almost no printing information).


##### Files parameters
- ```-i (--infile)```, ```-s (-sbml)``` (STRING) specify the inputs files. Only ```-i``` - corresponding to the dataset of fingerprint - is required. ```-s``` - the sbml file where the network is extracted - used Recon2.02 network by default (Thiele et al., 2013).
- ```--header``` considers first row as header of the columns.
- ```--separator``` (STRING) specify the character used to separate the column in the fingerprint dataset (e.g., "\t"). By default, the program uses tabulation separators.


##### Clustering parameters
- ```-t (--classifType)``` (INTEGER) type of clustering algorithm among clustering by partition (1: K-medoids 2: K-means) and hierarchical ascendant clustering (3: Ward; 4: Complete links; 5: Single links; 6: UPGMA; 7: WPGMA; 8: WPGMC; 9: UPGMC). By default, the complete links is used.
- ```--distance``` (INTEGER) type of distance among 1: Euclidian, 2: Manhattan, 3: Jaccard, 4: Sokal & Michener, 5 Sorensen (Dice), 6: Ochiai. By default, euclidean distance is used.
- ```-m (--maxClusters)``` (INTEGER) number maximum of clusters allowed; by default, 6 clusters (mimimum: 2; maximum: number of row of the dataset).
- ```-n (--nbClusters)``` (INTEGER) fixed the number of clustering in output (do not take account of Silhouette index; mimimum: 2; maximum: number of row of the dataset).
- ```--nbAxis``` (INTEGER) number of axis for PCA analysis outputs; by default, 2 axis (minimum: 2; maximum: 4).
- ```--text``` DO NOT prints text on plot.
- ```-a (-advanced mode)``` activates advanced mode with more clustering indexes: gap statistics, elbow, agglomerative coefficient, contribution per cluster and contribution per partition (discriminant power), silhouette index and pca first 2 axis for each points. The heatmap will be ordered by silhouette index.


## References
- Thiele I., Swainston N., Fleming R.M.T., et al. (2013). A community-driven global reconstruction of human metabolism. Nature biotechnology 31(5):10. doi:10.1038/nbt.2488.
- Cottret, L., Frainay, C., Chazalviel, M., et al. (2018). MetExplore: collaborative edition and exploration of metabolic networks. Nucleic acids research, 1.
- Rousseeuw, P. J. (1987). Silhouettes: a graphical aid to the interpretation and validation of cluster analysis. Journal of computational and applied mathematics, 20, 53-65.