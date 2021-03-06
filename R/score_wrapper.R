#' Score distribution
#'
#' This function computes the score distribution for the given PFM and
#' background. The Score distribution is computed based on an efficient
#' dynamic programming algorithm.
#'
#' @inheritParams motifValid
#' @inheritParams backgroundValid
#' @return List that contains
#' \describe{
#' \item{scores}{Vector of scores}
#' \item{dist}{Score distribution}
#' }
#'
#' @examples
#'
#'
#' # Load sequences
#' seqfile=system.file("extdata","seq.fasta", package="motifcounter")
#' seqs=Biostrings::readDNAStringSet(seqfile)
#'
#' # Load background
#' bg=readBackground(seqs,1)
#'
#' # Load motif
#' motiffile=system.file("extdata","x31.tab",package="motifcounter")
#' motif=t(as.matrix(read.table(motiffile)))
#'
#' # Compute the score distribution
#' dp=scoreDist(motif,bg)
#'
#' @export
scoreDist=function(pfm,bg) {
    motifValid(pfm)
    backgroundValid(bg)
    motifAndBackgroundValid(pfm,bg)


    scores=.Call("motifcounter_scorerange",
        as.numeric(pfm),nrow(pfm),ncol(pfm),
        bg$station,bg$trans,as.integer(bg$order),
        PACKAGE="motifcounter")

    dist=.Call("motifcounter_scoredist",
        as.numeric(pfm),nrow(pfm),ncol(pfm),
        bg$station,bg$trans,as.integer(bg$order),
        PACKAGE="motifcounter")
    return(list(scores=scores, dist=dist))
}


#' Score distribution
#'
#' This function computes the score distribution for a given PFM and
#' a background model.
#' 
#' The result of this function is identical to \code{\link{scoreDist}},
#' however, the method employs a less efficient algorithm that
#' enumerates all DNA sequences of the length of the motif.
#' This function is only used for debugging and testing purposes
#' and might require substantial computational
#' resources for long motifs.
#'
#' @inheritParams scoreDist
#' @return List containing
#' \describe{
#' \item{scores}{Vector of scores}
#' \item{dist}{Score distribution}
#' }
#'
#' @seealso \code{\link{scoreDist}}
#' @examples
#'
#' # Load sequences
#' seqfile=system.file("extdata","seq.fasta", package="motifcounter")
#' seqs=Biostrings::readDNAStringSet(seqfile)
#'
#' # Load background
#' bg=readBackground(seqs,1)
#'
#' # Load motif
#' motiffile=system.file("extdata","x31.tab",package="motifcounter")
#' motif=t(as.matrix(read.table(motiffile)))
#'
#' # Compute the score distribution
#' dp=motifcounter:::scoreDistBf(motif,bg)
#'
scoreDistBf=function(pfm,bg) {
    motifValid(pfm)
    backgroundValid(bg)
    motifAndBackgroundValid(pfm,bg)
    
    scores=.Call("motifcounter_scorerange",
                as.numeric(pfm),nrow(pfm),ncol(pfm),
                bg$station,bg$trans,as.integer(bg$order),
                PACKAGE="motifcounter")

    dist=.Call("motifcounter_scoredist_bf",
        as.numeric(pfm),nrow(pfm),ncol(pfm),
        bg$station,bg$trans,as.integer(bg$order),
        PACKAGE="motifcounter")
    return(list(scores=scores, dist=dist))
}

#' Score strand
#'
#' This function computes the per-position  
#' score in a given DNA strand.
#'
#' The function returns the per-position scores
#' for the given strand. If the sequence is too short,
#' it contains an empty vector.
#'
#' @inheritParams scoreDist
#' @param seq A DNAString object
#' @return 
#' \describe{
#' \item{scores}{Vector of scores on the given strand}
#' }
#'
#' @examples
#'
#'
#' # Load sequences
#' seqfile=system.file("extdata","seq.fasta", package="motifcounter")
#' seqs=Biostrings::readDNAStringSet(seqfile)
#'
#' # Load background
#' bg=readBackground(seqs,1)
#'
#' # Load motif
#' motiffile=system.file("extdata","x31.tab",package="motifcounter")
#' motif=t(as.matrix(read.table(motiffile)))
#'
#' # Compute the per-position and per-strand scores
#' motifcounter:::scoreStrand(seqs[[1]],motif,bg)
#'
scoreStrand=function(seq,pfm,bg) {
    motifValid(pfm)
    backgroundValid(bg)
    motifAndBackgroundValid(pfm,bg)
    
    # Check class
    stopifnot(class(seq)=="DNAString")
    
    scores=.Call("motifcounter_scoresequence",
        as.numeric(pfm),nrow(pfm),ncol(pfm),toString(seq),
        bg$station,bg$trans,as.integer(bg$order),
        PACKAGE="motifcounter")
    return(as.numeric(scores))
}

