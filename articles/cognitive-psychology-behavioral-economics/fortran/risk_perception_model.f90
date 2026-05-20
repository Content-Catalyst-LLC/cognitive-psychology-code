program risk_perception_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: probability, loss_frame, cognitive_load, attention, dprime, criterion
  real :: risk_detection, false_alarm
  real :: detection_sum, false_alarm_sum, dprime_sum
  real :: u1, u2, u3, u4

  call random_seed()

  detection_sum = 0.0
  false_alarm_sum = 0.0
  dprime_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)

     probability = u1
     loss_frame = merge(1.0, 0.0, u2 < 0.5)
     cognitive_load = 10.0 * u3
     attention = 10.0 * u4

     dprime = 1.2 + 1.1 * probability + 0.35 * loss_frame - 0.08 * cognitive_load + 0.07 * attention
     if (dprime < 0.1) dprime = 0.1

     criterion = 0.6 - 0.25 * loss_frame + 0.03 * cognitive_load - 0.02 * attention

     risk_detection = logistic(dprime - criterion)
     false_alarm = logistic(-criterion)

     detection_sum = detection_sum + risk_detection
     false_alarm_sum = false_alarm_sum + false_alarm
     dprime_sum = dprime_sum + dprime
  end do

  print *, "Risk perception model for behavioral economics"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum / n
  print *, "Mean risk detection probability: ", detection_sum / n
  print *, "Mean false alarm probability: ", false_alarm_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program risk_perception_model
