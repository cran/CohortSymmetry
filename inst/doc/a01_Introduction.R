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
library(CDMConnector)
library(dplyr)
library(DBI)
library(omock)
library(CohortSymmetry)
library(duckdb)

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm <- emptyCdmReference(cdmName = "mock") |>
  mockPerson(nPerson = 100) |>
  mockObservationPeriod() |>
  mockCohort(
    name = "index_cohort",
    numberCohorts = 1,
    cohortName = c("index_cohort"),
    seed = 1,
  ) |>
  mockCohort(
    name = "marker_cohort",
    numberCohorts = 1,
    cohortName = c("marker_cohort"), 
    seed = 2
  )

con <- dbConnect(duckdb::duckdb())
cdm <- copyCdmTo(con = con, cdm = cdm, schema = "main", overwrite = T)

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm <- generateSequenceCohortSet(
  cdm = cdm,
  indexTable = "index_cohort",
  markerTable = "marker_cohort",
  name = "intersect",
  combinationWindow = c(0, Inf)
)

## ----message= FALSE, warning=FALSE--------------------------------------------
cdm$intersect |> 
  dplyr::glimpse()

## ----message= FALSE, warning=FALSE--------------------------------------------
temporal_symmetry <- summariseTemporalSymmetry(
  cohort = cdm$intersect, 
  timescale = "year")

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

