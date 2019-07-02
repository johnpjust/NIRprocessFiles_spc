library(hyperSpec)
library(tools)
#netdir = 'Z:\\Nircal\\JD2018'
netdir = '\\\\my.files.iastate.edu\\engr\\research\\abe\\grainbin\\Nircal\\JD2018'
boxpath = 'C:\\Users\\gqlstdnt\\Box Sync\\JD2018'
dir.create(netdir)
dir.create(boxpath)
filepath = 'C:\\Users\\gqlstdnt\\Documents\\JD2018'
file.copy(filepath, dirname(netdir), recursive=TRUE, overwrite = FALSE)
file.copy(filepath, dirname(boxpath), recursive=TRUE, overwrite = FALSE)

files = list.files(netdir, recursive = TRUE, pattern = '*.spc')
df_opal = NULL
df_nist = NULL
for (f in files){
  flag <- TRUE
  tryCatch(
    {
      f1 = read.spc(sprintf('%s\\%s', filepath, f))
    },
    error = function(cond)
    {
      print(paste0("error:", cond))
      flag<<-FALSE
    }
  )
  if (!flag) next
  
  if(grepl("opal", f, ignore.case = TRUE)){
    #print(sprintf("opal %s",f))
    fname = file_path_sans_ext(basename(f))
    crop = dirname(dirname(f))
    SN = basename(dirname(f))
    date = substr(basename(f), start = 1, stop = 10)
    time = gsub('-',':',substr(basename(f), start = 12, stop = 19))
    sampID = regexpr("\\d+_\\d+(?=_opal)", f, perl=TRUE, ignore.case = TRUE)
    sampID = regmatches(f, sampID)
    if(length(sampID)){
    df_opal = rbind(df_opal, data.frame(date, time, crop, SN, fname, sampID, f1@data$spc))
    }
  }
  else if(grepl("nist", f, ignore.case = TRUE))
  {
    #print(sprintf("Nist %s",f))
    fname = file_path_sans_ext(basename(f))
    crop = dirname(dirname(f))
    SN = basename(dirname(f))
    date = substr(basename(f), start = 1, stop = 10)
    time = gsub('-',':',substr(basename(f), start = 12, stop = 19))
    sampID = regexpr("\\d+_\\d+(?=_nist)", f, perl=TRUE, ignore.case = TRUE)
    sampID = regmatches(f, sampID)
    if(length(sampID)){
      df_nist = rbind(df_nist, data.frame(date, time, crop, SN, fname, sampID, f1@data$spc))
    }
  }
}

for (f in files){
  if(grepl("opal", f, ignore.case = TRUE)){
    flag <- TRUE
    tryCatch(
      {
        f1 = read.spc(sprintf('%s\\%s', filepath, f))
      },
      error = function(cond)
      {
        print(paste0("error:", cond))
        flag<<-FALSE
      }
    )
    if (!flag) next
    colnames(df_opal) = c('date', 'time', 'crop', 'SN', "filename", "sampleID", as.character(f1@wavelength))
    break
  }
}
for (f in files){
  if(grepl("nist", f, ignore.case = TRUE)){
    flag <- TRUE
    tryCatch(
      {
        f1 = read.spc(sprintf('%s\\%s', filepath, f))
      },
      error = function(cond)
      {
        print(paste0("error:", cond))
        flag<<-FALSE
      }
    )
    if (!flag) next
    colnames(df_nist) = c('date', 'time', 'crop', 'SN', "filename", "sampleID", as.character(f1@wavelength))
    break
  }
}

## generic csv filepath generator
#sprintf('%s\\%s', filepath, gsub('/', '\\', substr(dirname(files[1]), 1, nchar(dirname(files[1]))-1)))

write.csv(df_opal, sprintf('%s\\%s', netdir, 'opal.csv'), row.names = FALSE)
write.csv(df_nist, sprintf('%s\\%s', netdir, 'nist.csv'), row.names = FALSE)

write.csv(df_opal, sprintf('%s\\%s', boxpath, 'opal.csv'), row.names = FALSE)
write.csv(df_nist, sprintf('%s\\%s', boxpath, 'nist.csv'), row.names = FALSE)
