## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  warning = FALSE,
  message = FALSE,
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5,
  eval = Sys.getenv("$RUNNER_OS") != "macOS"
)

## ----message= FALSE, warning=FALSE, include=FALSE-----------------------------
# Load libraries
library(dplyr)
library(CohortSymmetry)
library(CohortConstructor)
library(omock)

# Get mock data from omock
cdm <- mockCdmFromDataset(datasetName = "GiBleed")

# Generate index-marker cohorts
aspirin_codelist <- CodelistGenerator::getDrugIngredientCodes(
  cdm = cdm,
  name = "aspirin",
  nameStyle = "{concept_name}"
)

cdm[["aspirin"]] <- CohortConstructor::conceptCohort(
  cdm = cdm,
  conceptSet = aspirin_codelist,
  exit = "event_end_date",
  name = "aspirin")


amoxicillin_codelist <- CodelistGenerator::getDrugIngredientCodes(
  cdm = cdm,
  name = "amoxicillin",
  nameStyle = "{concept_name}"
)

cdm[["amoxicillin"]] <- CohortConstructor::conceptCohort(
  cdm = cdm,
  conceptSet = amoxicillin_codelist,
  exit = "event_end_date",
  name = "amoxicillin")

# Generate a sequence cohort
cdm$intersect <- sequenceCohort(
  cdm = cdm,
  indexCohortTable = "aspirin",
  markerCohortTable = "amoxicillin",
  name = "intersect")


## ----message= FALSE, warning=FALSE--------------------------------------------
temporal_symmetry <- summariseTemporalSymmetry(cohort = cdm$intersect)

## ----message= FALSE, warning=FALSE--------------------------------------------
tableTemporalSymmetry(result = temporal_symmetry)

## ----message= FALSE, warning=FALSE--------------------------------------------
plotTemporalSymmetry(result = temporal_symmetry)

