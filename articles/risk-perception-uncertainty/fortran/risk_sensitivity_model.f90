program risk_sensitivity_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: probability, consequence, affect, ambiguity, trust
  real :: dprime, criterion, risk_detection, false_alarm
  real :: detection_sum, false_sum, dprime_sum
  real :: u1, u2, u3, u4, u5

  call random_seed()

  detection_sum = 0.0
  false_sum = 0.0
  dprime_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)
     call random_number(u5)

     probability = u1
     consequence = 10.0 * u2
     affect = 10.0 * u3
     ambiguity = 10.0 * u4
     trust = 10.0 * u5

     ! Sensitivity to real risk rises with probability, consequence, affect, and ambiguity.
     dprime = 0.4 + 1.2 * probability + 0.08 * consequence + 0.06 * affect + 0.05 * ambiguity
     if (dprime < 0.1) dprime = 0.1

     ! Trust and clarity can raise the threshold for alarm; ambiguity lowers it.
     criterion = 0.65 + 0.04 * trust - 0.04 * ambiguity - 0.03 * affect

     risk_detection = logistic(dprime - criterion)
     false_alarm = logistic(-criterion)

     detection_sum = detection_sum + risk_detection
     false_sum = false_sum + false_alarm
     dprime_sum = dprime_sum + dprime
  end do

  print *, "Risk sensitivity model"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum / n
  print *, "Mean risk-detection probability: ", detection_sum / n
  print *, "Mean false-alarm probability: ", false_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program risk_sensitivity_model
