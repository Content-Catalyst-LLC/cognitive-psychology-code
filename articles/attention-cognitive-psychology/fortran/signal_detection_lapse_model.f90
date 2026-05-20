program signal_detection_lapse_model
  implicit none

  integer, parameter :: n = 1000
  integer :: i, block, target, response, correct
  real :: salience, load, vigilance, lapse, evidence, p_yes, rt
  real :: correct_sum, rt_sum, lapse_sum
  real :: u1, u2, u3, u4

  call random_seed()
  correct_sum = 0.0
  rt_sum = 0.0
  lapse_sum = 0.0

  do i = 1, n
     call random_number(u1)
     call random_number(u2)
     call random_number(u3)
     call random_number(u4)

     block = 1 + int(8.0 * u1)
     target = merge(1, 0, u2 < 0.3)
     salience = 2.0 + 7.0 * u3
     load = 1.0 + 8.0 * u4
     vigilance = max(0.0, min(10.0, 8.2 - 0.45 * block - 0.20 * load))
     lapse = logistic(-2.6 + 0.34 * block + 0.22 * load - 0.30 * vigilance)
     evidence = 0.50 * salience + 0.80 * target - 0.25 * load - 1.2 * lapse
     p_yes = logistic(evidence)

     call random_number(u1)
     response = merge(1, 0, u1 < p_yes)
     correct = merge(1, 0, response == target)
     rt = exp(log(720.0) + 0.05 * block + 0.04 * load - 0.03 * salience + 0.18 * (1 - correct))

     correct_sum = correct_sum + correct
     rt_sum = rt_sum + rt
     lapse_sum = lapse_sum + lapse
  end do

  print *, "Attention signal-detection/lapse model"
  print *, "Trials: ", n
  print *, "Correct rate: ", correct_sum / n
  print *, "Mean RT ms: ", rt_sum / n
  print *, "Mean lapse probability: ", lapse_sum / n

contains

  real function logistic(x)
    real, intent(in) :: x
    logistic = 1.0 / (1.0 + exp(-x))
  end function logistic

end program signal_detection_lapse_model
