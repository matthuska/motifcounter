
#interface functions for motif representation
read.background=function(file, order=1) {
    dummy=.C("Rmakebg", as.character(file), as.integer(order))
  #if (regexpr(pattern=".fasta$",file)>=0) {
  #} else {
  #  dummy=.C("RreloadBackground", as.character(file))
  #}
}

store.background=function(file) {
  dummy=.C("Rstorebg",as.character(file));
}

print.background=function() {
  dummy=.C("RprintBackground");
}

delete.background=function() {
  dummy=.C("RdestroyBackground")
}

read.background.sampling=function(file, order=1) {
  #if (regexpr(pattern=".fasta$",file)>=0) {
    dummy=.C("RmakebgForSampling", as.character(file), as.integer(order))
  #} else {
  #  dummy=.C("RreloadBackgroundForSampling", as.character(file))
  #}
}

store.background.sampling=function(file) {
  dummy=.C("RstorebgForSampling",as.character(file));
}

print.background.sampling=function() {
  dummy=.C("RprintBackgroundForSampling");
}

delete.background.sampling=function() {
  dummy=.C("RdestroyBackgroundForSampling")
}