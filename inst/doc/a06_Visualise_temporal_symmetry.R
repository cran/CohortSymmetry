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

## ----include = FALSE----------------------------------------------------------
if (Sys.getenv("EUNOMIA_DATA_FOLDER") == "") Sys.setenv("EUNOMIA_DATA_FOLDER" = tempdir())
if (!dir.exists(Sys.getenv("EUNOMIA_DATA_FOLDER"))) dir.create(Sys.getenv("EUNOMIA_DATA_FOLDER"))
if (!CDMConnector::eunomia_is_available()) CDMConnector::downloadEunomiaData()

## ----message= FALSE, warning=FALSE, include=FALSE-----------------------------
# Load libraries
library(CDMConnector)
library(dplyr)
library(DBI)
library(CohortSymmetry)
library(duckdb)
library(DrugUtilisation)

# Connect to the database
db <- DBI::dbConnect(duckdb::duckdb(), 
                     dbdir = CDMConnector::eunomia_dir())
cdm <- cdm_from_con(
  con = db,
  cdm_schema = "main",
  write_schema = "main"
)

# Generate cohorts
aspirin_code <- CodelistGenerator::getDrugIngredientCodes(
  cdm = cdm, 
  name = "aspirin"
)
cdm <- DrugUtilisation::generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "aspirin",
  conceptSet = aspirin_code
)

acetaminophen_code <- CodelistGenerator::getDrugIngredientCodes(
  cdm = cdm, 
  name = "acetaminophen"
)

cdm <- DrugUtilisation::generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "acetaminophen",
  conceptSet = acetaminophen_code
)

# Generate a sequence cohort
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  combinationWindow = c(0,Inf))

## ----message= FALSE, warning=FALSE--------------------------------------------
temporal_symmetry <- summariseTemporalSymmetry(cohort = cdm$intersect)

## ----message= FALSE, warning=FALSE--------------------------------------------
plotTemporalSymmetry(result = temporal_symmetry)

## ----message= FALSE, warning=FALSE--------------------------------------------
temporal_symmetry_day <- summariseTemporalSymmetry(cohort = cdm$intersect, timescale = "day")

plotTemporalSymmetry(result = temporal_symmetry_day,
                     labs = c("Time (days)", "Individuals (N)"),
                     xlim = c(-365, 365))

## ----message= FALSE, warning=FALSE--------------------------------------------
plotTemporalSymmetry(result = temporal_symmetry,
                     plotTitle = "Plot Temporal Symmetry")

## ----message= FALSE, warning=FALSE--------------------------------------------
plotTemporalSymmetry(result = temporal_symmetry,
                     colours = c("orange", "purple"))

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
#  plotTemporalSymmetry(result = temporal_symmetry,
#                       scales = "fixed")

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
#  CDMConnector::cdmDisconnect(cdm = cdm)

