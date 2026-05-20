program learning_sensitivity_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: prior, attention, feedback, load, retrieval
  real :: dprime, criterion, learned_probability, false_familiarity
  real :: learned_sum, false_sum, dprime_sum
  real :: u1, u2, u3, u4, u5

  call random_seed()

  learned_sum = 0.0
  false_sum = 0.0
  dprime_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)
     call random_number(u5)

     prior = 10.0 * u1
     attention = 10.0 * u2
     feedback = 10.0 * u3
     load = 10.0 * u4
     retrieval = merge(1.0, 0.0, u5 < 0.5)

     dprime = 0.6 + 0.07 * prior + 0.10 * attention + 0.08 * feedback + 0.20 * retrieval - 0.09 * load
     if (dprime < 0.1) dprime = 0.1

     criterion = 0.55 + 0.04 * load - 0.03 * feedback - 0.03 * attention

     learned_probability = logistic(dprime - criterion)
     false_familiarity = logistic(-criterion)

     learned_sum = learned_sum + learned_probability
     false_sum = false_sum + false_familiarity
     dprime_sum = dprime_sum + dprime
  end do

  print *, "Learning sensitivity model"
  print *, "Trials: ", n
  print *, "Mean d-prime: ", dprime_sum / n
  print *, "Mean durable-learning probability: ", learned_sum / n
  print *, "Mean false-familiarity probability: ", false_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program learning_sensitivity_model
