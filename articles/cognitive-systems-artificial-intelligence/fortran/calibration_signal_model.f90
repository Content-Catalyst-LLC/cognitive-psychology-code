program calibration_signal_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: uncertainty, explanation, calibration_error, trust, override_prob
  real :: trust_sum, override_sum, calibration_sum
  real :: u1, u2, u3

  call random_seed()

  trust_sum = 0.0
  override_sum = 0.0
  calibration_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)

     uncertainty = 10.0 * u1
     explanation = 10.0 * u2

     calibration_error = 0.05 + 0.02 * uncertainty - 0.006 * explanation + 0.05 * u3
     if (calibration_error < 0.0) calibration_error = 0.0
     if (calibration_error > 1.0) calibration_error = 1.0

     trust = 4.0 + 0.45 * explanation - 8.0 * calibration_error - 0.10 * uncertainty
     if (trust < 0.0) trust = 0.0
     if (trust > 10.0) trust = 10.0

     override_prob = logistic(1.2 - 0.35 * explanation - 0.18 * trust + 3.0 * calibration_error)

     trust_sum = trust_sum + trust
     override_sum = override_sum + override_prob
     calibration_sum = calibration_sum + calibration_error
  end do

  print *, "Calibration and override model for cognitive AI systems"
  print *, "Trials: ", n
  print *, "Mean calibration error: ", calibration_sum / n
  print *, "Mean trust: ", trust_sum / n
  print *, "Mean override probability: ", override_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program calibration_signal_model
