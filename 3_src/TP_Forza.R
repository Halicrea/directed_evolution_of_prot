setwd("/home/elyna/Documents/M1BB/M2Sem4/BioStruc_Niv3/OFFMANN/")

#automatic install of packages if they are not installed already
list.of.packages <- c(
  "foreach",
  "doParallel",
  "ranger",
  "tidyverse",
  "kableExtra",
  "stringr",
  "ggplot2"
)
#loading packages
for(package.i in list.of.packages){
  suppressPackageStartupMessages(
    library(
      package.i, 
      character.only = TRUE
    )
  )
}
n.cores <- parallel::detectCores() - 1
#create the cluster
my.cluster <- parallel::makeCluster(
  n.cores, 
  type = "PSOCK"
)
#register it to be used by %dopar%
doParallel::registerDoParallel(cl = my.cluster)

#check if it is registered (optional)
foreach::getDoParRegistered()

#### I. Preparations ----
amino_acid=c('A','C','D','E','F',
             'G','H','I','K','L',
             'M','N','P','Q','R',
             'S','T','W','Y','V')
seq_length=64
### - 1.1. Functions declaration
#mut_seq=rep("VKVKFKYKGEEKEVDTSKIKKVWRVGKMVSFTYDDNGKTGRGAVSEKDAPKELLDMLARAEREK",100)
mutate_seq <- function(seq, mut_rate=0.2,nb_of_mutants=100){
  vec_of_mutants={}
  for(i in 1:nb_of_mutants){
    name_seq= paste(">Sequence_mutated_",i,sep = "")
    new_seq = seq
    mypos = seq(1:nchar(seq))
    mypos.mutate = sample(mypos,nchar(seq)*mut_rate,replace=F)
    for (i in 1:length(mypos.mutate))
    {
      new_seq = `substr<-`(new_seq,mypos.mutate[i],mypos.mutate[i],sample(amino_acid,1,replace = T))
    }
    vec_of_mutants <- c(vec_of_mutants,c(name_seq,new_seq))
  }
  return(vec_of_mutants)
}
### - 1.2. Prepare the type of sequence to generate ----

list_ref_seq=read.table("all_similar.fa",sep=":")

tmp_data <- map_df(list_ref_seq$V2, function(s) {
  tmp <- t(str_count(s, fixed(LETTERS, ignore_case = TRUE))/nchar(s))
  tmp <- as_tibble(tmp, .name_repair = "minimal")
  colnames(tmp) <- LETTERS
  tmp
}) %>% 
  bind_rows()
tmp_data
amino_acid_pb <- apply(tmp_data,2,mean)
names(amino_acid)<-amino_acid
aa_pb <- cbind(amino_acid, amino_acid_pb = amino_acid_pb[names(amino_acid)])[,2]
amino_acid_pb_df <- data.frame(letter = amino_acid,
                                proba = as.numeric(aa_pb))
amino_acid_pb<-amino_acid_pb_df[order(amino_acid_pb_df$proba),]

#### II. Initial round ----
nb_of_bests <- 10
nb_of_mutants <- 1000
nb_of_init_seq <- 10000
### - 2.2. Generating the first batch of random sequences ----
sequences = {}
header = ""
sequences <- foreach(i=1:nb_of_init_seq,.combine = 'c') %dopar% {
  sequences[i]=paste(sample(amino_acid_pb_df$letter, seq_length, replace=TRUE, prob = amino_acid_pb_df$proba), collapse="")
  header = paste("Random_Sequence_",i,sep = "")
  sequence = paste(">",header,"\n",sequences[i],sep = "")
  write(sequence,file = paste("RD_SEQS/",header,".fasta",sep=""))
}

#system("./SCRIPTS/FORSA/forsa_global RD_SEQS/_Sequence_random_1.fasta OUT_DSSP_backup/2xiw_A.dssp.pb -5", intern = T)
align_raw={}
align_seq={}
align_raw <- foreach(i=1:nb_of_init_seq,.combine = 'rbind',.inorder = FALSE) %dopar% {
  name_seq = paste("Random_Sequence_",i,".fasta",sep = "")
  align_seq = system(paste("./SCRIPTS/FORSA/forsa_global RD_SEQS/",name_seq ," OUT_DSSP_backup/2xiw_A.dssp.pb -5",sep=""), intern = T)
  ## We need to delete the file to avoid overfilling
  system(paste("rm ","RD_SEQS/",name_seq,sep=""),intern=T)
  align_seq[1] = paste("Random_Sequence_",i,sep="")
  align_raw[i] = t(align_seq)
}
align_raw[,4]=str_split_i(align_raw[,4],":",5)
align_df<-data.frame(query  = align_raw[,2],
                     target = align_raw[,3],
                     z_score = as.double(align_raw[,4]))
