program comprehension_detection_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: frequency, syntax, ambiguity, context, wm_load, discourse
  real :: dprime, criterion, hit_probability, false_alarm_probability
  real :: hit_sum, false_alarm_sum, dprime_sum
  real :: u1, u2, u3, u4, u5, u6

  call random_seed()

  hit_sum = 0.0
  false_alarm_sum = 0.0
  dprime_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)
     call random_number(u5)
     call random_number(u6)

     frequency = 10.0 * u1
     syntax = 10.0 * u2
     ambiguity = 10.0 * u3
     context = 10.0 * u4
     wm_load = 10.0 * u5
     discourse = 10.0 * u6

     ! Sensitivity to correct comprehension improves with frequency,
     ! context, and discourse coherence; it declines under syntax, ambiguity,
     ! and working-memory load.
     dprime = 0.8 + 0.08 * frequency + 0.10 * context + 0.08 * discourse - 0.08 * syntax - 0.07 * ambiguity - 0.07 * wm_load
     if (dprime < 0.1) dprime = 0.1

     ! High ambiguity and low context can lower criterion, increasing false understanding.
     criterion = 0.55 + 0.04 * syntax + 0.03 * ambiguity - 0.04 * context - 0.03 * discourse

     hit_probability = logistic(dprime - criterion)
     false_alarm_probability = logistic(-criterion)

     hit_sum = hit_sum + hit_probability
     false_alarm_sum = false_alarm_sum + false_alarm_probability
     dprime_sum = dprime_sum + dprime
  end do

  print *, "Comprehension detection model"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum / n
  print *, "Mean correct-comprehension probability: ", hit_sum / n
  print *, "Mean false-understanding probability: ", false_alarm_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program comprehension_detection_model
