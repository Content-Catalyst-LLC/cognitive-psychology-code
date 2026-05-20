program load_accuracy_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: capacity, load, interference, attentional_control
  real :: cognitive_load, accuracy, rt, overload_probability
  real :: acc_sum, rt_sum, overload_sum
  real :: u1, u2, u3, u4

  call random_seed()

  acc_sum = 0.0
  rt_sum = 0.0
  overload_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)

     capacity = 2.0 + 5.0 * u1
     load = 1.0 + 9.0 * u2
     interference = 10.0 * u3
     attentional_control = 3.0 + 6.0 * u4

     cognitive_load = min(10.0, 0.45 * load + 0.35 * interference + 1.0)
     overload_probability = logistic(-1.8 + 0.75 * max(0.0, load - capacity) + 0.15 * interference - 0.12 * attentional_control)
     accuracy = logistic(2.0 + 0.55 * capacity - 0.55 * load - 0.22 * interference + 0.18 * attentional_control)
     rt = exp(log(950.0) + 0.06 * load + 0.05 * interference + 0.04 * cognitive_load - 0.02 * attentional_control)

     acc_sum = acc_sum + accuracy
     rt_sum = rt_sum + rt
     overload_sum = overload_sum + overload_probability
  end do

  print *, "Working-memory load-accuracy model"
  print *, "Trials: ", n
  print *, "Mean accuracy: ", acc_sum / n
  print *, "Mean RT ms: ", rt_sum / n
  print *, "Mean overload probability: ", overload_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program load_accuracy_model
