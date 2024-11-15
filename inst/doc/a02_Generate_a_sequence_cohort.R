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

## ----message= FALSE, warning=FALSE--------------------------------------------
library(CDMConnector)
library(dplyr)
library(DBI)
library(CohortSymmetry)
library(duckdb)

db <- DBI::dbConnect(duckdb::duckdb(), 
                     dbdir = CDMConnector::eunomia_dir())
cdm <- cdm_from_con(
  con = db,
  cdm_schema = "main",
  write_schema = "main"
)

## ----message= FALSE, warning=FALSE--------------------------------------------
library(DrugUtilisation)
cdm <- DrugUtilisation::generateIngredientCohortSet(
  cdm = cdm,
  name = "aspirin",
  ingredient = "aspirin")

cdm <- DrugUtilisation::generateIngredientCohortSet(
  cdm = cdm,
  name = "acetaminophen",
  ingredient = "acetaminophen")

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
library(here)
knitr::include_graphics(here("vignettes/1-NoRestrictions.png"))

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  cohortDateRange = as.Date(c(NA, NA)), #default
  daysPriorObservation = 0, #default
  washoutWindow = 0, #default
  indexMarkerGap = Inf, #default
  combinationWindow = c(0,Inf)) # default

cdm$intersect |> 
  dplyr::glimpse()

## ----message= FALSE, warning=FALSE--------------------------------------------
attr(cdm$intersect, "cohort_set")

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
#  cdm <- generateSequenceCohortSet(
#    cdm = cdm,
#    indexTable = "aspirin",
#    markerTable = "acetaminophen",
#    name = "intersect",
#    cohortDateRange = as.Date(c(NA, NA)),
#    indexId = 1,
#    markerId = 1,
#    daysPriorObservation = 0,
#    washoutWindow = 0,
#    indexMarkerGap = NULL,
#    combinationWindow = c(0,Inf))

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/2-studyPeriod.png"))

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
#  cdm <- generateSequenceCohortSet(
#    cdm = cdm,
#    indexTable = "aspirin",
#    markerTable = "acetaminophen",
#    name = "intersect_study_period",
#    cohortDateRange = as.Date(c("1950-01-01","1969-01-01")))

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/3-PriorObservation.png"))

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
#   cdm <- generateSequenceCohortSet(
#     cdm = cdm,
#     indexTable = "aspirin",
#     markerTable = "acetaminophen",
#     name = "intersect_prior_obs",
#     cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
#     daysPriorObservation = 365)

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/4-washoutPeriod.png"))

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
#  cdm <- generateSequenceCohortSet(
#    cdm = cdm,
#    indexTable = "aspirin",
#    markerTable = "acetaminophen",
#    name = "intersect_washout",
#    cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
#    daysPriorObservation = 365,
#    washoutWindow = 365)

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/5-combinationWindow_numbers.png"))

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
#   cdm <- generateSequenceCohortSet(
#     cdm = cdm,
#     indexTable = "aspirin",
#     markerTable = "acetaminophen",
#     name = "intersect_changed_cw",
#     cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
#     daysPriorObservation = 365,
#     combinationWindow = c(0, Inf))
#  
#   cdm$intersect_changed_cw |>
#     dplyr::filter(subject_id %in% c(80,187)) |>
#     dplyr::mutate(combinationWindow = pmax(index_date, marker_date) - pmin(index_date, marker_date))

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/6-indexGap.png"))

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
#  cdm <- generateSequenceCohortSet(
#    cdm = cdm,
#    indexTable = "aspirin",
#    markerTable = "acetaminophen",
#    name = "intersect_",
#    cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
#    daysPriorObservation = 365,
#    indexMarkerGap = 7)

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
#  CDMConnector::cdmDisconnect(cdm = cdm)

