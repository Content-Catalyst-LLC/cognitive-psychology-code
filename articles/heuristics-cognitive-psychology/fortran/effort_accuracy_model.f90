program effort_accuracy_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: cue_validity, cue_count, information_cost, time_pressure
  real :: heuristic_accuracy, analytic_accuracy, heuristic_effort, analytic_effort
  real :: lambda, heuristic_utility, analytic_utility
  real :: heuristic_utility_sum, analytic_utility_sum
  real :: u1, u2, u3, u4

  call random_seed()

  heuristic_utility_sum = 0.0
  analytic_utility_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)

     cue_validity = 0.3 + 0.65 * u1
     cue_count = 1.0 + 9.0 * u2
     information_cost = 10.0 * u3
     time_pressure = 10.0 * u4
     lambda = 0.08 + 0.02 * time_pressure

     heuristic_accuracy = logistic(-0.4 + 2.0 * cue_validity + 0.10 * cue_count - 0.05 * information_cost)
     analytic_accuracy = logistic(-0.7 + 2.6 * cue_validity + 0.18 * cue_count - 0.04 * time_pressure)

     heuristic_effort = 2.0 + 0.22 * cue_count + 0.15 * information_cost
     analytic_effort = 5.0 + 0.45 * cue_count + 0.28 * information_cost

     heuristic_utility = heuristic_accuracy - lambda * heuristic_effort
     analytic_utility = analytic_accuracy - lambda * analytic_effort

     heuristic_utility_sum = heuristic_utility_sum + heuristic_utility
     analytic_utility_sum = analytic_utility_sum + analytic_utility
  end do

  print *, "Effort-accuracy tradeoff model"
  print *, "Trials: ", n
  print *, "Mean heuristic utility: ", heuristic_utility_sum / n
  print *, "Mean analytic utility: ", analytic_utility_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program effort_accuracy_model
