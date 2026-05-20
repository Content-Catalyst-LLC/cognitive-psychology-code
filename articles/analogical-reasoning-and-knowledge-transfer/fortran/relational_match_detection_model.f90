program relational_match_detection_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: structural_similarity, surface_similarity, complexity, wm_load
  real :: dprime, criterion, hit_probability, false_alarm_probability
  real :: hit_sum, fa_sum, dprime_sum
  real :: u1, u2, u3, u4

  call random_seed()

  hit_sum = 0.0
  fa_sum = 0.0
  dprime_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)

     structural_similarity = 10.0 * u1
     surface_similarity = 10.0 * u2
     complexity = 10.0 * u3
     wm_load = 10.0 * u4

     ! Sensitivity to true relational match increases with structure,
     ! but decreases with relational complexity and working-memory burden.
     dprime = 0.8 + 0.14 * structural_similarity - 0.07 * complexity - 0.06 * wm_load
     if (dprime < 0.1) dprime = 0.1

     ! High surface similarity can lower decision criterion, increasing false alarms.
     criterion = 0.55 - 0.04 * surface_similarity + 0.04 * complexity

     hit_probability = logistic(dprime - criterion)
     false_alarm_probability = logistic(-criterion)

     hit_sum = hit_sum + hit_probability
     fa_sum = fa_sum + false_alarm_probability
     dprime_sum = dprime_sum + dprime
  end do

  print *, "Relational match detection model for analogical reasoning"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum / n
  print *, "Mean hit probability: ", hit_sum / n
  print *, "Mean false alarm probability: ", fa_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program relational_match_detection_model
