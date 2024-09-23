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
cdm <- DrugUtilisation::generateIngredientCohortSet(
  cdm = cdm,
  name = "aspirin",
  ingredient = "aspirin")

cdm <- DrugUtilisation::generateIngredientCohortSet(
  cdm = cdm,
  name = "acetaminophen",
  ingredient = "acetaminophen")

# Generate a sequence cohort
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  combinationWindow = c(0,Inf))

## ----message= FALSE, warning=FALSE--------------------------------------------
result <- summariseSequenceRatios(cohort = cdm$intersect)

## ----message= FALSE, warning=FALSE--------------------------------------------
tableSequenceRatios(result = result)

## ----message= FALSE, warning=FALSE--------------------------------------------
tableSequenceRatios(result = result,
                    studyPopulation = FALSE)

## ----message= FALSE, warning=FALSE--------------------------------------------
tableSequenceRatios(result = result,
                    cdmName = FALSE)

## ----message= FALSE, warning=FALSE--------------------------------------------
tableSequenceRatios(result = result,
                    .options = list(title = "Title"))

## ----message= FALSE, warning=FALSE--------------------------------------------
tableSequenceRatios(result = result,
                    type = "flextable")

## ----message= FALSE, warning=FALSE--------------------------------------------
tableSequenceRatios(result = result,
                    type = "tibble")

## ----message= FALSE, warning=FALSE--------------------------------------------
tableSequenceRatios(result = result,
                    type = "flextable",
                    style = NULL)

## ----message= FALSE, warning=FALSE--------------------------------------------
plotSequenceRatios(result = result)

## ----message= FALSE, warning=FALSE--------------------------------------------
plotSequenceRatios(result = result,
                   onlyaSR = T,
                   colours = "black")

## ----message= FALSE, warning=FALSE--------------------------------------------
plotSequenceRatios(result = result,
                   onlyaSR = T,
                   colours = "red")

## ----message= FALSE, warning=FALSE--------------------------------------------
plotSequenceRatios(result = result,
                   onlyaSR = T,
                   plotTitle = "Adjusted Sequence Ratio",
                   colour = "black")

## ----message= FALSE, warning=FALSE--------------------------------------------
plotSequenceRatios(result = result,
                   onlyaSR = T,
                   plotTitle = "Adjusted Sequence Ratio",
                   colour = "black",
                   labs = c("sequence ratios", "analysis"))

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
#  CDMConnector::cdmDisconnect(cdm = cdm)

