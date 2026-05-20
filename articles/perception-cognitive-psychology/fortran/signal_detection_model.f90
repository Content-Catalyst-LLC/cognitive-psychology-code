program signal_detection_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i, signal, response, correct
  real :: stimulus, threshold, noise_level, evidence, p_yes
  real :: yes_sum, correct_sum, evidence_sum
  real :: u1, u2, u3, u4

  call random_seed()
  yes_sum = 0.0
  correct_sum = 0.0
  evidence_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)

     signal = merge(1, 0, u1 < 0.55)
     stimulus = -3.0 + 6.0 * u2 + signal
     threshold = -0.5 + 2.0 * u3
     noise_level = 0.5 + 3.5 * u4
     evidence = stimulus - threshold - 0.20 * noise_level
     p_yes = logistic(1.2 * evidence)

     call random_number(u1)
     response = merge(1, 0, u1 < p_yes)
     correct = merge(1, 0, response == signal)

     yes_sum = yes_sum + response
     correct_sum = correct_sum + correct
     evidence_sum = evidence_sum + evidence
  end do

  print *, "Signal detection simulation"
  print *, "Trials: ", n
  print *, "Yes response rate: ", yes_sum / n
  print *, "Correct rate: ", correct_sum / n
  print *, "Mean evidence: ", evidence_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program signal_detection_model
