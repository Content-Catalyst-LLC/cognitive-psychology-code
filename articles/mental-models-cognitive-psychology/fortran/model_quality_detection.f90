program model_quality_detection
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: completeness, coherence, causal, loops, complexity
  real :: dprime, criterion, correct_model_probability, false_confidence_probability
  real :: correct_sum, false_sum, dprime_sum
  real :: u1, u2, u3, u4, u5

  call random_seed()

  correct_sum = 0.0
  false_sum = 0.0
  dprime_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)
     call random_number(u5)

     completeness = 10.0 * u1
     coherence = 10.0 * u2
     causal = 10.0 * u3
     loops = 10.0 * u4
     complexity = 10.0 * u5

     ! Sensitivity to system structure improves with model quality and declines with complexity.
     dprime = 0.5 + 0.06 * completeness + 0.07 * coherence + 0.09 * causal + 0.08 * loops - 0.06 * complexity
     if (dprime < 0.1) dprime = 0.1

     ! High complexity and weak coherence increase risk of false confidence.
     criterion = 0.55 + 0.04 * complexity - 0.03 * coherence - 0.03 * causal

     correct_model_probability = logistic(dprime - criterion)
     false_confidence_probability = logistic(-criterion)

     correct_sum = correct_sum + correct_model_probability
     false_sum = false_sum + false_confidence_probability
     dprime_sum = dprime_sum + dprime
  end do

  print *, "Mental-model quality detection"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum / n
  print *, "Mean correct-model probability: ", correct_sum / n
  print *, "Mean false-confidence probability: ", false_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program model_quality_detection
