program workload_threshold_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: intrinsic, extraneous, germane, capacity, prior, total_load
  real :: margin, p_success, effort, efficiency
  real :: success_sum, effort_sum, efficiency_sum
  real :: u1, u2, u3, u4, u5

  call random_seed()

  success_sum = 0.0
  effort_sum = 0.0
  efficiency_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)
     call random_number(u5)

     intrinsic = 10.0 * u1
     extraneous = 10.0 * u2
     germane = 10.0 * u3
     prior = 10.0 * u4
     capacity = 3.0 + 6.0 * u5 + 0.15 * prior

     total_load = intrinsic + extraneous + 0.55 * germane
     margin = capacity + 0.45 * prior - total_load
     p_success = logistic(-0.6 + 0.55 * margin + 0.24 * germane - 0.22 * extraneous)

     effort = 4.0 + 0.35 * intrinsic + 0.50 * extraneous + 0.18 * germane - 0.22 * prior
     if (effort < 0.0) effort = 0.0
     if (effort > 10.0) effort = 10.0

     efficiency = (p_success - effort / 10.0) / sqrt(2.0)

     success_sum = success_sum + p_success
     effort_sum = effort_sum + effort
     efficiency_sum = efficiency_sum + efficiency
  end do

  print *, "Cognitive workload threshold model"
  print *, "Trials: ", n
  print *, "Mean success probability: ", success_sum / n
  print *, "Mean effort: ", effort_sum / n
  print *, "Mean mental efficiency: ", efficiency_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program workload_threshold_model
