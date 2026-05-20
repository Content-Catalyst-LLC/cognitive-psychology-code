program category_discrimination_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: prototype_distance, feature_diagnosticity, boundary_ambiguity, feedback
  real :: dprime, criterion, hit_probability, false_alarm_probability
  real :: hit_sum, false_alarm_sum, dprime_sum
  real :: u1, u2, u3, u4

  call random_seed()

  hit_sum = 0.0
  false_alarm_sum = 0.0
  dprime_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)

     prototype_distance = 10.0 * u1
     feature_diagnosticity = 10.0 * u2
     boundary_ambiguity = 10.0 * u3
     feedback = merge(1.0, 0.0, u4 < 0.5)

     ! Sensitivity improves with diagnostic features and feedback,
     ! but declines with distance from prototype and category-boundary ambiguity.
     dprime = 0.8 + 0.12 * feature_diagnosticity + 0.22 * feedback - 0.08 * prototype_distance - 0.10 * boundary_ambiguity
     if (dprime < 0.1) dprime = 0.1

     ! Ambiguity lowers decision criterion, increasing false positives.
     criterion = 0.55 + 0.04 * prototype_distance - 0.03 * feature_diagnosticity - 0.05 * boundary_ambiguity

     hit_probability = logistic(dprime - criterion)
     false_alarm_probability = logistic(-criterion)

     hit_sum = hit_sum + hit_probability
     false_alarm_sum = false_alarm_sum + false_alarm_probability
     dprime_sum = dprime_sum + dprime
  end do

  print *, "Category discrimination model"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum / n
  print *, "Mean hit probability: ", hit_sum / n
  print *, "Mean false alarm probability: ", false_alarm_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program category_discrimination_model
