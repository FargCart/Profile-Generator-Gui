## How to RUN
<ol>
	<li> In the left panel upload the input matrix in the "input data" option.
	<li> Select the "Standardization method" for preprocessing of the data.
	<li> Click in "Upload data".
	<li> Go to Settings panel and choose the desired options.
	<li> Click in "Run analysis".
</ol>

## How each section is divided

#### Below a description of the various stages of analysis contained in this tool.

### 1.Input

The data should be uploaded in .csv or .xlsx format. An adjacency matrix is created aligning the row and column quantities using 0 for missing data. In the Input panel you can see the input matrix that will be use to execute the analysis.

### 2.Settings

You have two option for analysis, to change them you should just click on the button at the top right of the screen. Below these options you can select some metrics that will be calculated by the tool.

#### 2.1 Clustering

##### 2.1.1 Apply Clustering

##### 2.1.2 Type of analysis

This tool use two approaches from the WGCNA R package: dynamic tree and dynamic hybrid. Both are at this <u><b><a target="_blank" href = "https://labs.genetics.ucla.edu/horvath/CoexpressionNetwork/BranchCutting/">link</a></b></u>. It also used one strategy of Multiscale Bootstrap Resampling (pvclust R package) and three cutting strategies to identify the highest k in the dendogram (silhouette).

<ul>

	<li> <b>Dynamic tree:</b> The algorithm implements an adaptive and iterative process of cluster decomposition and combination that stops when the number of clusters becomes stable. To avoid over-splitting, very small clusters are joined to their neighboring major clusters;

	<li> <b>Dynamic hybrid:</b> The algorithm can be considered a hybrid of hierarchical clustering and modified Partitioning Around Medoids (PAM), since it involves assigning objects to their closest medoids.

	<li> <b>pvcluster:</b> The <u><b><a target="_blank" href = "http://stat.sys.i.kyoto-u.ac.jp/prog/pvclust/">pvclust</a></b></u> R package is used for assessing the uncertainty in hierarchical cluster analysis. For each cluster in hierarchical clustering, quantities called p-values are calculated via multiscale bootstrap resampling.

	<li> <b>NbClust:</b> For identification of the best cutting criterion the tolll use <u>silhouette metric </u>, that refers how well each object lies within its cluster.
</ul>

##### 2.1.2 Distance Metric

##### 2.1.2 Linkage Algorithm

</ul>

#### 2.2 Network

##### 2.2.1 Community Algorithms

Below a short summary about the community detection algorithms currently implemented.

<ul>
	<li> <b>edge.betweenness.community:</b> is a hierarchical decomposition process where edges are removed in the decreasing order of their edge betweenness scores (i.e. the number of shortest paths that pass through a given edge). This is motivated by the fact that edges connecting different groups are more likely to be contained in multiple shortest paths simply because in many cases they are the only option to go from one group to another. This method yields good results but is very slow because of the computational complexity of edge betweenness calculations and because the betweenness scores have to be re-calculated after every edge removal. Your graphs with ~700 vertices and ~3500 edges are around the upper size limit of graphs that are feasible to be analyzed with this approach. Another disadvantage is that edge.betweenness.community builds a full dendrogram and does not give you any guidance about where to cut the dendrogram to obtain the final groups, so you'll have to use some other measure to decide that (e.g., the modularity score of the partitions at each level of the dendrogram)

	<li> <b>fastgreedy.community:</b> is another hierarchical approach, but it is bottom-up instead of top-down. It tries to optimize a quality function called modularity in a greedy manner. Initially, every vertex belongs to a separate community, and communities are merged iteratively such that each merge is locally optimal (i.e. yields the largest increase in the current value of modularity). The algorithm stops when it is not possible to increase the modularity any more, so it gives you a grouping as well as a dendrogram. The method is fast and it is the method that is usually tried as a first approximation because it has no parameters to tune. However, it is known to suffer from a resolution limit, i.e. communities below a given size threshold (depending on the number of nodes and edges if I remember correctly) will always be merged with neighboring communities.

	<li> <b>walktrap.community:</b> is an approach based on random walks. The general idea is that if you perform random walks on the graph, then the walks are more likely to stay within the same community because there are only a few edges that lead outside a given community. Walktrap runs short random walks of 3-4-5 steps (depending on one of its parameters) and uses the results of these random walks to merge separate communities in a bottom-up manner like fastgreedy.community. Again, you can use the modularity score to select where to cut the dendrogram. It is a bit slower than the fast greedy approach but also a bit more accurate (according to the original publication).

	<li> <b>spinglass.community:</b> is an approach from statistical physics, based on the so-called Potts model. In this model, each particle (i.e. vertex) can be in one of c spin states, and the interactions between the particles (i.e. the edges of the graph) specify which pairs of vertices would prefer to stay in the same spin state and which ones prefer to have different spin states. The model is then simulated for a given number of steps, and the spin states of the particles in the end define the communities. The consequences are as follows: 1) There will never be more than c communities in the end, although you can set c to as high as 200, which is likely to be enough for your purposes. 2) There may be less than c communities in the end as some of the spin states may become empty. 3) It is not guaranteed that nodes in completely remote (or disconencted) parts of the networks have different spin states. This is more likely to be a problem for disconnected graphs only, so I would not worry about that. The method is not particularly fast and not deterministic (because of the simulation itself), but has a tunable resolution parameter that determines the cluster sizes. A variant of the spinglass method can also take into account negative links (i.e. links whose endpoints prefer to be in different communities).

	<li> <b>leading.eigenvector.community:</b> is a top-down hierarchical approach that optimizes the modularity function again. In each step, the graph is split into two parts in a way that the separation itself yields a significant increase in the modularity. The split is determined by evaluating the leading eigenvector of the so-called modularity matrix, and there is also a stopping condition which prevents tightly connected groups to be split further. Due to the eigenvector calculations involved, it might not work on degenerate graphs where the ARPACK eigenvector solver is unstable. On non-degenerate graphs, it is likely to yield a higher modularity score than the fast greedy method, although it is a bit slower.

	<li> <b>leading.eigenvector.community:</b> is a simple approach in which every node is assigned one of k labels. The method then proceeds iteratively and re-assigns labels to nodes in a way that each node takes the most frequent label of its neighbors in a synchronous manner. The method stops when the label of each node is one of the most frequent labels in its neighborhood. It is very fast but yields different results based on the initial configuration (which is decided randomly), therefore one should run the method a large number of times (say, 1000 times for a graph) and then build a consensus labeling, which could be tedious.

