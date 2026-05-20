program semantic_verification_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: semantic_distance, typicality, associative_strength, false_association
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

     semantic_distance = 10.0 * u1
     typicality = 10.0 * u2
     associative_strength = 10.0 * u3
     false_association = merge(1.0, 0.0, u4 < 0.20)

     ! Sensitivity improves with typicality and association,
     ! and decreases with semantic distance and false association.
     dprime = 0.8 + 0.11 * typicality + 0.07 * associative_strength - 0.08 * semantic_distance - 0.25 * false_association
     if (dprime < 0.1) dprime = 0.1

     ! False associations reduce criterion, increasing false alarms.
     criterion = 0.55 + 0.04 * semantic_distance - 0.03 * associative_strength - 0.20 * false_association

     hit_probability = logistic(dprime - criterion)
     false_alarm_probability = logistic(-criterion)

     hit_sum = hit_sum + hit_probability
     false_alarm_sum = false_alarm_sum + false_alarm_probability
     dprime_sum = dprime_sum + dprime
  end do

  print *, "Semantic verification model"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum / n
  print *, "Mean hit probability: ", hit_sum / n
  print *, "Mean false alarm probability: ", false_alarm_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program semantic_verification_model
