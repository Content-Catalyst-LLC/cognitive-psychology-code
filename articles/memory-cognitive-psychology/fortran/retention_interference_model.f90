program retention_interference_model
  implicit none
  integer, parameter :: n = 1000
  integer :: i
  real :: delay, initial, lambda, interference, cue_quality, strength, p, correct
  real :: strength_sum, retrieval_sum, correct_sum, u1, u2, u3, u4, u5
  call random_seed()
  strength_sum = 0.0; retrieval_sum = 0.0; correct_sum = 0.0
  do i = 1, n
     call random_number(u1); call random_number(u2); call random_number(u3); call random_number(u4); call random_number(u5)
     delay = 0.25 + 29.75 * u1
     initial = 0.55 + 0.70 * u2
     interference = 10.0 * u3
     cue_quality = 10.0 * u4
     lambda = max(0.01, min(0.35, 0.08 + 0.018 * interference - 0.006 * cue_quality))
     strength = initial * exp(-lambda * delay)
     p = logistic(-1.6 + 2.6 * strength + 0.16 * cue_quality - 0.20 * interference)
     correct = merge(1.0, 0.0, u5 < p)
     strength_sum = strength_sum + strength
     retrieval_sum = retrieval_sum + p
     correct_sum = correct_sum + correct
  end do
  print *, "Memory retention and interference model"
  print *, "Trials: ", n
  print *, "Mean retention strength: ", strength_sum / n
  print *, "Mean retrieval probability: ", retrieval_sum / n
  print *, "Correct retrieval rate: ", correct_sum / n
contains
  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic
end program retention_interference_model