</ul>

##### 2.2.2 Graph orientation

In this option you can choose whether your network is directed, or undirected.

##### 2.2.3 Weighted

</ul>

#### 2.3 Selecting metrics

In addition these options you can also select the metrics that you want to calculate:

<ol>
	<li> <b>Network metrics:</b> The results of these metrics are shown in the left window below the "upload data" button;
	<li> <b>Vertexs metrics:</b> The results of these metrics are shown in the Result/Metrics section.
	<li> <b>Intra-communities metrics:</b> The results of these metrics are shown in the Result/Intra-Communities section.
</ol>

### 3.Plots

In the plots section you have three option to view and one for community configuration.

<ul>
	<li><b>Dendogram:</b> For building the dendogram this softare use the <u><b><a target="_blank" href = "https://cran.r-project.org/web/packages/dendextend/vignettes/Cluster_Analysis.html">dendextend R package</a></b></u>. Below each of the dendograms there is a color bar that describes how the grouping elements was made.
	<br />
	<li> <b>Static Network:</b> For building the static network this software use the <u><b><a target="_blank" href = "http://igraph.org/r/">igraph R package</a></b></u>. The groups are highlighted by color according to the representation of the dendogram.
	<br />
	<li> <b>Interactive Network:</b> For the construction of the interactive network this software use <u><b><a target="_blank" href = "https://cran.r-project.org/web/packages/visNetwork/vignettes/Introduction-to-visNetwork.html">visNetwork R package</a></b></u>. The groups are also defined by color according to the result of the initial clustering. You can identify communities selecting them by color, or highlight the neighborhood of each vertex by clicking on the network elements.
	<br />
	<li> <b>Community settings:</b> In this option you must select the target group which you want to modify, identify and select the element by clicking on the row of the table indicated in the section "Select the fields you want to change:". On the right side in the "Select the new group:" option, you must select the new group and click on the "Change it".
</ul>

### 4.Results

#### 4.1 Metrics:

