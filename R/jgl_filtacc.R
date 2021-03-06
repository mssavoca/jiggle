#' Band pass filter acceleration
#'
#' Filter the acceleration signal between low and high frequency thresholds.
#'
#' @param A Acceleration data frame. Columns \code{Atime} (POSIXct) and
#'   \code{A} (3-column matrix) with an attribute, \code{Afs}, for the sampling
#'   frequency.
#' @param low,high Low and high cutoff frequencies for band-pass filter. 10 Hz
#'   and 90 Hz by default.
#'
#' @return Same as \code{A} but band-pass filtered acceleration in acceleration
#'   matrix (\code{A$A}) and attribute (\code{filtered}) to indicate filtering.
#'
#' @examples
#' jgl_filtacc(Araw_expl)
#'
#' @export
jgl_filtacc <- function(A, low = 10, high = 90) {
  # A$A must be a 3d numeric matrix
  if (!is.matrix(A$A)) {
    stop("`A$A` must be a matrix")
  }
  if (!is.numeric(A$A)) {
    stop("`A` must be numeric")
  }
  if (ncol(A$A) != 3) {
    stop(sprintf("`A` must have 3 columns, not %d", ncol(A)))
  }

  # Afs, low, and high must all be scalar numbers
  # There has to be a way to avoid repeating this
  Afs <- attr(A, "Afs")
  if (!is.numeric(Afs) || length(Afs) > 1) {
    stop("Afs must be a scalar")
  }
  if (!is.numeric(low) || length(low) > 1) {
    stop("low must be a scalar")
  }
  if (!is.numeric(high) || length(high) > 1) {
    stop("high must be a scalar")
  }

  # Can't filter above the Nyquist frequency
  nyquist <- Afs / 2
  if (high > nyquist) {
    stop(sprintf(
      "`high` (%.2f) must be less than the Nyquist frequency (Afs / 2 = %.2f)",
      high,
      nyquist
    ))
  }

  freq <- c(low, high) / nyquist
  h <- signal::fir1(127, freq, "pass")
  A$A <- apply(A$A, 2, function(col) signal::filtfilt(h, col))
  attr(A, "filtered") <- TRUE
  A
}
