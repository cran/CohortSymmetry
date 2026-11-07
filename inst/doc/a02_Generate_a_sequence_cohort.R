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

## ----message= FALSE, warning=FALSE--------------------------------------------
library(omock)
library(CohortSymmetry)

cdm <- mockCdmFromDataset(datasetName = "GiBleed")


## ----message= FALSE, warning=FALSE--------------------------------------------
library(dplyr)
library(CodelistGenerator)
library(CohortConstructor)

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


## ----message= FALSE, warning=FALSE--------------------------------------------
library(DrugUtilisation)

cdm <- DrugUtilisation::generateIngredientCohortSet(
  cdm = cdm, 
  name = "aspirin",
  ingredient = "aspirin")

cdm <- DrugUtilisation::generateIngredientCohortSet(
  cdm = cdm,
  name = "amoxicillin",
  ingredient = "amoxicillin")


## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
library(here)
knitr::include_graphics(here("vignettes/1-NoRestrictions.png"))

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm$intersect <- sequenceCohort(
  cdm = cdm,
  indexCohortTable = "aspirin",
  markerCohortTable = "amoxicillin",
  name = "intersect",
  cohortDateRange = as.Date(c(NA, NA)), 
  sequencePriorObservation = 0, 
  indexMarkerWashout = 0,
  indexMarkerGap = Inf, 
  combinationWindow = c(0,Inf)) 

cdm$intersect |> 
  dplyr::glimpse()

## ----message= FALSE, warning=FALSE--------------------------------------------
attr(cdm$intersect, "cohort_set")

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
# cdm$intersect <- sequenceCohort(
#   cdm = cdm,
#   indexCohortTable = "aspirin",
#   markerCohortTable = "amoxicillin",
#   name = "intersect",
#   cohortDateRange = as.Date(c(NA, NA)),
#   indexCohortId = 1,
#   markerCohortId = 1,
#   sequencePriorObservation = 0,
#   indexMarkerWashout = 0,
#   indexMarkerGap = Inf,
#   combinationWindow = c(0,Inf))

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/2-studyPeriod.png"))

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
# cdm$intersect <- sequenceCohort(
#   cdm = cdm,
#   indexCohortTable = "aspirin",
#   markerCohortTable = "amoxicillin",
#   name = "intersect_study_period",
#   sequencePriorObservation = 0,
#   indexMarkerWashout = 0,
#   indexMarkerGap = Inf,
#   cohortDateRange = as.Date(c("1950-01-01","1969-01-01")))

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/3-PriorObservation.png"))

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
# cdm$intersect <- sequenceCohort(
#   cdm = cdm,
#   indexCohortTable = "aspirin",
#   markerCohortTable = "amoxicillin",
#   name = "intersect_prior_obs",
#   cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
#   sequencePriorObservation = 365,
#   indexMarkerWashout = 0,
#   indexMarkerGap = Inf)

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/4-washoutPeriod.png"))

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
# cdm$intersect <- sequenceCohort(
#   cdm = cdm,
#   indexCohortTable = "aspirin",
#   markerCohortTable = "amoxicillin",
#   name = "intersect_washout",
#   cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
#   sequencePriorObservation = 365,
#   indexMarkerWashout = 365,
#   indexMarkerGap = Inf)

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/5-combinationWindow_numbers.png"))

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
# cdm$intersect <- sequenceCohort(
#   cdm = cdm,
#   indexCohortTable = "aspirin",
#   markerCohortTable = "amoxicillin",
#   name = "intersect_changed_cw",
#   cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
#   sequencePriorObservation = 365,
#   indexMarkerWashout = 365,
#   indexMarkerGap = Inf,
#   combinationWindow = c(0, Inf))
# 
#  cdm$intersect_changed_cw |>
#    dplyr::filter(subject_id %in% c(80,187)) |>
#    dplyr::mutate(combinationWindow = pmax(index_date, marker_date) - pmin(index_date, marker_date))

## ----echo=FALSE, message=FALSE, out.width="80%", warning=FALSE----------------
knitr::include_graphics(here("vignettes/6-indexGap.png"))

## ----message= FALSE, warning=FALSE, eval=FALSE--------------------------------
# cdm$intersect <- sequenceCohort(
#   cdm = cdm,
#   indexCohortTable = "aspirin",
#   markerCohortTable = "amoxicillin",
#   name = "intersect_",
#   cohortDateRange = as.Date(c("1950-01-01","1969-01-01")),
#   sequencePriorObservation = 365,
#   indexMarkerWashout = 365,
#   indexMarkerGap = 7)