#' Score observations
#'
#' This function computes the per-position and per-strand 
#' score in a given DNA sequence.
#'
#' @inheritParams scoreDist
#' @param seq A DNAString object
#' @return List containing
#' \describe{
#' \item{fscores}{Vector of scores on the forward strand}
#' \item{rscores}{Vector of scores on the reverse strand}
#' }
#'
#' @examples
#'
#'
#' # Load sequences
#' seqfile=system.file("extdata","seq.fasta", package="motifcounter")
#' seqs=Biostrings::readDNAStringSet(seqfile)
#'
#' # Load background
#' bg=readBackground(seqs,1)
#'
#' # Load motif
#' motiffile=system.file("extdata","x31.tab",package="motifcounter")
#' motif=t(as.matrix(read.table(motiffile)))
#'
#' # Compute the per-position and per-strand scores
#' scoreSequence(seqs[[1]],motif,bg)
#'
#' @export
scoreSequence=function(seq,pfm,bg) {
    motifValid(pfm)
    backgroundValid(bg)
    motifAndBackgroundValid(pfm,bg)
    
    # Check class
    stopifnot(class(seq)=="DNAString")
    
    fscores=scoreStrand(seq, pfm, bg)
    rscores=scoreStrand(seq, revcompMotif(pfm), bg)
    return(list(fscores=fscores,rscores=rscores))
}

