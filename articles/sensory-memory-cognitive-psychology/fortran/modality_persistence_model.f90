program modality_persistence_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i
  real :: delay, lambda, s0, trace, priority, salience, p_correct
  real :: trace_sum, correct_sum
  real :: u1, u2, u3, u4

  call random_seed()

  trace_sum = 0.0
  correct_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)

     ! Draw a modality-specific decay rate: visual faster, auditory slower, tactile intermediate.
     if (u1 < 0.4) then
        lambda = 0.0048
        delay = 700.0 * u2
        s0 = 0.95
     else if (u1 < 0.75) then
        lambda = 0.00055
        delay = 5000.0 * u2
        s0 = 0.92
     else
        lambda = 0.00125
        delay = 2400.0 * u2
        s0 = 0.82
     end if

     trace = s0 * exp(-lambda * delay)
     salience = 10.0 * u3
     priority = 10.0 * u4

     p_correct = logistic(-1.2 + 3.1 * trace + 0.18 * salience + 0.28 * priority)

     trace_sum = trace_sum + trace
     correct_sum = correct_sum + p_correct
  end do

  print *, "Modality persistence model"
  print *, "Trials: ", n
  print *, "Mean trace strength: ", trace_sum / n
  print *, "Mean correct-report probability: ", correct_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program modality_persistence_model
