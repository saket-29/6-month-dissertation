data<-read.table(file = file.choose(), header = TRUE)
View(data)
rownames(data) = data$Geneid
data$Geneid = NULL

data2<-as.matrix(data)
#coldata<-colnames(data))


coldata <- read.csv(file.choose(), row.names = 1)
#rownames(coldata) = coldata$Sample
#coldata$Sample = NULL
all(rownames(coldata) == colnames(data2))


dds <- DESeqDataSetFromMatrix(countData = data2, colData = coldata, design = ~Condition)
View(dds)
dds<-DESeq(dds)
res<-results(dds)
View(res)
res

res <- results(dds, name= "Young and Old")
res <- results(dds, contrast=c("Condition","Young","Old"), alpha =0.05)
resultsNames(dds)  #try first if error generated
cont_shrunk<-c("Condition","Young","Old")

resLFC <- lfcShrink(dds,coef = 2, type = "apeglm")
#use if apeglm not installed
#if (!requireNamespace("BiocManager", quietly = TRUE))
#install.packages("BiocManager")

#BiocManager::install("apeglm", force = TRUE)

plotMA(res, ylim=c(-2,2), legend = TRUE)
plotMA(resLFC, ylim=c(-2,2))

resOrdered <- res[order(res$pvalue),]
summary(res)
sum(res$padj < 0.01, na.rm=TRUE)


summary(res)
res3<-res[res$padj < 0.05, res$log2FoldChange > 2, na.rm =TRUE]
summary()
write.csv(res3, file = "condition Recurrence vs Non.recurrence", sep = ",")

ntd <- normTransform(dds)
library("vsn")
meanSdPlot(assay(ntd))
BiocManager::install("vsn")

res_LFC <- res[which(abs(res$log2FoldChange) > 2),]
res_LFC
res_prop<-  res_LFC[which(abs(res_LFC$padj) < 0.01),]
res_prop
plotMA(res_prop, ylim=c(-2,2))
res_prop<-data.frame(res_prop)
write.csv(res_prop,"D:\\cutoff_ya_stringent.csv")


d <- plotCounts(dds, gene=which.min(res$padj), intgroup="Condition", 
                returnData=TRUE)
ggplot(d, aes(x=Condition, y=count)) + 
  geom_point(position=position_jitter(w=0.1,h=0)) + 
  scale_y_log10(breaks=c(25,100,400))
 
library("pheatmap")
select <- dds
 pheatmap(dds)             
df <- as.data.frame(colData(dds)[,c("Condition")])
pheatmap(assay(ntd)[select,], cluster_rows=FALSE, show_rownames=FALSE,
         cluster_cols=FALSE, annotation_col=df)
pheatmap(assay(vsd)[select,], cluster_rows=FALSE, show_rownames=FALSE,
         cluster_cols=FALSE, annotation_col=df)
plotPCA(vsd, intgroup="condition")
GeneID<-rownames(res_prop)
res_prop<-cbind(GeneID,res_prop,)

ego<-enrichGO(new_res$GeneID, org.Hs.eg.db, keyType = "ENTREZID")
goplot(ego, size=0.05)

BiocManager::install("clusterProfiler")
enrichKEGG('ENSG00000143452')

new_res<-read_excel(file.choose())


original_gene_list <- new_res$log2FoldChange
names(original_gene_list)<- new_res$GeneID
gene_list<-na.omit(original_gene_list)
gene_list = sort(gene_list, decreasing = TRUE)


 keytypes(org.Hs.eg.db)


gse <- gseGO(geneList=gene_list, 
            ont ="ALL", 
            keyType = "ENTREZID",
            nPerm = 1000,
            pvalueCutoff = 'none',
            verbose = TRUE, 
            OrgDb = org.Hs.eg.db,
            pAdjustMethod = "none")
 
  require(DOSE)
  dotplot(gse, showCategory=10, split=".sign") + facet_grid(.~.sign)

  emapplot(gse, showCategory = 10)
  cnetplot(gse, categorySize="pvalue", foldChange=gene_list, showCategory = 3)  

  
  
kk2 <- gseKEGG(geneList     = gene_list,
                 organism     = "hsa",
                 nPerm        = 10000,
                 pvalueCutoff = "1.0",
                 pAdjustMethod = "none",
                 keyType       = "ncbi-geneid")  
dotplot(kk2, showCategory = 10, title = "Enriched Pathways" , split=".sign") + facet_grid(.~.sign)
