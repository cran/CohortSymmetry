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

cdm$aspirin |> 
  dplyr::glimpse()

cdm$acetaminophen |> 
  dplyr::glimpse()

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
  indexMarkerGap = NULL, #default
  combinationWindow = c(0,Inf))

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

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
  combinationWindow = c(0,Inf))

cdm$intersect |>  
  dplyr::summarise(min_cohort_start_date = min(cohort_start_date), 
            max_cohort_start_date = max(cohort_start_date),
            min_cohort_end_date   = min(cohort_end_date),
            max_cohort_end_date   = max(cohort_end_date)) |> 
  dplyr::glimpse()

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/3-PriorObservation.png"))

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
  daysPriorObservation = 0,
  combinationWindow = c(0,Inf))

cdm$intersect |> 
  dplyr::inner_join(
    cdm$observation_period |> 
      dplyr::select("subject_id" = "person_id", "observation_period_start_date")
  ) |> 
  dplyr::filter(subject_id %in% c(2,53)) |> 
  dplyr::mutate(daysPriorObservation = cohort_start_date - observation_period_start_date) |> 
  dplyr::glimpse()

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  cohortDateRange = as.Date(c("1950-01-01","1980-01-01")),
  daysPriorObservation = 365,
  combinationWindow = c(0,Inf))

cdm$intersect |> 
  dplyr::inner_join(
    cdm$observation_period |> 
      dplyr::select("subject_id" = "person_id", "observation_period_start_date")
  ) |> 
  dplyr::filter(subject_id %in% c(2,53)) |>
  dplyr::glimpse()

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/4-washoutPeriod.png"))

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  cohortDateRange = as.Date(c("1950-01-01","1980-01-01")),
  daysPriorObservation = 365,
  washoutWindow = 0,
  combinationWindow = c(0, Inf))

cdm$aspirin |> 
  dplyr::filter(subject_id %in% c(1936,3565)) |> 
  dplyr::group_by(subject_id) |> 
  dplyr::arrange(cohort_start_date)

cdm$intersect |> 
  dplyr::filter(subject_id %in% c(1936,3565)) |> 
  dplyr::glimpse()

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
  daysPriorObservation = 365,
  washoutWindow = 365,
  combinationWindow = c(0, Inf))

cdm$intersect |> 
  dplyr::filter(subject_id %in% c(1936,3565)) |>
  dplyr::arrange(subject_id, cohort_start_date) |>
  dplyr::glimpse()

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/5-combinationWindow_numbers.png"))

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
  daysPriorObservation = 365,
  combinationWindow = c(0, Inf))

cdm$intersect |>
  dplyr::filter(subject_id %in% c(80,187)) |>
  dplyr::mutate(combinationWindow = pmax(index_date, marker_date) - pmin(index_date, marker_date))

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
  daysPriorObservation = 365,
  combinationWindow = c(0, Inf))

cdm$intersect |>
  dplyr::filter(subject_id %in% c(80,187))

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/6-indexGap.png"))

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
  daysPriorObservation = 365,
  indexMarkerGap = NULL)

cdm$intersect |>
  dplyr::filter(subject_id %in% c(80,754)) |>
  dplyr::inner_join(
    # As for both, acetaminophen (marker) is the first event:
    cdm$acetaminophen |> 
      dplyr::select("subject_id", 
             "marker_date" = "cohort_start_date", 
             "first_episode_end_date" = "cohort_end_date"),
    by = c("subject_id", "marker_date")
  ) |>
  dplyr::inner_join(
    cdm$aspirin |> 
      dplyr::select("subject_id", 
             "index_date" = "cohort_start_date",
             "second_episode_start_date" = "cohort_start_date"),
    by = c("subject_id", "index_date")
  ) |>
  dplyr::mutate(indexMarkerGap = second_episode_start_date - first_episode_end_date)
  

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "aspirin",
  markerTable = "acetaminophen",
  name = "intersect",
  cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
  daysPriorObservation = 365,
  indexMarkerGap = 30)

cdm$intersect |>
  dplyr::filter(subject_id %in% c(80,754)) 

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
#  CDMConnector::cdmDisconnect(cdm = cdm)

