% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/overlap.R
\name{probOverlapHit}
\alias{probOverlapHit}
\title{Overlapping motif hit probabilities}
\usage{
probOverlapHit(pfm, bg, singlestranded = FALSE)
}
\arguments{
\item{pfm}{An R matrix that represents a position frequency matrix}

\item{bg}{A Background object}

\item{singlestranded}{Boolean that indicates whether a single strand or
both strands shall be scanned for motif hits. 
Default: singlestranded = FALSE.}
}
\value{
A list containing various overlapping hit probabilities.
The list contains the following entries
    \describe{
    \item{alpha}{False positive probability}
    \item{beta}{Vector of overlapping hit probability for hits
            occurring on the same strand. Each element corresponds to
            relative distance of the starts of the two hits.}
    \item{beta3p}{Vector of overlapping hit probability for a
            forward strand hit that is followed by a reverse strand
            hit. Each element corresponds to
            relative distance of the starts of the two hits.}
    \item{beta5p}{Vector of overlapping hit probability for a
            reverse strand hit that is followed by a forward strand
            hit. Each element corresponds to
            relative distance of the starts of the two hits.}
    \item{gamma}{Vector of overlapping hit probabilities across
            all configurations. In contrast to beta, beta3p and beta5p,
            gamma is not corrected for intermediate motif hit events.}
    \item{singlestranded}{singlestranded flag that is prescribed 
            as input argument.}
    }
}
\description{
This function computes a set of self-overlapping probabilites for a
motif and background model.
}
\details{
The `gamma`s are determined based on two-dimensional score 
distributions (similar as described in Pape et al. 2008),
however, they are computed based on an order-d background model.
On the other hand, the `beta`s represent overlapping hit probabilities
that were corrected for intermediate hits.
}
\examples{

# Load sequences
seqfile=system.file("extdata","seq.fasta", package="motifcounter")
seqs=Biostrings::readDNAStringSet(seqfile)

# Load background
bg=readBackground(seqs,1)

# Load motif
motiffile=system.file("extdata","x31.tab", package="motifcounter")
motif=t(as.matrix(read.table(motiffile)))

# Compute overlapping hit probabilities for scanning both DNA strands
op=motifcounter:::probOverlapHit(motif,bg,singlestranded=FALSE)

# Compute overlapping hit probabilities for scanning a single DNA strand
op=motifcounter:::probOverlapHit(motif,bg,singlestranded=TRUE)

}

