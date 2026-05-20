program warning_detection_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: perceptual_load, attentional_demand, alignment, dprime, criterion
  real :: hit_probability, false_alarm_probability
  real :: hit_sum, fa_sum, dprime_sum
  real :: u1, u2, u3

  call random_seed()

  hit_sum = 0.0
  fa_sum = 0.0
  dprime_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)

     perceptual_load = 10.0 * u1
     attentional_demand = 10.0 * u2
     alignment = 10.0 * u3

     ! Perceptual and attentional load reduce sensitivity to warnings.
     ! Alignment improves recognition of meaningful cues.
     dprime = 2.4 - 0.10 * perceptual_load - 0.12 * attentional_demand + 0.08 * alignment
     if (dprime < 0.1) dprime = 0.1

     criterion = 0.35 + 0.04 * perceptual_load + 0.03 * attentional_demand - 0.02 * alignment

     hit_probability = logistic(dprime - criterion)
     false_alarm_probability = logistic(-criterion)

     hit_sum = hit_sum + hit_probability
     fa_sum = fa_sum + false_alarm_probability
     dprime_sum = dprime_sum + dprime
  end do

  print *, "Warning detection model for human-computer interaction"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum / n
  print *, "Mean hit probability: ", hit_sum / n
  print *, "Mean false alarm probability: ", fa_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program warning_detection_model
