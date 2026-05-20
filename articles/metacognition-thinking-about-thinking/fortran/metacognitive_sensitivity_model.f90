program metacognitive_sensitivity_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: difficulty, evidence, confidence, accuracy_signal
  real :: dprime, criterion, correct_monitoring, false_confidence
  real :: correct_sum, false_confidence_sum, dprime_sum
  real :: u1, u2, u3, u4

  call random_seed()

  correct_sum = 0.0
  false_confidence_sum = 0.0
  dprime_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)

     difficulty = 10.0 * u1
     evidence = 10.0 * u2
     confidence = u3
     accuracy_signal = u4

     ! Metacognitive sensitivity improves with evidence and declines with difficulty.
     dprime = 0.8 + 0.10 * evidence - 0.08 * difficulty
     if (dprime < 0.1) dprime = 0.1

     ! Low evidence and high confidence can lower criterion and increase false confidence.
     criterion = 0.55 + 0.04 * difficulty - 0.05 * evidence - 0.20 * confidence

     correct_monitoring = logistic(dprime - criterion)
     false_confidence = logistic(-criterion)

     correct_sum = correct_sum + correct_monitoring
     false_confidence_sum = false_confidence_sum + false_confidence
     dprime_sum = dprime_sum + dprime
  end do

  print *, "Metacognitive sensitivity model"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum / n
  print *, "Mean correct-monitoring probability: ", correct_sum / n
  print *, "Mean false-confidence probability: ", false_confidence_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program metacognitive_sensitivity_model