The network metrics are defined in the "Settings" tab. The igraph object called 'g1' represents the network. Most of the functions shown bellow were obtained from the native functions of igraph R package. 
<ul>
	<li><b>Degree:</b> number of edges per node. [degree(g1,v=V(g1),mode="all")]

	<li><b>In-degree:</b> number of incoming edges in a directed graph. [degree(g1,v=V(g1),mode="in")]



	<li><b>Out-degree:</b> number of outgoing edges in a directed graph. [degree(g1,v=V(g1),mode="out")]

	<li><b>Average neighbor degree:</b> average degree of neighboring nodes. [neighborhoodConnectivity(g1)]

	<li><b>Clustering coefficient:</b> ratio of triangles in a node neighborhood to all possible triangles. [transitivity(g1, type="local")]

	<li><b>Degree centrality:</b>  ratio of other nodes connected to the node. [centr_degree(g1, mode = "all", loops = TRUE, normalized = FALSE)]

	<li><b>In-degree centrality:</b>  ratio of incoming edges to a node in a directed graph. [centr_degree(g1, mode = "in", loops = TRUE, normalized = FALSE)]

	<li><b>Out-degree centrality:</b> atio of outgoing edges from a node in directed graph. [centr_degree(g1, mode = "out", loops = TRUE, normalized = FALSE)]

	<li><b>Betweenness centrality:</b> measure of control a node exerts over the interaction of other nodes in the network. [betweenness(g1, v=V(g1), directed = TRUE, nobigint = TRUE, normalized = FALSE)]

	<li><b>Eigenvector centrality:</b> score nodes by their connections to high-scoring nodes (measure of centrality of a node based on its connection to other central nodes). [evcent(g1)[[1]]]

	<li><b>Closeness vitality:</b> change in the sum of distances for all node pairs when excluding that node. [closeness_vitality(g1)]

	<li><b>Core number:</b> largest value k of a k-core containing that node. [(SANTA R package) coreness(g1, mode = "all")]

	<li><b>Information centrality:</b> proportion of total information flow that is controlled by each node. [info.centrality.vertex(g1)]

	<li><b>Eccentricity:</b> maximum distance between the node and every other node in the network. [eccentricity(g1)]

	<li><b>Closeness centrality:</b> distance to all other nodes. [closeness(g1, vids = V(g1), mode = "all", normalized = FALSE)]
</ul>

#### 4.2 Asymmetries

#### 4.3 Intra-Communities

In the extraction of intra-community metrics, each color identified as a group in the network is detached and the metrics of each sub-network are calculated separately. Below are the descriptions of each metric, as well as the functions used with the help of the igraph R package.

<ul>
	<li><b> Average shortest path length:</b> expected distance between two nodes in the graph. [average.path.length(g2)]

	<li><b>Graph clique number:</b> number of nodes in the largest clique (size of a clique). [length(largest_cliques(g2)[[1]])]

	<li><b>Radius:</b> Minimum eccentricity of the graph. [radius(g2, mode = "all")]

	<li><b>Density:</b> ratio between actual number of edges and maximum number of edges (fully connected graph). [edge_density(g2, loops = FALSE)]

	<li><b>Graph number of cliques:</b> number of cliques (subsets of nodes, where every two nodes are connected). [length(cliques(g2, min = 2, max = NULL))]

	<li><b>Transitivity:</b> ratio of all possible triangles in the network (if node A connects to B and C, how often are B and C connected in the graph). [transitivity(g2, type="global")]

	<li><b>Average clustering coefficient:</b> average of the local clustering coefficients of all the vertices. [average.path.length(g2)]

	<li><b>Degree assortativity coefficient:</b> correlations between nodes of similar degree. [assortativity_degree(g2, directed = "directed")]

	<li><b>Compactness:</b> The number of branches found below the cut height [SANTA R package - Compactness(g2, nperm=100, vertex.attr="weights", verbose=F)$pval]

	<li><b>Degree pearson correlation coefficient:</b> same as degree assortativity coefficient but with a scipy.stats.pearsonr function. [assortativity_b(g2)]

	<li><b>Number of connected components:</b> number of separate networks in a graph. [clusters(g3)$no]

	<li><b>Number of strongly connected components:</b> parts of network where every vertex is reachable from every other vertex (for directed graphs only). [clusters(g2, mode="strong")$no]

	<li><b>Number of weakly connected components:</b> parts of network where replacing all of its directed edges with undirected edges produces a connected (undirected) graph (for directed graphs only). [clusters(g2, mode="weak")$no]

	<li><b>Number of attracting components:</b> node in a direct graph that a random walker in a graph cannot leave (for directed graphs only). [canonical_permutation(g3)$info$nof_leaf_nodes]

</ul>

#### 4.4 Download

## Others informations
<ul>
	<li> <b>Data preprocessing:</b> The data should be uploaded in .csv or .xlsx format. I have created an adjacency matrix by aligning the row and column quantities using 0 for missing data.

	<li> <b>Test:</b> If you can test this tool you can download the data at: https://www.dropbox.com/s/mexcr320bs0yj9r/input.xlsx?dl=0

</ul>


	