row.names(align_df)<-align_raw[,1]

par(mfrow = c(1,1))
hist(as.numeric(unlist(align_df$z_score)),breaks = 100,
     xlim=c(-3, 11),
     main = "Valeur de Z-SCORE pour des séquences aléatoires\n selon une loi uniforme par rapport à 2xiw",
     ylab = "Nombre de séquences", xlab = "Z-Score",
     col = rgb(0.83,0,1,0.7), border = F)
abline(v = c(3.085,8.004 ), col = "red",lwd=2)
top_hit<-head(align_df[order(-align_df$z_score),,drop = F],nb_of_bests)
print(head(top_hit))
#top_hit[1,1]="VKVKFKYKGEEKEVDTSKIKKVWRVGKMVSFTYDDNGKTGRGAVSEKDAPKELLDMLARAEREK"

### III. Mutation cycles ----
par(mfrow = c(2,2))
for(cycles in 1:4){
  print(cycles)
  top_hit[,1]<-gsub('-', '', top_hit[,1])
  new_sequences = {}
  new_sequences_tmp = {}
  file_name_l <<- {}
  cpt = 1
  foreach(i=1:nb_of_bests,.combine = 'c') %dopar% {
    #new_sequences_tmp=system(paste("./mutate_seq",nb_of_mutants,top_hit[i,1]),intern = T)
    new_sequences_tmp = mutate_seq(top_hit[i,1],nb_of_mutants = nb_of_mutants)
    for (j in 1:(nb_of_mutants*2)){
      if(j %% 2 != 0){
        header <- new_sequences_tmp[j] 
      } else {
        file_name = paste("Sequence_mutated_0.2_from",i,"_child_",j/2,sep="")
        sequence <- paste(header,"\n",new_sequences_tmp[j],sep="")
        #new_sequences[i] = sequence
        write(sequence,file = paste("MUT_SEQ/",file_name,".fasta",sep=""))
      }
    }
  }
  
  align_raw_mut={}
  align_seq_mut={}
  file_names = list.files("MUT_SEQ/")
  align_raw_mut <- foreach(i=1:(nb_of_mutants*nb_of_bests),.combine = 'rbind',.inorder = FALSE) %dopar% {
    align_seq_mut = system(paste("./SCRIPTS/FORSA/forsa_global MUT_SEQ/",file_names[i] ," OUT_DSSP_backup/2xiw_A.dssp.pb -5",sep=""), intern = T)
    system(paste("rm ","MUT_SEQ/",file_names[i],sep=""),intern=T)
    align_seq_mut[1] = paste("Random_Sequence_",i,sep="")
    align_raw_mut[i] = t(align_seq_mut)
  }
  align_raw_mut[,4]=str_split_i(align_raw_mut[,4],":",5)
  align_df_mut<-data.frame(query  = align_raw_mut[,2],
                           target = align_raw_mut[,3],
                           z_score = as.double(align_raw_mut[,4]))
  row.names(align_df_mut)<-align_raw_mut[,1]
  
  hist(as.numeric(unlist(align_df_mut$z_score)),breaks = 100,
       xlim=c(-3, 11),
       main = paste("Valeur de Z-SCORE pour des séquences aléatoires\n selon une loi uniforme par rapport à 2xiw\nCycle:",cycles),
       ylab = "Nombre de séquences", xlab = "Z-Score",
       col = rgb(0.83,0,1,0.7), border = F)
  abline(v = c(3.085,8.004 ), col = "red", lwd = 3)
  top_hit <- head(align_df_mut[order(-align_df_mut$z_score),,drop = F],nb_of_bests)
  print(head(top_hit))
  write.csv(top_hit,file = paste("Top_HITS_",cycles,".txt",sep=""),row.names = T,quote=F)
}
mtext("Valeur de Z-SCORE pour des séquences aléatoires\n selon une loi uniforme par rapport à 2xiw",
      side = 3, line = -21, outer = T)
