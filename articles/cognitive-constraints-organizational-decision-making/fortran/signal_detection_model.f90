program signal_detection_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: load, safety, dprime, criterion, hit_probability, false_alarm_probability
  real :: hit_sum, fa_sum, dprime_sum
  real :: u1, u2

  call random_seed()

  hit_sum = 0.0
  fa_sum = 0.0
  dprime_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)

     load = 10.0 * u1
     safety = 10.0 * u2

     ! Cognitive load reduces sensitivity to weak signals.
     ! Psychological safety improves reporting and detection.
     dprime = 2.2 - 0.12 * load + 0.08 * safety
     if (dprime < 0.1) dprime = 0.1

     ! Higher institutional pressure can be represented as a stricter criterion.
     criterion = 0.4 + 0.04 * load - 0.03 * safety

     hit_probability = logistic(dprime - criterion)
     false_alarm_probability = logistic(-criterion)

     hit_sum = hit_sum + hit_probability
     fa_sum = fa_sum + false_alarm_probability
     dprime_sum = dprime_sum + dprime
  end do

  print *, "Signal detection model for organizational risk recognition"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum / n
  print *, "Mean hit probability: ", hit_sum / n
  print *, "Mean false alarm probability: ", fa_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program signal_detection_model
