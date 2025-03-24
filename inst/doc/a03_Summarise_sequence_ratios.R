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
if (!CDMConnector::eunomiaIsAvailable())
  CDMConnector::downloadEunomiaData()

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
                     dbdir = CDMConnector::eunomiaDir())
cdm <- cdmFromCon(
  con = db,
  cdmSchema = "main",
  writeSchema = "main"
)

cdm <- DrugUtilisation::generateIngredientCohortSet(
  cdm = cdm,
  name = "aspirin",
  ingredient = "aspirin")

cdm <- DrugUtilisation::generateIngredientCohortSet(
  cdm = cdm,
  name = "acetaminophen",
  ingredient = "acetaminophen")

## ----message= FALSE, warning=FALSE--------------------------------------------
# Generate a sequence cohort
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  combinationWindow = c(0,Inf))

## ----message = FALSE, warning = FALSE-----------------------------------------
summariseSequenceRatios(
  cohort = cdm$intersect
) |> 
  dplyr::glimpse()

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
#  CDMConnector::cdmDisconnect(cdm = cdm)

