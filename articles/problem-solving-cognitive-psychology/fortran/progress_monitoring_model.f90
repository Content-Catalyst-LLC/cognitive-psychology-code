program progress_monitoring_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: metacognition, wm_load, representation, difficulty
  real :: dprime, criterion, progress_detection, false_progress
  real :: detection_sum, false_progress_sum, dprime_sum
  real :: u1, u2, u3, u4

  call random_seed()

  detection_sum = 0.0
  false_progress_sum = 0.0
  dprime_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)

     metacognition = 10.0 * u1
     wm_load = 10.0 * u2
     representation = 10.0 * u3
     difficulty = 10.0 * u4

     ! Sensitivity to real progress improves with metacognition and representation,
     ! and declines under high working-memory load and problem difficulty.
     dprime = 0.8 + 0.12 * metacognition + 0.10 * representation - 0.07 * wm_load - 0.06 * difficulty
     if (dprime < 0.1) dprime = 0.1

     ! High difficulty and low metacognition make false progress more likely.
     criterion = 0.55 + 0.04 * difficulty - 0.05 * metacognition

     progress_detection = logistic(dprime - criterion)
     false_progress = logistic(-criterion)

     detection_sum = detection_sum + progress_detection
     false_progress_sum = false_progress_sum + false_progress
     dprime_sum = dprime_sum + dprime
  end do

  print *, "Progress monitoring model for problem solving"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum / n
  print *, "Mean progress-detection probability: ", detection_sum / n
  print *, "Mean false-progress probability: ", false_progress_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program progress_monitoring_model