#' Score profile across multiple sequences
#'
#' This function computes the per-position and per-strand 
#' average score profiles across a set of DNA sequences.
#' It can be used to reveal positional constraints
#' of TFBSs.
#'
#' @inheritParams scoreDist
#' @param seqs A DNAStringSet object
#' 
#' @return List containing
#' \describe{
#' \item{fscores}{Vector of per-position average forward strand scores}
#' \item{rscores}{Vector of per-position average reverse strand scores}
#' }
#'
#' @examples
#'
#'
#' # Load sequences
#' seqfile=system.file("extdata","seq.fasta", package="motifcounter")
#' seqs=Biostrings::readDNAStringSet(seqfile)
#'
#' # Load background
#' bg=readBackground(seqs,1)
#'
#' # Load motif
#' motiffile=system.file("extdata","x31.tab",package="motifcounter")
#' motif=t(as.matrix(read.table(motiffile)))
#'
#' # Compute the score profile
#' scoreSequenceProfile(seqs,motif,bg)
#'
#' @export
scoreSequenceProfile=function(seqs,pfm,bg) {
    motifValid(pfm)
    backgroundValid(bg)
    stopifnot (class(seqs)=="DNAStringSet")

    if (any(lenSequences(seqs)!=lenSequences(seqs)[1])) {
        stop("Sequences must be equally long.
            Please trim the sequnces.")
    }
    slen=lenSequences(seqs)[1]
    
    fscores=lapply(seqs, function(seq,pfm,bg) {
        s=scoreStrand(seq,pfm,bg) }, 
        pfm,bg)
    fscores=unlist(fscores)
    fscores=apply(as.matrix(fscores,slen,length(fscores)/slen),1,mean)

    rscores=sapply(seqs, function(seq,pfm,bg) {
        s=scoreStrand(seq,revcompMotif(pfm),bg) }, 
        pfm,bg)
    rscores=unlist(rscores)
    rscores=apply(as.matrix(rscores,slen,length(rscores)/slen),1,mean)
    return (list(fscores=as.vector(fscores),rscores=as.vector(rscores)))
}

#' Score histogram on a single sequence
#'
#' This function computes the empirical score
#' distribution by normalizing the observed score histogram
#' for a given sequence.
#'
#'
#' @inheritParams scoreSequence
#' @return List containing
#' \describe{
#' \item{scores}{Vector of scores}
#' \item{dist}{Score distribution}
#' }
#'
#' @examples
#' 
#' # Load sequences
#' seqfile=system.file("extdata","seq.fasta", package="motifcounter")
#' seqs=Biostrings::readDNAStringSet(seqfile)
#'
#' # Load background
#' bg=readBackground(seqs,1)
#'
#' # Load motif
#' motiffile=system.file("extdata","x31.tab",package="motifcounter")
#' motif=t(as.matrix(read.table(motiffile)))
#'
#' # Compute the per-position and per-strand scores
#' motifcounter:::scoreHistogramSingleSeq(seqs[[1]],motif,bg)
#' 
scoreHistogramSingleSeq=function(seq,pfm, bg) {
    motifValid(pfm)
    backgroundValid(bg)
    stopifnot(class(seq)=="DNAString")
    motifAndBackgroundValid(pfm,bg)

    scores=.Call("motifcounter_scorerange",
                as.numeric(pfm),nrow(pfm),ncol(pfm),
                bg$station,bg$trans,as.integer(bg$order),
                PACKAGE="motifcounter")

    dist=.Call("motifcounter_scorehistogram",
            as.numeric(pfm),nrow(pfm),ncol(pfm),
            toString(seq),
            bg$station,bg$trans,as.integer(bg$order),
            PACKAGE="motifcounter")
    result=list(scores=scores, dist=dist)

    return(result)
}


#' Score histogram
#'
#' This function computes the empirical score
#' distribution for a given set of DNA sequences.
#'
#' It can be used to compare the empirical score
#' distribution against the theoretical one (see \code{\link{scoreDist}}).
#'
#' @inheritParams scoreSequenceProfile
#' @return List containing
#' \describe{
#' \item{scores}{Vector of scores}
#' \item{dist}{Score distribution}
#' }
#' @examples
#'
#' # Load sequences
#' seqfile=system.file("extdata","seq.fasta", package="motifcounter")
#' seqs=Biostrings::readDNAStringSet(seqfile)
#'
#' # Load background
#' bg=readBackground(seqs,1)
#'
#' # Load motif
#' motiffile=system.file("extdata","x31.tab",package="motifcounter")
#' motif=t(as.matrix(read.table(motiffile)))
#'
#' # Compute the empirical score histogram
#' scoreHistogram(seqs,motif,bg)
#'
#' @seealso \code{\link{scoreDist}}
#' @export
scoreHistogram=function(seqs,pfm,bg) {
    motifValid(pfm)
    backgroundValid(bg)
    stopifnot(class(seqs)=="DNAStringSet")

    his=lapply(seqs, scoreHistogramSingleSeq, pfm, bg)
    nseq=length(his)
    scores=his[[1]]$scores
    nrange=length(his[[1]]$dist)
    his=lapply(his,function(x) {x$dist})
    his=unlist(his)
    his=matrix(his,nrange,nseq)
    his=apply(his,1,sum)
    freq=his
    result=list(scores=scores, dist=freq)

    return(result)
}

#' Score threshold
#'
#' This function computes the score threshold for a desired
#' false positive probability `alpha`.
#' 
#' Note that the returned alpha usually differs slightly
#' from the one that is prescribed using 
#' \code{\link{motifcounterOptions}}, because
#' of the discrete nature of the sequences.
#'
#' @inheritParams scoreDist
#' @return List containing
#' \describe{
#' \item{threshold}{Score threshold}
#' \item{alpha}{False positive probability}
#' }
#' @examples
#'
#' # Load sequences
#' seqfile=system.file("extdata","seq.fasta", package="motifcounter")
#' seqs=Biostrings::readDNAStringSet(seqfile)
#'
#' # Load background
#' bg=readBackground(seqs,1)
#'
#' # Load motif
#' motiffile=system.file("extdata","x31.tab",package="motifcounter")
#' motif=t(as.matrix(read.table(motiffile)))
#'
#' # Compute the score threshold
#' motifcounter:::scoreThreshold(motif,bg)
#'
scoreThreshold=function(pfm,bg) {
    motifValid(pfm)
    backgroundValid(bg)
    
    scoredist=scoreDist(pfm,bg)

    # find quantile
    ind=which(1-cumsum(scoredist$dist)<=sigLevel())
    if (length(ind)<=1) {
        stop("The significance level is too stringent for the given motif.
            Motif hits are impossible to occur at that level.
            Use 'motifcounterOptions' to prescribe a less stringent 
            value for 'alpha'.")
    }
    ind=ind[2:length(ind)]
    alpha=sum(scoredist$dist[ind])

    ind=min(ind)
    threshold=scoredist$scores[ind]

    return(list(threshold=threshold, alpha=alpha))
}


