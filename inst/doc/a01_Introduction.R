## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5,
  eval = Sys.getenv("$RUNNER_OS") != "macOS"
)
options(rmarkdown.html_vignette.check_title = FALSE)

## ----message= FALSE, warning=FALSE--------------------------------------------
library(omock)
library(CohortSymmetry)
library(visOmopResults)
library(dplyr)

## ----message= FALSE, warning=FALSE--------------------------------------------
library(dplyr)
library(CodelistGenerator)
library(CohortConstructor)

cdm <- mockCdmFromDataset(datasetName = "GiBleed")

index_codelist <- CodelistGenerator::getDrugIngredientCodes(
  cdm = cdm,
  name = "aspirin",
  nameStyle = "{concept_name}"
)

cdm[["index"]] <- CohortConstructor::conceptCohort(
  cdm = cdm,
  conceptSet = index_codelist,
  exit = "event_end_date",
  name = "index")


marker_codelist <- CodelistGenerator::getDrugIngredientCodes(
  cdm = cdm,
  name = "amoxicillin",
  nameStyle = "{concept_name}"
)

cdm[["marker"]] <- CohortConstructor::conceptCohort(
  cdm = cdm,
  conceptSet = marker_codelist,
  exit = "event_end_date",
  name = "marker")


## ----message= FALSE, warning=FALSE--------------------------------------------
cdm$intersect <- sequenceCohort(
  cdm = cdm,
  indexCohortTable = "index",
  markerCohortTable = "marker",
  name = "intersect",
  combinationWindow = c(0, 365)
)

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm$intersect |> 
  dplyr::glimpse()

## ----message= FALSE, warning=FALSE--------------------------------------------
temporal_symmetry <- summariseTemporalSymmetry(
  cohort = cdm$intersect, 
  days = 30)

## ----message= FALSE, warning=FALSE--------------------------------------------
tableTemporalSymmetry(result = temporal_symmetry)

## ----message= FALSE, warning=FALSE--------------------------------------------
plotTemporalSymmetry(result = temporal_symmetry)

## ----message= FALSE, warning=FALSE--------------------------------------------
sequence_ratio <- summariseSequenceRatios(cohort = cdm$intersect)

## ----message= FALSE, warning=FALSE--------------------------------------------
tableSequenceRatios(result = sequence_ratio)

## ----message= FALSE, warning=FALSE--------------------------------------------
plotSequenceRatios(result = sequence_ratio)

## ----echo=FALSE, message=FALSE, out.width="100%", warning=FALSE---------------
library(here)
knitr::include_graphics(here("vignettes/workflow.png"))

